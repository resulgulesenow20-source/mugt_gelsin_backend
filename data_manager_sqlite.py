import sqlite3
import os
import json
import requests
import shutil

import sys
import io

# UTF-8 handling is now centralized in main.py

# EXE'nin bulunduğu klasörü bul (PyInstaller uyumlu)
if getattr(sys, 'frozen', False):
    BASE_DIR = os.path.dirname(sys.executable)
else:
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DB_FILE = os.path.join(BASE_DIR, "restaurant.db")
# BAĞLANTI AYARLARI
PROJECT_ID = "mugt-gelsin"
BASE_URL = "https://mugt-gelsin-backend.onrender.com" 

def get_db_connection():
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def initialize_db():
    start_fresh = not os.path.exists(DB_FILE)
    conn = get_db_connection()
    c = conn.cursor()
    
    # Create Tables
    c.execute('''
        CREATE TABLE IF NOT EXISTS menu (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            icon TEXT,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            stock INTEGER DEFAULT 0,
            category TEXT DEFAULT 'Diğer'
        )
    ''')
    
    # Ensure all columns exist in menu table
    menu_columns = [row[1] for row in c.execute("PRAGMA table_info(menu)").fetchall()]
    
    if "stock" not in menu_columns:
        try: c.execute("ALTER TABLE menu ADD COLUMN stock INTEGER DEFAULT 0")
        except: pass
    if "category" not in menu_columns:
        try: c.execute("ALTER TABLE menu ADD COLUMN category TEXT DEFAULT 'Diğer'")
        except: pass
    if "image_path" not in menu_columns:
        try: c.execute("ALTER TABLE menu ADD COLUMN image_path TEXT")
        except: pass
 

    
    c.execute('''
        CREATE TABLE IF NOT EXISTS tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            status TEXT DEFAULT 'Boş'
        )
    ''')
    
    c.execute('''
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_id INTEGER, 
            customer_name TEXT,
            customer_phone TEXT,
            customer_address TEXT,
            note TEXT,
            product_name TEXT NOT NULL,
            price REAL NOT NULL,
            quantity INTEGER DEFAULT 1,
            status TEXT DEFAULT 'Hazırlanıyor',
            FOREIGN KEY (table_id) REFERENCES tables (id)
        )
    ''')

    
    c.execute('''
        CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    ''') 

    # Check if orders has firestore_id
    try:
        c.execute("SELECT firestore_id FROM orders LIMIT 1")
    except:
        try:
             c.execute("ALTER TABLE orders ADD COLUMN firestore_id TEXT")
        except:
             pass

    # Check if orders has created_at
    try:
        c.execute("SELECT created_at FROM orders LIMIT 1")
    except:
        try:
             c.execute("ALTER TABLE orders ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP")
        except:
             pass # Already exists or other error
             
    # Check if orders has payment_method
    try:
        c.execute("SELECT payment_method FROM orders LIMIT 1")
    except:
        try:
             c.execute("ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT 'Bilinmiyor'")
        except:
             pass
             
    # Check if orders has courier_name
    try:
        c.execute("SELECT courier_name FROM orders LIMIT 1")
    except:
        try:
             c.execute("ALTER TABLE orders ADD COLUMN courier_name TEXT")
        except:
             pass
    
    conn.commit()
    conn.close()
    
    # Initialize default settings if empty
    initialize_settings_defaults()

    
    if start_fresh and os.path.exists("data.json"):
        migrate_from_json()

