
# --- Settings Functions ---

def initialize_settings_defaults():
    conn = get_db_connection()
    # Check if empty
    try:
        cur = conn.execute("SELECT count(*) FROM settings")
        if cur.fetchone()[0] == 0:
            defaults = {
                "shop_name": "Paket Servis Dükkanım",
                "phone": "0555 000 0000",
                "address": "Adres Bilgisi Girilmedi",
                "theme": "light"
            }
            for k, v in defaults.items():
                conn.execute("INSERT OR IGNORE INTO settings (key, value) VALUES (?, ?)", (k, v))
            conn.commit()
    except:
        pass
    conn.close()

def get_setting(key, default=""):
    conn = get_db_connection()
    try:
        cur = conn.execute("SELECT value FROM settings WHERE key = ?", (key,))
        res = cur.fetchone()
        conn.close()
        return res[0] if res else default
    except:
        conn.close()
        return default

def update_setting(key, value):
    conn = get_db_connection()
    conn.execute("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)", (key, value))
    conn.commit()
    conn.close()

# --- Reporting Functions ---

def get_total_revenue():
    conn = get_db_connection()
    try:
        cur = conn.execute("SELECT SUM(price * quantity) FROM orders")
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

# Initialize on import
initialize_db()
