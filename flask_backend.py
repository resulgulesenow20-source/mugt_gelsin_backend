from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os
import sys
import requests
import threading
import urllib.parse
from datetime import datetime, timezone

# --- CONFIGURATION ---
RENDER_URL = "https://mugt-gelsin-backend.onrender.com"
# ---------------------

# Prevent UnicodeEncodeError on Windows consoles when printing Turkish characters
sys.stdout.reconfigure(encoding='utf-8')

app = Flask(__name__, static_folder='static')
CORS(app)

# Ensure static/uploads exists
UPLOAD_FOLDER = os.path.join(app.root_path, 'static', 'uploads')
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

SUPPORT_FILE = 'support_messages.json'

# Support messages storage initialization
if not os.path.exists(SUPPORT_FILE):
    with open(SUPPORT_FILE, 'w', encoding='utf-8') as f:
        json.dump({}, f)

def load_support_messages():
    try:
        with open(SUPPORT_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except:
        return {}

def save_support_messages(data):
    with open(SUPPORT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

# Tüm kaynaklara ve metodlara izin veriyoruz
CORS(app, resources={r"/*": {"origins": "*"}}) 

@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "Dosya bulunamadı"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "Dosya adı boş"}), 400
        
    if file:
        filename = file.filename
        # Dosya adını güvenli hale getirebiliriz ama şimdilik orijinali kullanıyoruz
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)
        
        # Mobil uygulamanın erişebileceği relative path
        relative_path = f"static/uploads/{filename}"
        return jsonify({
            "success": True, 
            "url": relative_path,
            "full_url": f"https://mugt-gelsin-backend.onrender.com/{relative_path}"
        })

# Dükkan verilerinin saklanacağı klasör
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SHOPS_DIR = os.path.join(SCRIPT_DIR, "shops")

# Eğer 'shops' klasörü yoksa oluştur
if not os.path.exists(SHOPS_DIR):
    os.makedirs(SHOPS_DIR)

def get_shop_file(shop_id):
    return os.path.join(SHOPS_DIR, f"{shop_id}.json")

def load_shop_data(shop_id):
    """Belirli bir dükkanın verilerini yükler"""
    file_path = get_shop_file(shop_id)
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return None

@app.route('/', methods=['GET'])
def health_check():
    # Kaç dükkan kayıtlı olduğunu sayalım
    shop_files = [f for f in os.listdir(SHOPS_DIR) if f.endswith('.json')]
    return {
        "status": "online",
        "message": "Mugt_Gelsin Çoklu Dükkan Sistemi Aktif",
        "registered_shops": len(shop_files)
    }

@app.route('/api/restaurants/<shop_id>', methods=['GET', 'DELETE'])
def handle_restaurant(shop_id):
    """Dükkan detaylarını getirir (GET) veya dükkanı tamamen siler (DELETE)"""
    file_path = get_shop_file(shop_id)
    
    if request.method == 'DELETE':
        print(f">>> {shop_id} dükkanı siliniyor...")
        if os.path.exists(file_path):
            os.remove(file_path)
            invalidate_cache()
            return jsonify({"success": True, "message": "Dükkan bulut verileri silindi"})
        return jsonify({"error": "Dükkan bulunamadı"}), 404

    # GET Metodu
    print(f">>> {shop_id} dükkan detayı isteniyor...")
    data = load_shop_data(shop_id)
    if not data:
        return jsonify({"error": "Dükkan bulunamadı"}), 404
    
    return jsonify(data)

# --- CACHING MECHANISM ---
_restaurant_cache = None
_cache_lock = threading.Lock()

def invalidate_cache():
    global _restaurant_cache
    with _cache_lock:
        _restaurant_cache = None
        print(">>> Cache invalidated.")

@app.route('/api/restaurants', methods=['GET'])
def get_restaurants():
    """Tüm dükkanların özet listesini döner (Önbellekli)"""
    global _restaurant_cache
    
    with _cache_lock:
        if _restaurant_cache is not None:
            return jsonify(_restaurant_cache)

    print(">>> Cache miss: Tüm dükkanlar diskten okunuyor...")
    restaurants = []
    
    # Shops klasöründeki her .json dosyasını oku
    for filename in os.listdir(SHOPS_DIR):
        if filename.endswith(".json"):
            shop_id = filename.replace(".json", "")
            data = load_shop_data(shop_id)
            if data and data.get("status", "waiting") == "active":
                # Özet bilgi (Liste için)
                restaurants.append({
                    "id": shop_id,
                    "name": data.get("name", "İsimsiz Dükkan"),
                    "imageUrl": data.get("imageUrl", "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500"),
                    "rating": data.get("rating", "0.0"),
                    "deliveryTime": data.get("deliveryTime", "30-40 dk"),
                    "category": data.get("category", "Genel"),
                    "status": data.get("status", "active"),
                    "minOrderAmount": data.get("minOrderAmount", 50.0),
                    "menu": data.get("menu", [])
                })
    
    with _cache_lock:
        _restaurant_cache = restaurants
                
    return jsonify(restaurants)

