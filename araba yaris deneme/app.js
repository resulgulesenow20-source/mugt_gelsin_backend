/* ==============================================================================
   APEX TELEMETRY - CORE APPLICATION LOGIC & SIMULATION ENGINE
   ============================================================================== */

document.addEventListener("DOMContentLoaded", () => {
    // --------------------------------------------------------------------------
    // SEKMELİ YAPI KONTROLÜ
    // --------------------------------------------------------------------------
    const navButtons = document.querySelectorAll(".nav-btn");
    const tabContents = document.querySelectorAll(".tab-content");
    const currentTabTitle = document.getElementById("current-tab-title");
    const currentTabDesc = document.getElementById("current-tab-desc");

    const tabMetadata = {
        "hud-tab": {
            title: "Canlı Telemetri HUD",
            desc: "Video akışı üzerinden gerçek zamanlı tespit, takip ve hız analizi."
        },
        "calibration-tab": {
            title: "Homografi Kalibrasyonu",
            desc: "Perspektif kamera görüntülerini gerçek dünya (metre) koordinat düzlemine eşler."
        },
        "racing-line-tab": {
            title: "Yarış Çizgisi & Apeks",
            desc: "Sürücülerin pist üzerindeki çizgilerini ve viraj içi hız değişimlerini inceler."
        },
        "comparison-tab": {
            title: "Sürücü Karşılaştırma",
            desc: "İki sürücünün telemetri verilerini grafikler üzerinden milisaniyelik hassasiyetle kıyaslar."
        },
        "pipeline-code-tab": {
            title: "Python CV Kodları",
            desc: "Üretimde kullanılmak üzere tasarlanan nesne tespiti, takip ve telemetri çıkarma kodları."
        }
    };

    navButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const targetTab = btn.getAttribute("data-tab");
            
            // Aktif buton değiştirme
            navButtons.forEach(b => b.classList.remove("active"));
            btn.classList.add("active");
            
            // Aktif sekme içeriği değiştirme
            tabContents.forEach(content => content.classList.remove("active"));
            document.getElementById(targetTab).classList.add("active");
            
            // Başlık ve açıklama güncelleme
            currentTabTitle.textContent = tabMetadata[targetTab].title;
            currentTabDesc.textContent = tabMetadata[targetTab].desc;
            
            // Grafikleri veya canvas'ları gerektiğinde yeniden tetikle
            if (targetTab === "comparison-tab") {
                initComparisonCharts();
            } else if (targetTab === "racing-line-tab") {
                drawRacingLineAnalysis();
            }
        });
    });

    // --------------------------------------------------------------------------
    // CANLI TELEMETRİ HUD VE VİDEO SİMÜLASYONU
    // --------------------------------------------------------------------------
    const videoCanvas = document.getElementById("video-canvas");
    const ctx = videoCanvas.getContext("2d");
    
    // Simülasyon Değişkenleri
    let isPlaying = true;
    let frameId = 0;
    const fps = 60;
    const totalFrames = 600; // ~10 saniyelik bir tur sekansı
    let simInterval = null;

    // Pist Seçimi
    const trackSelect = document.getElementById("track-select");
    
    // HUD Arayüz Elemanları
    const playPauseBtn = document.getElementById("play-pause-btn");
    const resetSimBtn = document.getElementById("reset-sim-btn");
    const simTimeText = document.getElementById("sim-time");
    const hudSpeedText = document.getElementById("hud-speed");
    const speedGaugeBar = document.getElementById("speed-gauge-bar");
    const throttleFill = document.getElementById("throttle-fill");
    const brakeFill = document.getElementById("brake-fill");
    const hudCarInfo = document.getElementById("hud-car-info");
    
    // G-Force Elemanları
    const gforceCanvas = document.getElementById("gforce-canvas");
    const gctx = gforceCanvas.getContext("2d");
    const gforceLatText = document.getElementById("gforce-lat");
    const gforceLonText = document.getElementById("gforce-lon");

    // Simülasyon Veri Yapısı (Spa Pistinin bir bölümü)
    function getSimulatedTelemetry(frame) {
        const progress = frame / totalFrames; // 0 to 1
        
        let speed = 310;
        let throttle = 100;
        let brake = 0;
        let latG = 0.1;
        let lonG = 0.05;
        let currentSector = 1;
        
        // Simüle edilen sekans: Düzlük -> Sert Frenleme (Viraj 1) -> Viraj Dönüşü -> Düzlüğe Çıkış -> Eau Rouge Hızlanması
        if (progress < 0.2) {
            // Düzlük
            speed = 310 + Math.sin(progress * 20) * 2;
            throttle = 100;
            brake = 0;
            latG = (Math.random() - 0.5) * 0.1;
            lonG = 0.15 + (Math.random() - 0.5) * 0.05;
        } else if (progress >= 0.2 && progress < 0.35) {
            // Sert Frenleme
            const brakeProgress = (progress - 0.2) / 0.15;
            speed = 312 - brakeProgress * 220; // Hız 92 km/h'ye düşer
            throttle = 0;
            brake = 100 - (1 - brakeProgress) * 20;
            latG = (progress - 0.2) * 1.5;
            lonG = -4.5 + brakeProgress * 1.5; // -4.5 G'ye kadar yavaşlama
        } else if (progress >= 0.35 && progress < 0.5) {
            // Apeks ve Dönüş (La Source)
            const turnProgress = (progress - 0.35) / 0.15;
            speed = 92 + turnProgress * 30; // Hızlanma başlar
            throttle = 20 + turnProgress * 40;
            brake = 0;
            latG = 3.2 - Math.sin(turnProgress * Math.PI) * 1.2; // Yanal G kuvveti
            lonG = 0.5 + turnProgress * 0.8;
            currentSector = 2;
        } else if (progress >= 0.5 && progress < 0.75) {
            // Viraj çıkışı ve Eau Rouge'a doğru hızlanma
            const accelProgress = (progress - 0.5) / 0.25;
            speed = 122 + accelProgress * 170; // 292 km/h'ye çıkar
            throttle = 100;
            brake = 0;
            latG = -0.5 + Math.sin(accelProgress * 3) * 0.3;
            lonG = 1.2 - accelProgress * 0.8;
        } else {
            // Eau Rouge tırmanışı (Büyük yanal ivme salınımı)
            const erProgress = (progress - 0.75) / 0.25;
            speed = 292 + erProgress * 20;
            throttle = 100;
            brake = 0;
            // Sol-sağ sert viraj geçişi
            latG = Math.sin(erProgress * Math.PI * 2) * 4.2; 
            lonG = -0.2 + Math.cos(erProgress * Math.PI) * 0.5;
            currentSector = 3;
        }

        return {
            speed: Math.round(speed),
            throttle: Math.round(throttle),
            brake: Math.round(brake),
            latG: parseFloat(latG.toFixed(2)),
            lonG: parseFloat(lonG.toFixed(2)),
            sector: currentSector
        };
    }

    // Video Canvas Çizim Döngüsü (Yarış Arabası Simülasyonu)
    function drawVideoFrame() {
        ctx.fillStyle = "#0c0d12";
        ctx.fillRect(0, 0, videoCanvas.width, videoCanvas.height);

        // 1. Yol Çizimi (Perspektif)
        ctx.beginPath();
        ctx.moveTo(350, 150);
        ctx.lineTo(450, 150);
        ctx.lineTo(800, 450);
        ctx.lineTo(0, 450);
        ctx.closePath();
        ctx.fillStyle = "#1e2029";
        ctx.fill();

        // 2. Yol Şeritleri (Hareketli Kesikli Çizgi)
        ctx.strokeStyle = "#383d4f";
        ctx.lineWidth = 2;
        const lineOffset = (frameId * 8) % 40;
        for (let y = 150; y < 450; y += 40) {
            const currentY = y + lineOffset;
            if (currentY > 450) continue;
            
            // Sol ve sağ çizgiler
            const t = (currentY - 150) / 300;
            const leftX = 350 - t * 350;
            const rightX = 450 + t * 350;
            
            ctx.beginPath();
            ctx.moveTo(leftX, currentY);
            ctx.lineTo(leftX, currentY + 15);
            ctx.moveTo(rightX, currentY);
            ctx.lineTo(rightX, currentY + 15);
            ctx.stroke();
        }

        // Kerbler (Kırmızı-Beyaz Rumble Strips)
        const numKerbs = 10;
        for (let i = 0; i < numKerbs; i++) {
            const kerbProgress = ((i / numKerbs) + (frameId * 0.02)) % 1;
            const kerbY = 150 + kerbProgress * 300;
            const kerbH = 8 + kerbProgress * 15;
            
            const t = (kerbY - 150) / 300;
            const leftX = 350 - t * 350;
            const rightX = 450 + t * 350;
            const kerbW = 5 + t * 40;
            
            ctx.fillStyle = Math.floor(i + frameId/5) % 2 === 0 ? "#ff3b30" : "#ffffff";
            // Sol Kerb
            ctx.fillRect(leftX - kerbW, kerbY, kerbW, kerbH);
            // Sağ Kerb
            ctx.fillRect(rightX, kerbY, kerbW, kerbH);
        }

        // 3. Telemetri verilerini al
        const data = getSimulatedTelemetry(frameId);

        // 4. Yarış Arabası Çizimi (Perspektif)
        // Arabanın konumu viraja göre hafif yanal salınım yapar
        const carXOffset = Math.sin(frameId * 0.04) * 60 - (data.latG * 12);
        const carWidth = 140;
        const carHeight = 70;
        const carX = (videoCanvas.width / 2) - (carWidth / 2) + carXOffset;
        const carY = 320;

        // Araba Gövdesi
        ctx.fillStyle = "rgba(255, 59, 48, 0.95)"; // Karbon Kırmızı
        ctx.beginPath();
        ctx.moveTo(carX + 20, carY + 30);
        ctx.lineTo(carX + 120, carY + 30);
        ctx.lineTo(carX + 130, carY + 60);
        ctx.lineTo(carX + 10, carY + 60);
        ctx.closePath();
        ctx.fill();

        // Arka Kanat
        ctx.fillStyle = "#111";
        ctx.fillRect(carX + 15, carY + 5, carWidth - 30, 8);
        ctx.fillRect(carX + 15, carY + 5, 8, 25);
        ctx.fillRect(carX + carWidth - 23, carY + 5, 8, 25);

        // Tekerlekler
        ctx.fillStyle = "#050505";
        ctx.fillRect(carX, carY + 35, 18, 35); // Sol arka
        ctx.fillRect(carX + carWidth - 18, carY + 35, 18, 35); // Sağ arka
        ctx.fillRect(carX + 22, carY + 25, 14, 25); // Sol ön
        ctx.fillRect(carX + carWidth - 36, carY + 25, 14, 25); // Sağ ön

        // Kask / Kokpit
        ctx.fillStyle = "#ffcc00";
        ctx.beginPath();
        ctx.arc(carX + carWidth/2, carY + 35, 10, 0, Math.PI * 2);
        ctx.fill();

        // 5. YOLOv8 Bounding Box Çizimi
        ctx.strokeStyle = "rgba(52, 199, 89, 0.85)";
        ctx.lineWidth = 2;
        const boxX = carX - 10;
        const boxY = carY - 2;
        const boxW = carWidth + 20;
        const boxH = carHeight + 5;
        ctx.strokeRect(boxX, boxY, boxW, boxH);

        // Bounding Box Etiketi
        ctx.fillStyle = "rgba(52, 199, 89, 0.85)";
        ctx.fillRect(boxX, boxY - 24, 180, 24);
        ctx.fillStyle = "#000";
        ctx.font = "bold 11px Inter";
        ctx.fillText(`CAR #1 [VER] | Conf: 98%`, boxX + 6, boxY - 8);

        // 6. DeepSORT İzleme Yörüngesi (Trailing Path)
        ctx.strokeStyle = "rgba(0, 122, 255, 0.4)";
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(videoCanvas.width/2, 450);
        for(let i = 0; i < 40; i++) {
            const backFrame = (frameId - i + totalFrames) % totalFrames;
            const backData = getSimulatedTelemetry(backFrame);
            const backXOffset = Math.sin(backFrame * 0.04) * 60 - (backData.latG * 12);
            const py = 320 + i * 3.5;
            const px = (videoCanvas.width / 2) + backXOffset;
            if (py < 450) {
                ctx.lineTo(px, py);
            }
        }
        ctx.stroke();

        // 7. Arayüz Göstergelerini Güncelleme
        hudSpeedText.textContent = data.speed;
        
        // Conic gradient açısını ayarla (conic gradient 220 dereceden başlar)
        const speedPercent = data.speed / 340;
        const activeAngle = speedPercent * 260; // 260 derece maksimum yay
        speedGaugeBar.style.background = `conic-gradient(from 220deg, var(--accent-blue) 0%, var(--accent-red) ${activeAngle}deg, rgba(255,255,255,0.05) ${activeAngle}deg, rgba(255,255,255,0.05) 360deg)`;
        
        throttleFill.style.height = `${data.throttle}%`;
        brakeFill.style.height = `${data.brake}%`;
        
        // Zaman formatlama (01:45.32 formatı)
        const baseSeconds = 105.32;
        const currentSeconds = baseSeconds + (frameId / fps);
        const mins = Math.floor(currentSeconds / 60);
        const secs = Math.floor(currentSeconds % 60);
        const ms = Math.floor((currentSeconds % 1) * 100);
        simTimeText.textContent = `Lap Time: 0${mins}:${secs.toString().padStart(2, '0')}.${ms.toString().padStart(2, '0')}`;
        
        hudCarInfo.innerHTML = `CAR #1 (VER) | Hız: <span style="color:var(--accent-blue)">${data.speed} km/h</span> | İvme: <span style="color:${data.lonG >= 0 ? 'var(--accent-green)':'var(--accent-red)'}">${data.lonG} G</span> | Sektör: ${data.sector}`;
        
        // G-Force Balon Çizimi
        drawGForceBubble(data.latG, data.lonG);
    }

    // G-Force Dairesel Arayüzü Çizimi
    function drawGForceBubble(lat, lon) {
        gctx.clearRect(0, 0, gforceCanvas.width, gforceCanvas.height);
        
        const cx = gforceCanvas.width / 2;
        const cy = gforceCanvas.height / 2;
        const maxRadius = cx - 15;
        
        // Eksen Çizgileri
        gctx.strokeStyle = "rgba(255, 255, 255, 0.1)";
        gctx.lineWidth = 1;
        gctx.beginPath();
        gctx.moveTo(cx, 0); gctx.lineTo(cx, gforceCanvas.height);
        gctx.moveTo(0, cy); gctx.lineTo(gforceCanvas.width, cy);
        gctx.stroke();
        
        // Konsantrik G Halkaları (1G, 2G, 3G, 4G, 5G limitleri)
        for (let i = 1; i <= 5; i++) {
            const r = (i / 5) * maxRadius;
            gctx.beginPath();
            gctx.arc(cx, cy, r, 0, Math.PI * 2);
            gctx.strokeStyle = i === 5 ? "rgba(255, 59, 48, 0.3)" : "rgba(255, 255, 255, 0.05)";
            gctx.stroke();
            if (i % 2 === 0) {
                gctx.fillStyle = "rgba(255, 255, 255, 0.2)";
                gctx.font = "8px Orbitron";
                gctx.fillText(`${i}G`, cx + r - 12, cy - 2);
            }
        }
        
        // Merkez Top (Mevcut G-Force)
        // Maksimum G ölçeği 5G olarak belirlendi
        const scale = maxRadius / 5;
        const bubbleX = cx + (lat * scale);
        const bubbleY = cy - (lon * scale); // Eksi işaret çünkü canvas'ta aşağı yön +Y'dir.
        
        // Hareket İzi (Tail)
        gctx.beginPath();
        gctx.arc(bubbleX, bubbleY, 6, 0, Math.PI * 2);
        gctx.fillStyle = "rgba(255, 204, 0, 0.85)";
        gctx.shadowColor = "rgba(255, 204, 0, 0.5)";
        gctx.shadowBlur = 8;
        gctx.fill();
        gctx.shadowBlur = 0; // Sıfırla
        
        gforceLatText.textContent = `${lat > 0 ? '+':''}${lat} G`;
        gforceLonText.textContent = `${lon > 0 ? '+':''}${lon} G`;
    }

    // Simülasyon Oynatma/Durdurma Kontrolleri
    function startSimulation() {
        if (!simInterval) {
            simInterval = setInterval(() => {
                if (isPlaying) {
                    frameId = (frameId + 1) % totalFrames;
                    drawVideoFrame();
                }
            }, 1000 / fps);
        }
    }

    playPauseBtn.addEventListener("click", () => {
        isPlaying = !isPlaying;
        playPauseBtn.textContent = isPlaying ? "⏸ Duraklat" : "▶ Başlat";
        playPauseBtn.className = isPlaying ? "btn primary" : "btn secondary";
    });

    resetSimBtn.addEventListener("click", () => {
        frameId = 0;
        if (!isPlaying) {
            drawVideoFrame();
        }
    });

    // Başlat
    startSimulation();

    // --------------------------------------------------------------------------
    // KAMERA HOMOGRAFİ KALİBRASYON ARACI
    // --------------------------------------------------------------------------
    const calibSrcCanvas = document.getElementById("calib-src-canvas");
    const sctx = calibSrcCanvas.getContext("2d");
    const calibDstCanvas = document.getElementById("calib-dst-canvas");
    const dctx = calibDstCanvas.getContext("2d");
    
    const calcHomographyBtn = document.getElementById("calc-homography-btn");
    const resetCalibBtn = document.getElementById("reset-calib-btn");
    const matrixDisplay = document.getElementById("homography-matrix-display");
    
    // Kalibrasyon Noktaları
    let srcPoints = [];
    // Gerçek Dünya Karşılık Noktaları (Varsayılan 2D üstten pist boyutları: Metre)
    // 40m x 40m'lik bir alana ölçekli
    const dstPoints = [
        { x: 150, y: 300, wx: 0, wy: 40 },   // Sol ön (0, 40)
        { x: 410, y: 300, wx: 20, wy: 40 },  // Sağ ön (20, 40)
        { x: 480, y: 50,  wx: 20, wy: 0 },   // Sağ arka (20, 0)
        { x: 80,  y: 50,  wx: 0, wy: 0 }     // Sol arka (0, 0)
    ];

    // Kamera Perspektif Görselini Çiz (Spa Pist virajı temsil eden sabit resim)
    function drawCalibrationSource() {
        sctx.fillStyle = "#16181f";
        sctx.fillRect(0, 0, calibSrcCanvas.width, calibSrcCanvas.height);
        
        // Temsili Perspektif Yol Çizimi
        sctx.beginPath();
        sctx.moveTo(80, 50);
        sctx.lineTo(480, 50);
        sctx.lineTo(410, 300);
        sctx.lineTo(150, 300);
        sctx.closePath();
        sctx.fillStyle = "#2d313f";
        sctx.fill();
        sctx.strokeStyle = "rgba(255,255,255,0.2)";
        sctx.stroke();

        // Kılavuz Grid Çizimi (Perspektif)
        sctx.strokeStyle = "rgba(255, 255, 255, 0.05)";
        sctx.lineWidth = 1;
        for (let i = 1; i < 4; i++) {
            const ratio = i / 4;
            // Dikey perspektif çizgileri
            const topX = 80 + ratio * 400;
            const botX = 150 + ratio * 260;
            sctx.beginPath();
            sctx.moveTo(topX, 50);
            sctx.lineTo(botX, 300);
            sctx.stroke();
        }

        // Tıklanan Noktaları Çiz
        srcPoints.forEach((pt, idx) => {
            sctx.beginPath();
            sctx.arc(pt.x, pt.y, 6, 0, Math.PI * 2);
            sctx.fillStyle = "var(--accent-red)";
            sctx.fill();
            sctx.strokeStyle = "#fff";
            sctx.stroke();
            
            sctx.fillStyle = "#fff";
            sctx.font = "bold 10px Inter";
            sctx.fillText(`P${idx+1}`, pt.x + 10, pt.y + 4);
        });

        // Bağlantı Çizgileri
        if (srcPoints.length === 4) {
            sctx.beginPath();
            sctx.moveTo(srcPoints[0].x, srcPoints[0].y);
            for(let i=1; i<4; i++) sctx.lineTo(srcPoints[i].x, srcPoints[i].y);
            sctx.closePath();
            sctx.strokeStyle = "rgba(255, 59, 48, 0.5)";
            sctx.lineWidth = 2;
            sctx.stroke();
        }
    }

    // 2D Üstten Görünüm Haritası Çizimi (Dünya Koordinat Sistemi)
    function drawCalibrationDestination() {
        dctx.fillStyle = "#11131a";
        dctx.fillRect(0, 0, calibDstCanvas.width, calibDstCanvas.height);
        
        // Grid Sistemi
        dctx.strokeStyle = "rgba(255, 255, 255, 0.05)";
        dctx.lineWidth = 1;
        const gridGap = 35;
        for (let x = 0; x < calibDstCanvas.width; x += gridGap) {
            dctx.beginPath(); dctx.moveTo(x, 0); dctx.lineTo(x, calibDstCanvas.height); dctx.stroke();
        }
        for (let y = 0; y < calibDstCanvas.height; y += gridGap) {
            dctx.beginPath(); dctx.moveTo(0, y); dctx.lineTo(calibDstCanvas.width, y); dctx.stroke();
        }

        // Dönüştürülmüş Hedef Eşleşme Alanı (Örn: 2D Dikdörtgen)
        dctx.beginPath();
        dctx.moveTo(dstPoints[0].x, dstPoints[0].y);
        dctx.lineTo(dstPoints[1].x, dstPoints[1].y);
        dctx.lineTo(dstPoints[2].x, dstPoints[2].y);
        dctx.lineTo(dstPoints[3].x, dstPoints[3].y);
        dctx.closePath();
        dctx.fillStyle = "rgba(0, 122, 255, 0.1)";
        dctx.fill();
        dctx.strokeStyle = "rgba(0, 122, 255, 0.5)";
        dctx.lineWidth = 2;
        dctx.stroke();

        // Noktaları Çiz
        dstPoints.forEach((pt, idx) => {
            dctx.beginPath();
            dctx.arc(pt.x, pt.y, 6, 0, Math.PI * 2);
            dctx.fillStyle = "var(--accent-blue)";
            dctx.fill();
            dctx.strokeStyle = "#fff";
            dctx.stroke();
            
            dctx.fillStyle = "#fff";
            dctx.font = "bold 10px Inter";
            dctx.fillText(`P${idx+1} (${pt.wx}m, ${pt.wy}m)`, pt.x + 10, pt.y + 4);
        });
    }

    // Kaynak canvas tıklama dinleyicisi
    calibSrcCanvas.addEventListener("click", (e) => {
        if (srcPoints.length >= 4) return; // Maksimum 4 nokta
        
        const rect = calibSrcCanvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        srcPoints.push({ x: Math.round(x), y: Math.round(y) });
        
        // Metin koordinatlarını güncelle
        document.getElementById(`src-p${srcPoints.length}`).textContent = `(${Math.round(x)}, ${Math.round(y)}) px`;
        
        drawCalibrationSource();
    });

    resetCalibBtn.addEventListener("click", () => {
        srcPoints = [];
        for (let i = 1; i <= 4; i++) {
            document.getElementById(`src-p${i}`).textContent = "-";
        }
        matrixDisplay.textContent = `[ 1.000e+00,  0.000e+00,  0.000e+00 ]\n[ 0.000e+00,  1.000e+00,  0.000e+00 ]\n[ 0.000e+00,  0.000e+00,  1.000e+00 ]`;
        drawCalibrationSource();
    });

    // 4 Noktalı Homografi Çözücü (Sayısal Analiz Gaussian Elimination ile Ax = B çözümü)
    function solveHomography(src, dst) {
        // A matrisi ve B vektörünün oluşturulması (8 parametreli homografi için)
        // H = [h11, h12, h13, h21, h22, h23, h31, h32, 1]
        let A = [];
        let B = [];
        
        for (let i = 0; i < 4; i++) {
            const x = src[i].x;
            const y = src[i].y;
            const X = dst[i].wx;
            const Y = dst[i].wy;
            
            A.push([x, y, 1, 0, 0, 0, -X*x, -X*y]);
            B.push(X);
            A.push([0, 0, 0, x, y, 1, -Y*x, -Y*y]);
            B.push(Y);
        }
        
        // Gaussian Elimination ile Denklem Sistemini Çöz
        const h = gaussianElimination(A, B);
        if (!h) return null;
        
        // Matris Formatında Döndür
        return [
            [h[0], h[1], h[2]],
            [h[3], h[4], h[5]],
            [h[6], h[7], 1.0]
        ];
    }

    function gaussianElimination(A, B) {
        const n = B.length;
        for (let i = 0; i < n; i++) {
            // Pivot seçimi
            let maxRow = i;
            for (let k = i + 1; k < n; k++) {
                if (Math.abs(A[k][i]) > Math.abs(A[maxRow][i])) {
                    maxRow = k;
                }
            }
            // Satırları değiştir
            const tempRow = A[i]; A[i] = A[maxRow]; A[maxRow] = tempRow;
            const tempVal = B[i]; B[i] = B[maxRow]; B[maxRow] = tempVal;
            
            if (Math.abs(A[i][i]) < 1e-10) return null; // Matris tekil
            
            for (let k = i + 1; k < n; k++) {
                const c = -A[k][i] / A[i][i];
                for (let j = i; j < n; j++) {
                    if (i === j) A[k][j] = 0;
                    else A[k][j] += c * A[i][j];
                }
                B[k] += c * B[i];
            }
        }
        
        // Geriye doğru yerine koyma
        const x = new Array(n).fill(0);
        for (let i = n - 1; i >= 0; i--) {
            let sum = 0;
            for (let j = i + 1; j < n; j++) {
                sum += A[i][j] * x[j];
            }
            x[i] = (B[i] - sum) / A[i][i];
        }
        return x;
    }

    calcHomographyBtn.addEventListener("click", () => {
        if (srcPoints.length < 4) {
            alert("Lütfen önce kaynak görsel üzerinde 4 adet kalibrasyon noktası seçin!");
            return;
        }
        
        const H = solveHomography(srcPoints, dstPoints);
        if (H) {
            matrixDisplay.textContent = `[ ${H[0][0].toExponential(3)}, ${H[0][1].toExponential(3)}, ${H[0][2].toExponential(3)} ]
[ ${H[1][0].toExponential(3)}, ${H[1][1].toExponential(3)}, ${H[1][2].toExponential(3)} ]
[ ${H[2][0].toExponential(3)}, ${H[2][1].toExponential(3)}, ${H[2][2].toExponential(3)} ]`;
        } else {
            alert("Homografi çözülemedi. Seçtiğiniz noktaların doğrusal (lineer bağımlı) olmadığından emin olun.");
        }
    });

    // Kalibrasyon ilk çizimleri
    drawCalibrationSource();
    drawCalibrationDestination();


    // --------------------------------------------------------------------------
    // YARIŞ ÇİZGİSİ VE APEKS VİRAL PLOTTER
    // --------------------------------------------------------------------------
    const trackPlotCanvas = document.getElementById("track-plot-canvas");
    const tctx = trackPlotCanvas.getContext("2d");

    function drawRacingLineAnalysis() {
        tctx.clearRect(0, 0, trackPlotCanvas.width, trackPlotCanvas.height);
        
        // 1. Pist Sınırlarını Çiz (2D Kuşbakışı Spa La Source Virajı)
        tctx.strokeStyle = "rgba(255, 255, 255, 0.12)";
        tctx.lineWidth = 35;
        tctx.lineCap = "round";
        tctx.lineJoin = "round";
        
        tctx.beginPath();
        tctx.moveTo(50, 200);
        tctx.quadraticCurveTo(350, 80, 500, 250);
        tctx.lineTo(650, 320);
        tctx.stroke();

        // Pist içi asfalt rengi (Gri)
        tctx.strokeStyle = "#1a1c24";
        tctx.lineWidth = 30;
        tctx.stroke();

        // Apeks Bölgesi (Viraj merkezi)
        tctx.beginPath();
        tctx.arc(320, 130, 18, 0, Math.PI * 2);
        tctx.fillStyle = "rgba(255, 204, 0, 0.15)";
        tctx.strokeStyle = "rgba(255, 204, 0, 0.5)";
        tctx.lineWidth = 1;
        tctx.fill();
        tctx.stroke();
        
        tctx.fillStyle = "var(--accent-yellow)";
        tctx.font = "bold 9px Orbitron";
        tctx.fillText("APEX ZONE", 285, 110);

        // 2. İdeal Yarış Çizgisi Çizimi (Yeşil Kesikli Çizgi)
        tctx.strokeStyle = "var(--accent-green)";
        tctx.lineWidth = 2;
        tctx.setLineDash([4, 4]);
        tctx.beginPath();
        tctx.moveTo(50, 210);
        tctx.quadraticCurveTo(330, 120, 510, 260);
        tctx.lineTo(650, 330);
        tctx.stroke();
        tctx.setLineDash([]); // Sıfırla

        // 3. Sürücü A (VER) Çizgisi (Kırmızı)
        // Apeks noktasına teğet, viraj çıkışında geniş
        tctx.strokeStyle = "var(--accent-red)";
        tctx.lineWidth = 3;
        tctx.beginPath();
        tctx.moveTo(50, 208);
        tctx.quadraticCurveTo(325, 122, 515, 258);
        tctx.lineTo(655, 328);
        tctx.stroke();

        // 4. Sürücü B (HAM) Çizgisi (Mavi)
        // Apeksi biraz kaçırmış (genişten dönüyor)
        tctx.strokeStyle = "var(--accent-blue)";
        tctx.lineWidth = 3;
        tctx.beginPath();
        tctx.moveTo(50, 215);
        tctx.quadraticCurveTo(345, 138, 505, 265);
        tctx.lineTo(645, 335);
        tctx.stroke();

        // 5. Araçların Mevcut Konumu
        // Simülasyon frame_id'sine göre pistte ilerleyen iki nokta
        const simProgress = frameId / totalFrames;
        
        // Bezier Eğrisi Noktası Hesaplama Fonksiyonu
        function getBezierPoint(t, p0, p1, p2) {
            const x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
            const y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
            return { x, y };
        }

        let p0_ver = { x: 50, y: 208 }, p1_ver = { x: 325, y: 122 }, p2_ver = { x: 515, y: 258 };
        let p0_ham = { x: 50, y: 215 }, p1_ham = { x: 345, y: 138 }, p2_ham = { x: 505, y: 265 };

        let posVer = getBezierPoint(simProgress, p0_ver, p1_ver, p2_ver);
        let posHam = getBezierPoint(Math.max(0, simProgress - 0.02), p0_ham, p1_ham, p2_ham); // HAM biraz geride

        // Sürücü A Noktası
        tctx.beginPath();
        tctx.arc(posVer.x, posVer.y, 8, 0, Math.PI * 2);
        tctx.fillStyle = "var(--accent-red)";
        tctx.strokeStyle = "#fff";
        tctx.lineWidth = 2;
        tctx.fill();
        tctx.stroke();
        
        tctx.fillStyle = "#fff";
        tctx.font = "bold 9px Inter";
        tctx.fillText("VER", posVer.x - 10, posVer.y - 12);

        // Sürücü B Noktası
        tctx.beginPath();
        tctx.arc(posHam.x, posHam.y, 8, 0, Math.PI * 2);
        tctx.fillStyle = "var(--accent-blue)";
        tctx.strokeStyle = "#fff";
        tctx.lineWidth = 2;
        tctx.fill();
        tctx.stroke();
        
        tctx.fillStyle = "#fff";
        tctx.font = "bold 9px Inter";
        tctx.fillText("HAM", posHam.x - 10, posHam.y - 12);
    }


    // --------------------------------------------------------------------------
    // SÜRÜCÜ KARŞILAŞTIRMA GRAFİKLERİ (CHART.JS)
    // --------------------------------------------------------------------------
    let speedChart = null;
    let gforceChart = null;
    let pedalsChart = null;
    let deltaChart = null;

    function initComparisonCharts() {
        // Grafikler zaten yüklendiyse yok et (yeniden boyutlandırma/güncelleme için)
        if (speedChart) speedChart.destroy();
        if (gforceChart) gforceChart.destroy();
        if (pedalsChart) pedalsChart.destroy();
        if (deltaChart) deltaChart.destroy();

        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: {
                    grid: { color: "rgba(255, 255, 255, 0.05)" },
                    ticks: { color: "var(--text-secondary)", font: { family: "Inter", size: 10 } },
                    title: { display: true, text: 'Lap Mesafesi (Metre)', color: 'var(--text-secondary)' }
                },
                y: {
                    grid: { color: "rgba(255, 255, 255, 0.05)" },
                    ticks: { color: "var(--text-secondary)", font: { family: "Inter", size: 10 } }
                }
            },
            plugins: {
                legend: {
                    labels: { color: "var(--text-primary)", font: { family: "Inter", size: 11 } }
                }
            }
        };

        // Örnek Mesafe Eksen Verisi (0m - 1000m)
        const distances = Array.from({ length: 50 }, (_, i) => i * 20);

        // 1. Hız Grafiği
        // VER viraja daha geç fren basıp daha yüksek minimum hız korur
        const verSpeed = distances.map(d => {
            if (d < 200) return 312 - (d * 0.05); // Düzlük
            if (d >= 200 && d < 400) return 302 - (d - 200) * 1.1; // Fren
            if (d >= 400 && d < 600) return 82 + (d - 400) * 0.45; // Apeks çıkışı
            return 172 + (d - 600) * 0.35; // Eau Rouge öncesi
        });
        const hamSpeed = distances.map(d => {
            if (d < 180) return 308 - (d * 0.04);
            if (d >= 180 && d < 380) return 300 - (d - 180) * 1.12;
            if (d >= 380 && d < 580) return 76 + (d - 380) * 0.46;
            return 168 + (d - 580) * 0.34;
        });

        const sCtx = document.getElementById("speed-comparison-chart").getContext("2d");
        speedChart = new Chart(sCtx, {
            type: 'line',
            data: {
                labels: distances,
                datasets: [
                    { label: 'Sürücü A (VER)', data: verSpeed, borderColor: 'var(--accent-red)', borderWidth: 2, pointRadius: 0, tension: 0.1 },
                    { label: 'Sürücü B (HAM)', data: hamSpeed, borderColor: 'var(--accent-blue)', borderWidth: 2, pointRadius: 0, tension: 0.1 }
                ]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: { ...commonOptions.scales.y, title: { display: true, text: 'Hız (km/h)', color: 'var(--text-secondary)' } }
                }
            }
        });

        // 2. G-Force Grafiği (Yanal G)
        const verG = distances.map(d => {
            if (d < 200) return 0.2;
            if (d >= 200 && d < 450) return 3.8 * Math.sin((d - 200) / 250 * Math.PI);
            return 0.5 + Math.sin(d/100) * 0.8;
        });
        const hamG = distances.map(d => {
            if (d < 180) return 0.15;
            if (d >= 180 && d < 430) return 3.4 * Math.sin((d - 180) / 250 * Math.PI);
            return 0.45 + Math.sin(d/100) * 0.75;
        });

        const gCtx = document.getElementById("gforce-comparison-chart").getContext("2d");
        gforceChart = new Chart(gCtx, {
            type: 'line',
            data: {
                labels: distances,
                datasets: [
                    { label: 'VER Yanal G', data: verG, borderColor: 'rgba(255, 59, 48, 0.85)', borderWidth: 2, pointRadius: 0 },
                    { label: 'HAM Yanal G', data: hamG, borderColor: 'rgba(0, 122, 255, 0.85)', borderWidth: 2, pointRadius: 0 }
                ]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: { ...commonOptions.scales.y, title: { display: true, text: 'İvme (G)', color: 'var(--text-secondary)' } }
                }
            }
        });

        // 3. Pedallar Grafiği
        const verThrottle = distances.map(d => {
            if (d < 200) return 100;
            if (d >= 200 && d < 360) return 0;
            if (d >= 360 && d < 500) return (d - 360) * 0.71;
            return 100;
        });
        const verBrake = distances.map(d => {
            if (d < 200) return 0;
            if (d >= 200 && d < 320) return 100 - (d - 200) * 0.8;
            return 0;
        });

        const pCtx = document.getElementById("pedals-comparison-chart").getContext("2d");
        pedalsChart = new Chart(pCtx, {
            type: 'line',
            data: {
                labels: distances,
                datasets: [
                    { label: 'VER Gaz %', data: verThrottle, borderColor: 'rgba(52, 199, 89, 0.85)', borderWidth: 1.5, pointRadius: 0, fill: false },
                    { label: 'VER Fren %', data: verBrake, borderColor: 'rgba(255, 59, 48, 0.85)', borderWidth: 1.5, pointRadius: 0, fill: false }
                ]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: { ...commonOptions.scales.y, min: 0, max: 100, title: { display: true, text: 'Giriş Yüzdesi (%)', color: 'var(--text-secondary)' } }
                }
            }
        });

        // 4. Zaman Delta Grafiği (Sürücü A'nın Sürücü B'ye kıyasla kazandığı/kaybettiği zaman)
        // Artı değer VER'in önde olduğunu gösterir
        const delta = distances.map(d => {
            if (d < 200) return 0.05 + d * 0.0001;
            if (d >= 200 && d < 450) return 0.07 + (d - 200) * 0.0008; // Viraj girişinde VER zaman kazanır
            return 0.27 - (d - 450) * 0.0002; // Düzlükte HAM hafifçe yaklaşır
        });

        const dCtx = document.getElementById("delta-comparison-chart").getContext("2d");
        deltaChart = new Chart(dCtx, {
            type: 'line',
            data: {
                labels: distances,
                datasets: [
                    { label: 'Zaman Deltası (VER vs HAM)', data: delta, borderColor: 'var(--accent-yellow)', borderWidth: 2, pointRadius: 0, fill: true, backgroundColor: 'rgba(255, 204, 0, 0.05)' }
                ]
            },
            options: {
                ...commonOptions,
                scales: {
                    ...commonOptions.scales,
                    y: { ...commonOptions.scales.y, title: { display: true, text: 'Zaman Farkı (Saniye)', color: 'var(--text-secondary)' } }
                }
            }
        });
    }

    // --------------------------------------------------------------------------
    // PYTHON KOD KOPYALAMA İŞLEVİ
    // --------------------------------------------------------------------------
    const copyCodeBtn = document.getElementById("copy-code-btn");
    const codeContent = document.getElementById("python-code-content");

    copyCodeBtn.addEventListener("click", () => {
        navigator.clipboard.writeText(codeContent.textContent)
            .then(() => {
                copyCodeBtn.textContent = "✓ Kopyalandı!";
                copyCodeBtn.className = "btn primary badge-green";
                setTimeout(() => {
                    copyCodeBtn.textContent = "Kodu Kopyala";
                    copyCodeBtn.className = "btn primary";
                }, 2000);
            })
            .catch(err => {
                alert("Kod kopyalanamadı: " + err);
            });
    });
});