def migrate_from_json():
    print("Migrating data from data.json...")
    try:
        with open("data.json", "r", encoding="utf-8") as f:
            data = json.load(f)
            
        conn = get_db_connection()
        c = conn.cursor()
        
        # Migrate Menu
        for item in data.get("menu_items", []):
            # item format: [icon, name, (desc), price_str]
            icon = item[0]
            name = item[1]
            price_str = item[-1]
            desc = item[2] if len(item) == 4 else ""
            
            try:
                price = float(price_str.replace(" TL", "").strip())
            except:
                price = 0.0
            
            c.execute("INSERT INTO menu (icon, name, description, price) VALUES (?, ?, ?, ?)",
                      (icon, name, desc, price))
        
        # Migrate Tables
        # Current data.json tables: [{"id": 1, "name": "Masa 1", "status": "Boş"}, ...]
        # We should clear existing tables first to avoid duplicates if re-running or just insert
        # Actually tables are usually fixed 1-10.
        for table in data.get("tables", []):
            # Check if exists
            c.execute("SELECT id FROM tables WHERE id = ?", (table["id"],))
            if not c.fetchone():
               c.execute("INSERT INTO tables (id, name, status) VALUES (?, ?, ?)", 
                         (table["id"], table["name"], table["status"]))
            else:
               c.execute("UPDATE tables SET status = ? WHERE id = ?", (table["status"], table["id"]))

        # Migrate Orders
        # table_orders: {"1": [{"product": "...", "price": 100, "quantity": 1, "status": "..."}, ...]}
        table_orders = data.get("table_orders", {})
        for table_id_str, orders in table_orders.items():
            table_id = int(table_id_str)
            for order in orders:
                status = order.get("status", "Hazırlanıyor")
                c.execute('''
                    INSERT INTO orders (table_id, product_name, price, quantity, status) 
                    VALUES (?, ?, ?, ?, ?)
                ''', (table_id, order["product"], order["price"], order["quantity"], status))
        
        conn.commit()
        conn.close()
        print("Migration successful.")
        
    except Exception as e:
        print(f"Migration failed: {e}")

# --- Helper Functions for UI ---

def get_menu_items():
    conn = get_db_connection()
    items = conn.execute("SELECT * FROM menu").fetchall()
    conn.close()
    # Convert to list format expected by UI for now or return objects
    # Old UI expected list: [icon, name, desc, price_str]
    # We will adapt UI to use objects or dicts, but for quick refactor let's return list of dicts or tuples
    # Let's return objects (rows) and adapt UI to receive cleaner data
    return [dict(ix) for ix in items]