@app.route('/api/status/<shop_id>', methods=['GET'])
def get_shop_status(shop_id):
    """Dükkanın onay durumunu sorgular (Firestore öncelikli)"""
    print(f">>> {shop_id} için durum sorgulanıyor...")
    
    # 1. Önce yerel veriye bak (Eğer zaten aktifse hızlıca dön)
    local_data = load_shop_data(shop_id)
    if local_data and local_data.get("status") == "active":
        return jsonify({"status": "active"})
        
    # 2. Yerelde aktif değilse veya dosya yoksa EN GÜNCEL Firestore verisine bak
    import requests
    import urllib.parse
    collections = ["Restoranlar", "restaurants"]
    
    for coll in collections:
        safe_shop_id = urllib.parse.quote(shop_id)
        url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/{coll}/{safe_shop_id}"
        try:
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200:
                doc = resp.json()
                fields = doc.get("fields", {})
                
                # 'Durum' veya 'status' alanını kontrol et
                val = ""
                if "Durum" in fields:
                    val = fields.get("Durum", {}).get("stringValue", "")
                elif "status" in fields:
                    val = fields.get("status", {}).get("stringValue", "")
                
                # Onaylanmışsa yerel dosyayı da güncelle
                if val.strip().lower() in ["aktif", "active"]:
                    if local_data:
                        local_data["status"] = "active"
                        file_path = get_shop_file(shop_id)
                        with open(file_path, "w", encoding="utf-8") as f:
                            json.dump(local_data, f, ensure_ascii=False, indent=2)
                    return jsonify({"status": "active"})
                
                return jsonify({"status": "waiting"})
        except Exception as e:
            print(f">>> Firestore status check error ({coll}): {e}")
            
    # Hiçbir yerde bulunamadıysa 'waiting' dön (Kayıt yeni yapılmış olabilir)
    return jsonify({"status": "waiting"})

@app.route('/api/profile/<shop_id>', methods=['POST'])
def update_profile(shop_id):
    """Masaüstü uygulamasından gelen dükkan profil güncellemelerini alır"""
    profile_data = request.json
    print(f">>> {shop_id} için profil güncellemesi geldi: {profile_data.get('name')}")
    
    if not profile_data:
        return jsonify({"error": "Profil verisi bulunamadı"}), 400
        
    data = load_shop_data(shop_id)
    if not data:
        data = {"id": shop_id, "menu": [], "reviews": [], "pending_orders": []}
        
    # Güncellenecek alanları aktar
    if "name" in profile_data: data["name"] = profile_data["name"]
    if "imageUrl" in profile_data: data["imageUrl"] = profile_data["imageUrl"]
    if "phone" in profile_data: data["phone"] = profile_data["phone"]
    if "address" in profile_data: data["address"] = profile_data["address"]
    
    if "minOrderAmount" in profile_data:
        try:
            data["minOrderAmount"] = float(profile_data["minOrderAmount"])
        except (ValueError, TypeError):
            data["minOrderAmount"] = data.get("minOrderAmount", 50.0)
            
    if "deliveryTime" in profile_data: data["deliveryTime"] = profile_data["deliveryTime"]
    
    # Varsayılan olarak aktif yap (Onay sürecini otomatiğe bağlamak için)
    # Varsayılan olarak onay bekliyor yap (Kullanıcı isteği: form -> onay -> açılış)
    data["status"] = profile_data.get("status", data.get("status", "waiting"))
    
    # Dosyayı güncelle ve önbelleği temizle
    file_path = get_shop_file(shop_id)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    invalidate_cache()
        
    # Firestore Senkronizasyonu (Arka planda çalıştır - THREADING)
    threading.Thread(target=sync_shop_to_firestore, args=(shop_id, data), daemon=True).start()
        
    return jsonify({"success": True})

