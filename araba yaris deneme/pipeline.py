#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
APEX TELEMETRY - PRODUCTION PIPELINE
Yarış Videosu Hareket Analizi, Takip ve Telemetri Çıkarma Sistemi

Bu iş hattı:
1. YOLOv8x ile araç tespiti yapar.
2. Kalman Filtresi tabanlı takipçiyle araç kimliklerini (ID) korur.
3. Homografi dönüşümü ile piksel hareketlerini gerçek dünya metre düzlemine aktarır.
4. Savitzky-Golay filtreleme ile hız, ivme ve yanal G-kuvveti gibi telemetri verilerini hesaplar.
5. Sonuçları JSON formatında dışa aktarır.
"""

import os
import json
import numpy as np
import cv2
from scipy.signal import savgol_filter
from scipy.optimize import linear_sum_assignment

# Gerekirse ultralytics kütüphanesini içe aktar
try:
    from ultralytics import YOLO
except ImportError:
    print("[UYARI] 'ultralytics' kütüphanesi yüklü değil. Model tespiti çalışmayacaktır. Yüklemek için: pip install ultralytics")

class KalmanFilter2D:
    """Nesne takibi için basitleştirilmiş 2D Sabit İvmeli Kalman Filtresi"""
    def __init__(self, dt=1.0/60.0):
        self.dt = dt
        # Durum vektörü: [x, y, vx, vy]T
        self.x = np.zeros((4, 1))
        
        # Durum geçiş matrisi
        self.F = np.array([
            [1, 0, dt, 0],
            [0, 1, 0, dt],
            [0, 0, 1,  0],
            [0, 0, 0,  1]
        ])
        
        # Ölçüm matrisi (Sadece X ve Y konumlarını ölçüyoruz)
        self.H = np.array([
            [1, 0, 0, 0],
            [0, 1, 0, 0]
        ])
        
        # Kovaryans matrisleri
        self.P = np.eye(4) * 1000.0  # İlk belirsizlik yüksek
        self.R = np.eye(2) * 5.0      # Ölçüm gürültüsü
        self.Q = np.eye(4) * 0.1      # Süreç gürültüsü

    def predict(self):
        self.x = np.dot(self.F, self.x)
        self.P = np.dot(self.F, np.dot(self.P, self.F.T)) + self.Q
        return self.x[0, 0], self.x[1, 0]

    def update(self, z):
        # z: [x_olculen, y_olculen]
        z = np.array(z).reshape(2, 1)
        y = z - np.dot(self.H, self.x) # Ölçüm artığı
        S = np.dot(self.H, np.dot(self.P, self.H.T)) + self.R
        K = np.dot(self.P, np.dot(self.H.T, np.linalg.inv(S))) # Kalman Kazancı
        
        self.x = self.x + np.dot(K, y)
        self.P = self.P - np.dot(K, np.dot(self.H, self.P))

class Tracklet:
    """Tek bir araca ait takip verisi ve Kalman filtresi"""
    def __init__(self, track_id, bbox, world_pos, dt):
        self.id = track_id
        self.kf = KalmanFilter2D(dt)
        self.kf.x[0, 0] = world_pos[0]
        self.kf.x[1, 0] = world_pos[1]
        
        self.bbox = bbox # [x1, y1, x2, y2]
        self.world_path = [world_pos]
        self.timestamps = [0.0]
        self.age = 0
        self.hits = 1
        self.no_losses = 0

    def predict(self):
        self.age += 1
        self.no_losses += 1
        return self.kf.predict()

    def update(self, bbox, world_pos, t):
        self.no_losses = 0
        self.hits += 1
        self.bbox = bbox
        self.world_path.append(world_pos)
        self.timestamps.append(t)
        self.kf.update(world_pos)

class SimpleSortTracker:
    """SORT Takip Mekanizması (Hungarian Eşleştirmesi ile)"""
    def __init__(self, max_lost_frames=30, dt=1.0/60.0):
        self.tracks = []
        self.next_id = 1
        self.max_lost_frames = max_lost_frames
        self.dt = dt

    def update(self, detections, world_positions, t):
        # detections: N x 4 (bbox)
        # world_positions: N x 2 (X, Y in meters)
        
        # 1. Mevcut aktif tracklet'ler için tahmin yap
        for trk in self.tracks:
            trk.predict()

        matched_indices = []
        unmatched_detections = list(range(len(world_positions)))
        unmatched_tracks = list(range(len(self.tracks)))

        if len(self.tracks) > 0 and len(world_positions) > 0:
            # Maliyet matrisi oluştur (Öklid mesafesi)
            cost_matrix = np.zeros((len(self.tracks), len(world_positions)), dtype=np.float32)
            for t_idx, trk in enumerate(self.tracks):
                pred_pos = [trk.kf.x[0, 0], trk.kf.x[1, 0]]
                for d_idx, det_pos in enumerate(world_positions):
                    cost_matrix[t_idx, d_idx] = np.linalg.norm(np.array(pred_pos) - np.array(det_pos))

            # Hungarian algoritması ile en iyi eşleşmeyi bul
            row_ind, col_ind = linear_sum_assignment(cost_matrix)
            
            # Gating (Mesafe sınırlandırması: örneğin 6 metreden fazla sapma olamaz)
            distance_threshold = 6.0
            for r, c in zip(row_ind, col_ind):
                if cost_matrix[r, c] < distance_threshold:
                    matched_indices.append((r, c))
                    unmatched_tracks.remove(r)
                    unmatched_detections.remove(c)

        # 2. Eşleşenleri güncelle
        for r, c in matched_indices:
            self.tracks[r].update(detections[c], world_positions[c], t)

        # 3. Eşleşmeyen tespitler için yeni Tracklet oluştur
        for d_idx in unmatched_detections:
            new_track = Tracklet(self.next_id, detections[d_idx], world_positions[d_idx], self.dt)
            self.tracks.append(new_track)
            self.next_id += 1

        # 4. Çok uzun süredir kaybedilen veya pist dışına çıkan tracklet'leri temizle
        dead_tracks = []
        for idx, trk in enumerate(self.tracks):
            if trk.no_losses > self.max_lost_frames:
                dead_tracks.append(idx)
                
        for idx in sorted(dead_tracks, reverse=True):
            self.tracks.pop(idx)

        return self.tracks

class RacingMotionPipeline:
    def __init__(self, yolo_model_path="yolov8x.pt", src_coords=None, dst_coords=None, fps=60):
        # 1. Nesne Tespiti Başlat
        if 'YOLO' in globals():
            self.detector = YOLO(yolo_model_path)
        else:
            self.detector = None
            
        self.fps = fps
        self.dt = 1.0 / fps
        
        # 2. Homografi Ayarı
        # Varsayılan piksel koordinatları -> 2D Metre koordinatları
        if src_coords is None or dst_coords is None:
            # Örnek 1080p viraj açısı homografisi
            self.src_coords = np.float32([[200, 800], [1720, 800], [1200, 400], [720, 400]])
            self.dst_coords = np.float32([[0, 40], [20, 40], [20, 0], [0, 0]])
        else:
            self.src_coords = np.float32(src_coords)
            self.dst_coords = np.float32(dst_coords)
            
        self.H, _ = cv2.findHomography(self.src_coords, self.dst_coords)
        
        # 3. Takipçi
        self.tracker = SimpleSortTracker(max_lost_frames=30, dt=self.dt)
        self.all_completed_tracks = {} # {id: {"pos": [], "time": []}}

    def transform_to_world(self, px, py):
        """Piksel (u, v) koordinatını dünya koordinatına (X, Y - metre) çevirir"""
        p = np.array([px, py, 1.0]).reshape(3, 1)
        p_world = np.dot(self.H, p)
        p_world /= p_world[2, 0]
        return float(p_world[0, 0]), float(p_world[1, 0])

    def process_frame(self, frame, frame_id):
        if self.detector is None:
            return []
            
        t = frame_id * self.dt
        
        # YOLOv8 ile araçları bul (COCO sınıf ID'si: 2=araba, 7=kamyon)
        results = self.detector(frame, classes=[2, 7], verbose=False)[0]
        
        detections = []
        world_positions = []
        
        for box in results.boxes:
            x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
            conf = box.conf[0].cpu().numpy()
            
            # Alt orta nokta (Lastiklerin yola değdiği nokta) homografi için idealdir
            cx = (x1 + x2) / 2
            cy = y2
            
            wx, wy = self.transform_to_world(cx, cy)
            
            detections.append([x1, y1, x2, y2, conf])
            world_positions.append([wx, wy])
            
        # Takipçiyi güncelle
        active_tracks = self.tracker.update(detections, world_positions, t)
        
        # Bitmiş veya aktif olan tüm konumları arşivle
        for trk in active_tracks:
            if trk.id not in self.all_completed_tracks:
                self.all_completed_tracks[trk.id] = {"pos": [], "time": []}
            self.all_completed_tracks[trk.id]["pos"].append(trk.world_path[-1])
            self.all_completed_tracks[trk.id]["time"].append(t)
            
        return active_tracks

    def generate_telemetry_report(self, output_filepath="telemetry_report.json"):
        """Tüm kayıtlı araçların hız, ivme ve G-Force verilerini hesaplar ve JSON olarak yazar"""
        report_data = {}
        
        for track_id, data in self.all_completed_tracks.items():
            pos = np.array(data["pos"])
            times = np.array(data["time"])
            
            # Gürültü filtreleme için Savitzky-Golay pencere genişliği
            # En az 11 veri noktası gereklidir
            window = 11
            if len(pos) < window:
                if len(pos) > 3:
                    # Daha küçük pencereli filtreleme
                    window = len(pos) if len(pos) % 2 != 0 else len(pos) - 1
                else:
                    continue # Çok az veri
                    
            if window < 3:
                continue

            try:
                # Savitzky-Golay Filtreleme ile Konum Düzleştirme
                wx_smooth = savgol_filter(pos[:, 0], window, 2)
                wy_smooth = savgol_filter(pos[:, 1], window, 2)
                
                # Diferansiyel Hız (v = ds/dt)
                dx = np.diff(wx_smooth)
                dy = np.diff(wy_smooth)
                dt = np.diff(times)
                
                # Sıfıra bölme hatası engelleme
                dt[dt == 0] = 1.0 / self.fps
                
                speeds = np.sqrt(dx**2 + dy**2) / dt  # m/s
                speeds_kmh = speeds * 3.6  # km/h
                
                # Boyuna İvme (a = dv/dt)
                accel = np.diff(speeds) / dt[:-1]
                accel_g = accel / 9.81
                
                # Yanal İvme (Merkezkaç ivme) ve Viraj Yarıçapı
                angles = np.arctan2(dy, dx)
                d_theta = np.diff(angles)
                angular_velocity = d_theta / dt[:-1]
                
                lat_g = (speeds[1:]**2 * angular_velocity) / 9.81
                
                report_data[f"CAR_{track_id}"] = {
                    "raw_points": pos.tolist(),
                    "smoothed_points": list(zip(wx_smooth.tolist(), wy_smooth.tolist())),
                    "timestamps": times.tolist(),
                    "speed_kmh": [0.0] + speeds_kmh.tolist(),
                    "longitudinal_g": [0.0, 0.0] + accel_g.tolist(),
                    "lateral_g": [0.0, 0.0] + lat_g.tolist(),
                    "max_speed": float(np.max(speeds_kmh)),
                    "avg_speed": float(np.mean(speeds_kmh)),
                    "max_lat_g": float(np.max(np.abs(lat_g)))
                }
            except Exception as e:
                print(f"[HATA] CAR_{track_id} verisi işlenirken hata oluştu: {str(e)}")

        with open(output_filepath, "w", encoding="utf-8") as f:
            json.dump(report_data, f, indent=4, ensure_ascii=False)
            
        print(f"[BAŞARILI] Telemetri raporu oluşturuldu: {output_filepath}")
        return report_data

if __name__ == "__main__":
    print("--------------------------------------------------")
    print("APEX TELEMETRY - Yarış Arabası Analiz Pipeline")
    print("--------------------------------------------------")
    print("İş hattı yükleme başarılı.")
    print("Dosya doğrudan çalıştırıldığında simülasyon modunu başlatır.")
    
    # Simülasyon modunda yapay veri üretelim ve kaydedelim
    pipeline = RacingMotionPipeline()
    
    # 200 frame'lik yapay takip simüle et
    print("Yapay araç hareket verileri üretiliyor...")
    pipeline.all_completed_tracks[1] = {"pos": [], "time": []}
    
    # Düzlükten viraja giren ve dönen araç konumu simülasyonu
    t_arr = np.linspace(0, 5, 300)
    for i, t in enumerate(t_arr):
        if t < 2:
            # Düzlükte gitme (Hız 300 km/h = 83.3 m/s)
            wx = 10.0 + (np.random.normal(0, 0.05))
            wy = t * 83.3
        else:
            # Viraja girme ve sola keskin dönüş
            angle = (t - 2) * (np.pi / 3) # 60 derece dönüş
            wx = 10.0 - np.sin(angle) * 30 + (np.random.normal(0, 0.05))
            wy = 2 * 83.3 + np.cos(angle) * 30
            
        pipeline.all_completed_tracks[1]["pos"].append([wx, wy])
        pipeline.all_completed_tracks[1]["time"].append(t)
        
    pipeline.generate_telemetry_report("sample_telemetry.json")