def _process_image(local_path):
    """Resmi Flask sunucusuna yükler ve dönen yolu (static/uploads/...) döner"""
    if not local_path or not os.path.exists(local_path):
        return None
        
    # Eğer zaten bir URL ise (http...) veya relative path ise (static/...) dokunma
    if local_path.startswith("http") or local_path.startswith("static/"):
        return local_path

    try:
        API_URL = f"{BASE_URL}/api/upload"
        with open(local_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(API_URL, files=files, timeout=5)
            
        if response.status_code == 200:
            result = response.json()
            print(f">>> Resim yüklendi: {result.get('url')}")
            return result.get('url')
        else:
            print(f">>> Resim yükleme hatası ({response.status_code}): {response.text}")
    except Exception as e:
        print(f">>> Resim yükleme sırasında hata oluştu: {e}")
            
    # Hata durumunda original yolu dönmek yerine null veya placeholder dönebiliriz
    # Ama mevcut sistemi bozmamak için null dönüyoruz
    return None

def add_menu_item(shop_id, icon, name, description, price, stock=0, category="Diğer", image_path=None):
    processed_path = _process_image(image_path)
    conn = get_db_connection()
    conn.execute("INSERT INTO menu (icon, name, description, price, stock, category, image_path) VALUES (?, ?, ?, ?, ?, ?, ?)",
                 (icon, name, description, price, stock, category, processed_path))
    conn.commit()
    conn.close()
    # Senkronize et
    sync_menu_to_remote(shop_id)

def update_menu_item(shop_id, item_id, icon, name, description, price, stock=0, category="Diğer", image_path=None):
    processed_path = _process_image(image_path)
    conn = get_db_connection()
    conn.execute("UPDATE menu SET icon = ?, name = ?, description = ?, price = ?, stock = ?, category = ?, image_path = ? WHERE id = ?",
                 (icon, name, description, price, stock, category, processed_path, item_id))
    conn.commit()
    conn.close()
    # Senkronize et
    sync_menu_to_remote(shop_id)

def delete_menu_item(shop_id, item_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM menu WHERE id = ?", (item_id,))
    conn.commit()
    conn.close()
    # Senkronize et
    sync_menu_to_remote(shop_id)

def sync_menu_to_remote(shop_id):
    """Yerel menüyü Flask sunucusuna gönderir (Dinamik Shop ID ile)"""
    def task():
        try:
            items = get_menu_items()
            remote_menu = []
            updated_locally = False
            
            for item in items:
                img_path = item.get("image_path")
                
                # OTOMATİK GÖÇ: Eğer hala yerel (C:/...) bir yol ise sunucuya yükle
                if img_path and (":/" in img_path or ":\\" in img_path) and os.path.exists(img_path):
                    print(f">>> Göç ediliyor: {img_path}")
                    new_path = _process_image(img_path)
                    if new_path:
                        # Yerel DB'yi güncelle
                        conn = get_db_connection()
                        conn.execute("UPDATE menu SET image_path = ? WHERE id = ?", (new_path, item["id"]))
                        conn.commit()
                        conn.close()
                        img_path = new_path
                        updated_locally = True

                # API'nin beklediği format
                # image_path artık 'static/uploads/name.png' formatında olmalı
                image_url = img_path if img_path else "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400"

                remote_menu.append({
                    "name": item["name"],
                    "icon": item["icon"],
                    "description": item["description"],
                    "price": item["price"],
                    "category": item["category"],
                    "imageUrl": image_url
                })
            
            API_URL = f"{BASE_URL}/api/menu/{shop_id}"
            print(f">>> Menu Sync: {API_URL} gönderiliyor... ({len(remote_menu)} ürün)")
            response = requests.post(API_URL, json=remote_menu, timeout=8)
            if response.status_code == 200:
                print(f">>> Başarılı: Menü buluta iletildi ({shop_id})")
            else:
                print(f">>> Hata: Menü senkronize edilemedi ({response.status_code})")
                
        except Exception as e:
            print(f">>> Senkronizasyon hatası: {e}")

    import threading
    threading.Thread(target=task, daemon=True).start()

def sync_profile_to_remote(shop_id):
    """Yerel dükkan profil ayarlarını Flask sunucusuna gönderir (Dinamik Shop ID ile)"""
    def task():
        try:
            shop_name = get_setting("shop_name", "Mugt Gelsin")
            phone = get_setting("phone", "")
            address = get_setting("address", "")
            logo_path = get_setting("shop_logo_path", "")
            min_order = get_setting("min_order_amount", "50.0")
            
            # Resmi sunucuya yükle veya URL olarak ayarla
            processed_logo = _process_image(logo_path)
            image_url = processed_logo if processed_logo else "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500"
            
            profile_payload = {
                "name": shop_name,
                "phone": phone,
                "address": address,
                "imageUrl": image_url,
                "minOrderAmount": float(min_order) if min_order.replace('.','',1).isdigit() else 50.0,
                "deliveryTime": get_setting("avg_delivery_time", "20 dk")
            }
            
            API_URL = f"{BASE_URL}/api/profile/{shop_id}"
            print(f">>> Profile Sync: {API_URL} gönderiliyor...")
            response = requests.post(API_URL, json=profile_payload, timeout=8)
            
            if response.status_code == 200:
                print(f">>> Başarılı: Profil buluta iletildi ({shop_id})")
            else:
                print(f">>> Hata: Profil senkronize edilemedi ({response.status_code})")
                
        except Exception as e:
            print(f">>> Profil senkronizasyonunda hata: {e}")

    import threading
    threading.Thread(target=task, daemon=True).start()

def check_shop_status(shop_id):
    """Backend üzerinden dükkanın onay durumunu sorgular"""
    try:
        API_URL = f"{BASE_URL}/api/status/{shop_id}"
        import requests
        resp = requests.get(API_URL, timeout=5)
        if resp.status_code == 200:
            return resp.json().get("status", "unknown")
        return "unknown"
    except Exception as e:
        print(f"Check status error: {e}")
        return "error"

def check_stock(item_id):
    conn = get_db_connection()
    cur = conn.execute("SELECT stock FROM menu WHERE id = ?", (item_id,))
    res = cur.fetchone()
    conn.close()
    return res[0] if res else 0

def decrease_stock(item_id, quantity):
    conn = get_db_connection()
    cur = conn.execute("SELECT stock FROM menu WHERE id = ?", (item_id,))
    row = cur.fetchone()
    if row:
        current = row[0]
        new_stock = max(0, current - quantity)
        conn.execute("UPDATE menu SET stock = ? WHERE id = ?", (new_stock, item_id))
    conn.commit()
    conn.close()



def get_tables():
    conn = get_db_connection()
    tables = conn.execute("SELECT * FROM tables").fetchall()
    conn.close()
    # Ensure standard 10 tables if empty (fallback logic)
    if not tables:
        initialize_tables_default()
        return get_tables()
    return [dict(t) for t in tables]

def initialize_tables_default():
    conn = get_db_connection()
    for i in range(1, 11):
        conn.execute("INSERT INTO tables (id, name, status) VALUES (?, ?, ?)", (i, f"Masa {i}", "Boş"))
    conn.commit()
    conn.close()

def add_table():
    conn = get_db_connection()
    # Find next max ID
    cur = conn.execute("SELECT MAX(id) FROM tables")
    max_id = cur.fetchone()[0]
    new_id = (max_id or 0) + 1
    conn.execute("INSERT INTO tables (id, name, status) VALUES (?, ?, ?)", (new_id, f"Masa {new_id}", "Boş"))
    conn.commit()
    conn.close()

def delete_table(table_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM tables WHERE id = ?", (table_id,))
    # Also delete orders for this table?
    conn.execute("DELETE FROM orders WHERE table_id = ?", (table_id,))
    conn.commit()
    conn.close()

def get_table_orders(table_id):
    conn = get_db_connection()
    orders = conn.execute("SELECT * FROM orders WHERE table_id = ?", (table_id,)).fetchall()
    conn.close()
    return [dict(o) for o in orders]

def get_all_active_orders_grouped():
    """Returns a dictionary {table_id: [orders...]} for active tables"""
    conn = get_db_connection()
    # Get all orders that are NOT Tamamlandı
    orders = conn.execute("SELECT * FROM orders WHERE status != 'Tamamlandı'").fetchall()
    conn.close()
    
    grouped = {}
    for o in orders:
        o_dict = dict(o)
        tid = o_dict["table_id"]
        if tid not in grouped:
            grouped[tid] = []
        grouped[tid].append(o_dict)
    return grouped

def add_order_item(table_id, product_name, price, quantity=1, status="Hazırlanıyor", customer_name="", customer_phone="", customer_address="", note="", firestore_id=None, payment_method="Bilinmiyor", courier_name=None):
    conn = get_db_connection()
    # If table_id is provided, it groups by that (which can be a ticket number now)
    # Check if we should merge with existing item? Only if pure product add.
    # But for simplicity, let's just insert new line for now or keep merging if same table/ticket.
    
    # Check match only on product + status + table_id (ticket)
    cur = conn.execute("SELECT id, quantity FROM orders WHERE table_id = ? AND product_name = ? AND status = ? AND customer_phone = ?", 
                       (table_id, product_name, status, customer_phone))
    existing = cur.fetchone()
    
    if existing:
        new_qty = existing["quantity"] + quantity
        conn.execute("UPDATE orders SET quantity = ? WHERE id = ?", (new_qty, existing["id"]))
    else:
        conn.execute('''INSERT INTO orders 
                     (table_id, product_name, price, quantity, status, customer_name, customer_phone, customer_address, note, firestore_id, payment_method, courier_name) 
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                     (table_id, product_name, price, quantity, status, customer_name, customer_phone, customer_address, note, firestore_id, payment_method, courier_name))
    
    # We don't need to update 'tables' table status anymore if we are moving away from it, 
    # but to keep backward compatibility or dashboard count working:
    # If table_id is small int (1-10), it might be a real table. If it's big, it's a ticket.
    # For now, let's verify if tables table exists and has this id.
    try:
         conn.execute("UPDATE tables SET status = 'Dolu' WHERE (status = 'Boş' OR status IS NULL) AND id = ?", (table_id,))
    except:
         pass # Ignore if table_id is not in tables table (e.g. huge random number)
    
    conn.commit()
    conn.close()


def update_order_status(order_id, new_status, courier_name=None):
    conn = get_db_connection()
    # Önce firestore_id'yi alalım
    cur = conn.execute("SELECT firestore_id FROM orders WHERE id = ?", (order_id,))
    row = cur.fetchone()
    firestore_id = row[0] if row else None
    
    if courier_name:
        conn.execute("UPDATE orders SET status = ?, courier_name = ? WHERE id = ?", (new_status, courier_name, order_id))
    else:
        conn.execute("UPDATE orders SET status = ? WHERE id = ?", (new_status, order_id))
    
    # Eğer bu bir Firebase siparişi ise (firestore_id varsa) Firestore'u da güncelle
    if firestore_id:
        update_firestore_status(firestore_id, new_status, courier_name)
        
    conn.commit()
    conn.close()

def update_firestore_status(firestore_id, status, courier_name=None):
    """Firestore REST API kullanarak sipariş durumunu günceller"""
    PROJECT_ID = "mugt-gelsin" 
    
    # Flutter uygulamasının beklediği durum isimlerine eşleyelim
    status_map = {
        "Hazırlanıyor": "hazırlanıyor",
        "Yola Çıktı": "yolda",
        "Teslim Edildi": "teslim edildi"
    }
    target_status = status_map.get(status, status.lower())
    
    payload = {
        "fields": {
            "status": {"stringValue": target_status}
        }
    }
    
    if courier_name:
        payload["fields"]["courier_name"] = {"stringValue": courier_name}
        URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/Emirler/{firestore_id}?updateMask.fieldPaths=status&updateMask.fieldPaths=courier_name"
    else:
        URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/Emirler/{firestore_id}?updateMask.fieldPaths=status"
    
    try:
        # Patch metodu ile güncelliyoruz
        res = requests.patch(URL, json=payload, timeout=5)
        if res.status_code == 200:
            print(f"Firestore status updated: {firestore_id} -> {target_status}")
        else:
            print(f"Firestore update failed: {res.status_code} - {res.text}")
    except Exception as e:
        print(f"Firestore update error: {e}")

def delete_order_item(order_id):
    conn = get_db_connection()
    conn.execute("DELETE FROM orders WHERE id = ?", (order_id,))
    conn.commit()
    conn.close()
    # If no orders left for table, set status to Boş? 
    # Logic: Check if any orders remain for this table.
    # We need table_id first. (Optimizable but distinct step for now)

def close_table_account(table_id):
    conn = get_db_connection()
    
    # Get firestore_ids before updating status
    cur = conn.execute("SELECT DISTINCT firestore_id FROM orders WHERE table_id = ? AND firestore_id IS NOT NULL", (table_id,))
    firestore_ids = [row[0] for row in cur.fetchall()]
    
    # Mark as Tamamlandı instead of deleting
    conn.execute("UPDATE orders SET status = 'Tamamlandı' WHERE table_id = ?", (table_id,))
    conn.execute("UPDATE tables SET status = 'Boş' WHERE id = ?", (table_id,))
    conn.commit()
    conn.close()
    
    # Sync with Firestore
    for fid in firestore_ids:
        update_firestore_status(fid, "Teslim Edildi")

def get_order_history():
    """Returns all completed orders grouped by table_id/ticket"""
    conn = get_db_connection()
    # Fetch orders with status 'Tamamlandı', ordered by creation time descending
    orders = conn.execute("SELECT * FROM orders WHERE status = 'Tamamlandı' ORDER BY created_at DESC").fetchall()
    conn.close()
    
    # We want to group them by table_id (ticket) but since table_id can be reused, 
    # we should ideally group by a session/order group ID. 
    # For now, we'll group by table_id AND created_at (roughly) or just show them as a list.
    # Actually, grouping by customer info + table_id + created_at would be safer.
    
    # Let's keep it simple: return list of dicts.
    return [dict(o) for o in orders]

def fetch_remote_orders(shop_id):
    """API'den yeni gelen siparişleri çeker (Dinamik Shop ID ile)"""
    # Dükkan durumu kontrolü
    if get_setting("shop_status", "AÇIK") == "KAPALI":
        return False

    API_URL = f"{BASE_URL}/api/orders/{shop_id}"
    
    try:
        response = requests.get(API_URL, timeout=5)
        if response.status_code == 200:
            new_orders = response.json()
            if not new_orders:
                return False # Yeni sipariş yok
                
            # Gelen siparişleri yerel veritabanına ekle
            import time
            for remote_order in new_orders:
                # Ticket ID oluştur (API'den gelen ID'yi kullanabiliriz veya yeni bir tane)
                ticket_id = remote_order.get("id", int(time.time() * 1000) % 1000000)
                
                customer_name = remote_order.get("customerName", remote_order.get("customer_name", "Mobil Müşteri"))
                customer_phone = remote_order.get("customerPhone", remote_order.get("customer_phone", ""))
                customer_address = remote_order.get("deliveryAddress", remote_order.get("customer_address", "Mobil Sipariş"))
                note = remote_order.get("note", "")
                firestore_id = remote_order.get("firestore_id") # Flutter'dan gelen ID
                payment_method = remote_order.get("paymentMethod", "Bilinmiyor") # Kapıda Nakit, vb.
                
                # Menü kalemlerini ekle
                items = remote_order.get("items", [])
                for item in items:
                    add_order_item(
                        table_id=ticket_id,
                        product_name=item.get("name", "Bilinmeyen Ürün"),
                        price=item.get("price", 0.0),
                        quantity=item.get("quantity", 1),
                        status="Hazırlanıyor",
                        customer_name=customer_name,
                        customer_phone=customer_phone,
                        customer_address=customer_address,
                        note=note,
                        firestore_id=firestore_id,
                        payment_method=payment_method
                    )
            return True # Yeni siparişler başarıyla eklendi
    except Exception as e:
        print(f"Sipariş çekme hatası: {e}")
    
    return False

def get_daily_revenue():
    """Bugünkü toplam ciroyu hesaplar"""
    conn = get_db_connection()
    try:
        cur = conn.execute("SELECT SUM(price * quantity) FROM orders WHERE date(created_at) = date('now')")
        res = cur.fetchone()[0]
        conn.close()
        return res if res else 0.0
    except:
        conn.close()
        return 0.0

def get_recent_orders(limit=5):
    """En son verilen siparişleri getirir"""
    conn = get_db_connection()
    conn.row_factory = sqlite3.Row
    try:
        cur = conn.execute("""
            SELECT o.*, MAX(o.created_at) as last_activity 
            FROM orders o 
            GROUP BY o.table_id 
            ORDER BY last_activity DESC 
            LIMIT ?
        """, (limit,))
        rows = cur.fetchall()
        conn.close()
        return [dict(r) for r in rows]
    except Exception as e:
        print(f"Recent orders error: {e}")
        conn.close()
        return []







# --- Settings Functions ---

def initialize_settings_defaults():
    conn = get_db_connection()
    # Check if empty
    try:
        cur = conn.execute("SELECT count(*) FROM settings")
        if cur.fetchone()[0] == 0:
            defaults = {
                "shop_name": "Mugt Gelsin",
                "phone": "",
                "address": "",
                "theme": "light",
                "is_profile_setup": "0",
                "min_order_amount": "50.0",
                "couriers": "Ahmet,Mehmet,Ayhan"
            }
            for k, v in defaults.items():
                conn.execute("INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)", (k, v))
            conn.commit()
        else:
            # Sadece couriers kolonunu ekleyelim eğer yoksa (eski veri güncellemesi için)
            conn.execute("INSERT OR IGNORE INTO settings (key, value) VALUES ('couriers', 'Ahmet,Mehmet,Ayhan')")
            conn.commit()
    except:
        pass
    conn.close()

def get_last_login():
    """Son başarılı giriş yapılan telefon numarasını döner"""
    return get_setting("last_login_phone", None)

def set_last_login(phone):
    """Giriş yapılan telefon numarasını kaydeder (Otomatik giriş için)"""
    update_setting("last_login_phone", phone)

def clear_last_login():
    """Çıkış yapıldığında kayıtlı telefonu siler"""
    update_setting("last_login_phone", None)

_settings_cache = {}

def get_setting(key, default=""):
    global _settings_cache
    if key in _settings_cache:
        return _settings_cache[key]
        
    conn = get_db_connection()
    cur = conn.execute("SELECT value FROM settings WHERE key = ?", (key,))
    row = cur.fetchone()
    val = row[0] if row else default
    _settings_cache[key] = val
    return val

def update_setting(key, value):
    global _settings_cache
    _settings_cache[key] = value
    conn = get_db_connection()
    conn.execute("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)", (key, str(value)))
    conn.commit()
    conn.close()

def delete_account(shop_id):
    """Hem yerel veritabanını temizler hem de bulut verilerini siler"""
    try:
        # 1. Bulut verilerini sil (Backend API)
        API_URL = f"{BASE_URL}/api/restaurants/{shop_id}"
        resp = requests.delete(API_URL, timeout=5)
        
        # 2. Yerel Veritabanını Temizle
        conn = get_db_connection()
        c = conn.cursor()
        
        # Tüm tabloları boşalt
        c.execute("DELETE FROM orders")
        c.execute("DELETE FROM menu")
        c.execute("DELETE FROM tables")
        c.execute("DELETE FROM settings")
        
        # Cache'i temizle
        global _settings_cache
        _settings_cache = {}
        
        conn.commit()
        conn.close()
        
        # Varsayılan ayarları tekrar yükle
        initialize_settings_defaults()
        
        return True
    except Exception as e:
        print(f"Delete account error: {e}")
        return False


# --- Reporting Functions ---

def get_total_revenue():
    conn = get_db_connection()
    try:
        # Sum both active and completed orders
        cur = conn.execute("SELECT SUM(price * quantity) FROM orders")
        res = cur.fetchone()[0]
        conn.close()
        return res if res else 0.0
    except:
        conn.close()
        return 0.0

def get_pending_revenue():
    conn = get_db_connection()
    try:
        # Only sum NOT Tamamlandı
        cur = conn.execute("SELECT SUM(price * quantity) FROM orders WHERE status != 'Tamamlandı'")
        res = cur.fetchone()[0]
        conn.close()
        return res if res else 0.0
    except:
        conn.close()
        return 0.0


def get_total_orders_count():
    conn = get_db_connection()
    try:
        cur = conn.execute("SELECT COUNT(DISTINCT table_id) FROM orders")
        res = cur.fetchone()[0]
        conn.close()
        return res if res else 0
    except:
        conn.close()
        return 0

def get_weekly_sales_data():
    conn = get_db_connection()
    query = '''
        SELECT strftime('%Y-%m-%d', created_at) as day, SUM(price * quantity) as daily_total
        FROM orders 
        WHERE created_at IS NOT NULL
        GROUP BY day
        ORDER BY day DESC
        LIMIT 7
    '''
    try:
        cur = conn.execute(query)
        rows = cur.fetchall()
    except:
        rows = []
    conn.close()
    
    data_map = {row[0]: row[1] for row in rows}
    return data_map

def get_top_products(limit=5):
    conn = get_db_connection()
    query = '''
        SELECT product_name, SUM(quantity) as total_qty
        FROM orders
        GROUP BY product_name
        ORDER BY total_qty DESC
        LIMIT ?
    '''
    try:
        cur = conn.execute(query, (limit,))
        rows = cur.fetchall()
        conn.close()
        return [(r[0], r[1]) for r in rows]
    except:
        conn.close()
        return []

def get_today_courier_stats():
    """Bugün teslim edilen veya tamamlanan siparişlerin ciro ve sayı bilgilerini kuryeye ve ödeme yöntemine göre gruplar"""
    conn = get_db_connection()
    try:
        cur = conn.execute("""
            SELECT COALESCE(courier_name, 'Atanmadı') as courier_name, payment_method, SUM(price * quantity) as total_amount, COUNT(DISTINCT table_id) as package_count
            FROM orders 
            WHERE (status = 'Teslim Edildi' OR status = 'Tamamlandı') 
              AND date(created_at) = date('now')
            GROUP BY courier_name, payment_method
        """)
        rows = cur.fetchall()
        conn.close()
        
        # stats yapısı: {
        #   "global": {"kapida_nakit": 0, "kapida_kart": 0, "online_kart": 0, "total_packages": 0},
        #   "couriers": {
        #        "Ahmet": {"kapida_nakit": 0, "kapida_kart": 0, "online_kart": 0, "total_packages": 0}
        #   }
        # }
        stats = {
            "global": {
                "kapida_nakit": 0.0,
                "kapida_kart": 0.0,
                "online_kart": 0.0,
                "total_packages": 0
            },
            "couriers": {}
        }
        
        # Package count'ları tablo başına grupladığımız için, kurye başına benzersiz sayıyı 
        # bulmak adına ufak bir workaround (çünkü aynı siparişteki kalemler aynı kuryededir genelde).
        # Şimdilik direkt satırdan package_count'u toplayıp globale ekliyoruz ancak global packages
        # tekilleştirilmiş olması için farklı bir sorgu veya set mantığı gerekir. 
        # Fakat GROUP BY courier_name, table_id, payment_method'dan count çekmek yerine
        # mevcut yapı üzerinden ilerleyelim, sadece toplama yapsak yeter.
        
        for r in rows:
            c_name = r['courier_name']
            pm = r['payment_method']
            amount = r['total_amount']
            pkgs = r['package_count']
            
            if c_name not in stats["couriers"]:
                stats["couriers"][c_name] = {"kapida_nakit": 0.0, "kapida_kart": 0.0, "online_kart": 0.0, "total_packages": 0}
                
            stats["couriers"][c_name]["total_packages"] += pkgs
            stats["global"]["total_packages"] += pkgs
            
            # Global ve Kurye bazlı eklemeler
            if pm == "kapida_nakit":
                stats["global"]["kapida_nakit"] += amount
                stats["couriers"][c_name]["kapida_nakit"] += amount
            elif pm == "kapida_kart":
                stats["global"]["kapida_kart"] += amount
                stats["couriers"][c_name]["kapida_kart"] += amount
            elif pm == "online_kart":
                stats["global"]["online_kart"] += amount
                stats["couriers"][c_name]["online_kart"] += amount
            else:
                stats["global"]["kapida_nakit"] += amount
                stats["couriers"][c_name]["kapida_nakit"] += amount
                
        return stats
    except Exception as e:
        print(f"Stats error: {e}")
        conn.close()
        return {"kapida_nakit": 0.0, "kapida_kart": 0.0, "online_kart": 0.0, "total_packages": 0}

def get_today_delivered_packages():
    """Bugün teslim edilen siparişlerin listesini döner"""
    conn = get_db_connection()
    conn.row_factory = sqlite3.Row
    try:
        cur = conn.execute("""
            SELECT table_id, MAX(created_at) as order_time, customer_name, customer_address, 
                   payment_method, courier_name, SUM(price * quantity) as total_amount
            FROM orders 
            WHERE (status = 'Teslim Edildi' OR status = 'Tamamlandı') 
              AND date(created_at) = date('now')
            GROUP BY table_id
            ORDER BY order_time DESC
        """)
        rows = cur.fetchall()
        conn.close()
        return [dict(r) for r in rows]
    except Exception as e:
        print(f"Delivered packages error: {e}")
        conn.close()
        return []

# Initialize on import
initialize_db()