def to_firestore_value(val):
    """Python verisini Firestore REST API formatına dönüştürür"""
    if val is None:
        return {"nullValue": None}
    if isinstance(val, bool):
        return {"booleanValue": val}
    if isinstance(val, (int, float)):
        return {"doubleValue": float(val)}
    if isinstance(val, str):
        return {"stringValue": val}
    if isinstance(val, list):
        return {"arrayValue": {"values": [to_firestore_value(v) for v in val]}}
    if isinstance(val, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in val.items()}}}
    return {"stringValue": str(val)}

def sync_shop_to_firestore(shop_id, shop_data):
    """Dükkan verilerini Firestore'a (Bulut) doğrudan yansıtır"""
    try:
        if shop_id == "None" or not shop_id:
            print(">>> Hata: Geçersiz shop_id (None). Senkronizasyon iptal edildi.")
            return

        # 1. Profil ve Durum Senkronizasyonu (Restoranlar koleksiyonu)
        from datetime import datetime
        now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        firestore_payload = {
            "fields": {
                "id": {"stringValue": str(shop_id)},
                "name": {"stringValue": shop_data.get("name", "Mugt Dükkan")},
                "phone": {"stringValue": shop_data.get("phone", str(shop_id))},
                "address": {"stringValue": shop_data.get("address", "")},
                "imageUrl": {"stringValue": shop_data.get("imageUrl", "")},
                "minOrderAmount": {"doubleValue": float(shop_data.get("minOrderAmount", 50.0))},
                "status": {"stringValue": shop_data.get("status", "active")},
                "updatedAt": {"stringValue": now_str},
                "menu": to_firestore_value(shop_data.get("menu", []))
            }
        }
        
        # Firestore REST API (Projeye özel: mugt-gelsin)
        api_url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Restoranlar/{shop_id}"
        
        # Alanları güncelleme maskesi (ASCII karakterler kullanılmalı)
        params = {
            "updateMask.fieldPaths": ["name", "phone", "address", "imageUrl", "minOrderAmount", "status", "updatedAt", "id", "menu"]
        }
        
        print(f">>> Firestore'a Yazılıyor: {api_url}")
        resp = requests.patch(api_url, params=params, json=firestore_payload, timeout=10)
        
        if resp.status_code == 200:
            print(f">>> Başarılı: {shop_id} Firestore'a yazıldı.")
        else:
            print(f">>> Firestore Hatası ({resp.status_code}): {resp.text}")

        # 2. Menü Senkronizasyonu (Ayrı koleksiyon olarak - Yedek)
        if "menu" in shop_data and shop_data["menu"]:
            menu_url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Menuler/{shop_id}"
            menu_payload = {
                "fields": {
                    "items": to_firestore_value(shop_data["menu"]),
                    "lastUpdate": {"stringValue": now_str}
                }
            }
            # Maske ekle
            menu_params = {"updateMask.fieldPaths": ["items", "lastUpdate"]}
            requests.patch(menu_url, params=menu_params, json=menu_payload, timeout=10)
            
    except Exception as e:
        # Removed the specific "Kritik Hata" print line as requested.
        pass

@app.route('/api/orders', methods=['POST'])
def place_order():
    """Mobil uygulamadan sipariş alır"""
    order_data = request.json
    shop_id = order_data.get("shop_id")
    shop_name = order_data.get("shop_name", f"Otomatik Dükkan ({shop_id})")
    
    print(f">>> {shop_id} ({shop_name}) için yeni sipariş geldi!")
    
    if not shop_id:
        return jsonify({"error": "shop_id gerekli"}), 400
        
    data = load_shop_data(shop_id)
    if not data:
        print(f"!!! {shop_id} dükkanı bulunamadı, otomatik oluşturuluyor...")
        data = {
            "id": shop_id,
            "name": shop_name,
            "imageUrl": "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500",
            "rating": "4.0",
            "deliveryTime": "30-45 dk",
            "category": "Genel",
            "status": "active",
            "menu": [],
            "reviews": [],
            "pending_orders": []
        }
        
    # Siparişleri dükkan dosyasında 'pending_orders' altında tutalım
    if "pending_orders" not in data:
        data["pending_orders"] = []
    
    # Siparişe bir ID ve zaman damgası ekleyelim
    import time
    order_data["id"] = int(time.time() * 1000)
    order_data["created_at_api"] = time.strftime('%Y-%m-%d %H:%M:%S')
    
    data["pending_orders"].append(order_data)
    
    # Dosyayı güncelle
    file_path = get_shop_file(shop_id)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    return jsonify({"success": True, "order_id": order_data["id"]})

@app.route('/api/orders/<shop_id>', methods=['GET'])
def get_pending_orders(shop_id):
    """Masaüstü uygulamasının yeni siparişleri çekmesi için"""
    data = load_shop_data(shop_id)
    if not data:
        return jsonify({"error": "Dükkan bulunamadı"}), 404
        
    all_orders = data.get("pending_orders", [])
    # Sadece henüz çekilmemiş (yeni) olanları filtreleyelim
    pending = [o for o in all_orders if not o.get("api_read", False)]
    
    # Çekilenleri 'okundu' olarak işaretle
    for o in all_orders:
        if not o.get("api_read", False):
            o["api_read"] = True
    
    data["pending_orders"] = all_orders
    
    file_path = get_shop_file(shop_id)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    return jsonify(pending)

# TEST İÇİN: İlk dükkanı oluşturma yardımcı ucu (Eğer dosya yoksa)
@app.route('/api/setup-test', methods=['POST'])
def setup_test():
    shop_id = "python_admin_1"
    file_path = get_shop_file(shop_id)
    
    test_data = {
        "id": shop_id,
        "name": "Dükkan 1 (Python Admin)",
        "imageUrl": "https://images.unsplash.com/photo-1551632811-561732d1e306?w=500",
        "rating": "5.0",
        "deliveryTime": "0-5 dk",
        "category": "Admin",
        "menu": [
            {"name": "🍔 Özel Burger", "description": "Acılı sos ile", "price": 245.0, "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400"},
            {"name": "🍕 Karışık Pizza", "description": "Ekstra peynir", "price": 310.0, "imageUrl": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400"}
        ]
    }
    
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(test_data, f, ensure_ascii=False, indent=2)
        
    return jsonify({"success": True, "message": "Test dükkanı oluşturuldu (shops/python_admin_1.json)"})

@app.route('/api/menu/<shop_id>', methods=['POST'])
def update_menu(shop_id):
    """Masaüstü uygulamasından gelen güncel menüyü kaydeder"""
    menu_data = request.json
    print(f">>> {shop_id} için menü güncellemesi geldi!")
    
    if not menu_data or not isinstance(menu_data, list):
        return jsonify({"error": "Geçersiz menü verisi"}), 400
        
    data = load_shop_data(shop_id)
    if not data:
        # Dükkan yoksa oluştur (Opsiyonel: Veya hata dön)
        data = {"id": shop_id, "name": shop_id, "menu": [], "status": "active"}
        
    data["menu"] = menu_data
    
    # Dosyayı güncelle
    file_path = get_shop_file(shop_id)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    invalidate_cache()
    
    # Menü değişince tüm dükkanı Firestore'a senkronize et (Arka planda - THREADING)
    threading.Thread(target=sync_shop_to_firestore, args=(shop_id, data), daemon=True).start()
        
    return jsonify({"success": True, "message": "Menü başarıyla güncellendi"})

@app.route('/api/support/chats/<user_phone>', methods=['GET'])
def get_support_chats_for_shop(user_phone):
    safe_phone = urllib.parse.quote(user_phone)
    url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/chats/{safe_phone}"
    try:
        resp = requests.get(url, timeout=5)
        if resp.status_code == 200:
            d = resp.json()
            fields = d.get("fields", {})
            last_msg = fields.get("lastMessage", {}).get("stringValue", "Canlı desteğe bağlanın")
            ts = fields.get("timestamp", {}).get("timestampValue", "")
            if ts: ts = ts.replace("T", " ")[:16]
            return jsonify([{
                "userUid": user_phone,
                "userName": "Mugt Destek",
                "lastMessage": last_msg,
                "lastTimestamp": ts
            }])
    except Exception as e:
        print(f"Chats fetch error for {user_phone}: {e}")
        
    return jsonify([{
        "userUid": user_phone,
        "userName": "Mugt Destek",
        "lastMessage": "Canlı desteğe bağlanın",
        "lastTimestamp": ""
    }])

@app.route('/api/support/messages/<user_uid>', methods=['GET'])
def get_user_messages(user_uid):
    safe_uid = urllib.parse.quote(user_uid)
    url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/chats/{safe_uid}/messages"
    try:
        resp = requests.get(url, timeout=5)
        if resp.status_code == 200:
            docs = resp.json().get("documents", [])
            messages = []
            for d in docs:
                fields = d.get("fields", {})
                text = fields.get("text", {}).get("stringValue", "")
                is_admin = fields.get("isAdmin", {}).get("booleanValue", False)
                ts = fields.get("timestamp", {}).get("timestampValue", "")
                messages.append({
                    "text": text,
                    "sender": "admin" if is_admin else "user",
                    "timestamp": ts,
                    "raw_ts": ts
                })
            messages.sort(key=lambda x: x["raw_ts"])
            for m in messages:
                 if m["timestamp"]: m["timestamp"] = m["timestamp"].replace("T", " ")[:16]
            return jsonify(messages)
    except Exception as e:
        print(f"Messages fetch error: {e}")
    return jsonify([])

@app.route('/api/support/message', methods=['POST'])
def post_support_message():
    data = request.json
    user_uid = data.get("userUid")
    text = data.get("text")
    sender = data.get("sender") 
    
    shop_name = data.get("shopName", "Restoran")
    
    if not user_uid or not text or not sender:
        return jsonify({"error": "Missing data"}), 400

    now_str = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    safe_uid = urllib.parse.quote(user_uid)
    msg_url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/chats/{safe_uid}/messages"
    msg_payload = {
        "fields": {
            "text": {"stringValue": text},
            "senderId": {"stringValue": user_uid},
            "senderName": {"stringValue": shop_name},
            "isAdmin": {"booleanValue": False},
            "timestamp": {"timestampValue": now_str}
        }
    }
    requests.post(msg_url, json=msg_payload)

    patch_url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/chats/{safe_uid}?updateMask.fieldPaths=lastMessage&updateMask.fieldPaths=timestamp&updateMask.fieldPaths=unreadByAdmin&updateMask.fieldPaths=type&updateMask.fieldPaths=userName"
    patch_payload = {
        "fields": {
            "lastMessage": {"stringValue": text},
            "timestamp": {"timestampValue": now_str},
            "unreadByAdmin": {"stringValue": "1"}, # integerValue incorrect in some Firestore REST versions, stringValue safer or check version
            "type": {"stringValue": "restaurant"},
            "userName": {"stringValue": shop_name}
        }
    }
    requests.patch(patch_url, json=patch_payload)
    
    return jsonify({"success": True})

@app.route('/api/reviews/<shop_id>', methods=['GET'])
def get_reviews(shop_id):
    """Belirli bir dükkanın yorumlarını döner"""
    data = load_shop_data(shop_id)
    if not data:
        return jsonify({"error": "Dükkan bulunamadı"}), 404
    return jsonify(data.get("reviews", []))

@app.route('/api/reviews/<shop_id>', methods=['POST'])
def post_review(shop_id):
    """Müşteriden yeni yorum alır"""
    review_data = request.json
    if not review_data:
        return jsonify({"error": "Yorum verisi eksik"}), 400
        
    data = load_shop_data(shop_id)
    if not data:
        return jsonify({"error": "Dükkan bulunamadı"}), 404
        
    if "reviews" not in data:
        data["reviews"] = []
        
    # Yorum formatı: {id, customerName, rating, comment, date, reply}
    import time
    new_review = {
        "id": int(time.time() * 1000),
        "customerName": review_data.get("customerName", "Müşteri"),
        "rating": review_data.get("rating", 5),
        "comment": review_data.get("comment", ""),
        "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "reply": None
    }
    
    data["reviews"].insert(0, new_review) # En yeni en üstte
    
    file_path = get_shop_file(shop_id)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    return jsonify({"success": True, "review": new_review})

@app.route('/api/reviews/reply', methods=['POST'])
def post_review_reply():
    """Yoruma cevap yazar"""
    data_reply = request.json
    shop_id = data_reply.get("shop_id")
    review_id = data_reply.get("review_id")
    reply_text = data_reply.get("reply")
    
    if not all([shop_id, review_id, reply_text]):
        return jsonify({"error": "Eksik veri (shop_id, review_id, reply)"}), 400
        
    data = load_shop_data(shop_id)
    if not data or "reviews" not in data:
        return jsonify({"error": "Dükkan veya yorum bulunamadı"}), 404
        
    for r in data["reviews"]:
        if r["id"] == review_id:
            r["reply"] = reply_text
            r["replyDate"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            break
    else:
        return jsonify({"error": "Yorum bulunamadı"}), 404

    file_path = get_shop_file(shop_id)
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    return jsonify({"success": True})

if __name__ == '__main__':
    # Render (bulut) için dinamik port ayarı
    import os
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
