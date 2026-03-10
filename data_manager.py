import json
import os

DATA_FILE = "data.json"

# Global Data State
menu_items = []
tables = []
table_orders = {}

def load_data():
    """data.json dosyasından verileri yükler"""
    global menu_items, tables, table_orders
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
                menu_items = data.get("menu_items", [])
                tables = data.get("tables", [])
                table_orders = data.get("table_orders", {})
                # Convert keys in table_orders back to int if they are strings (JSON keys are always strings)
                # But looking at main.py, table_id is int. JSON loads keys as strings.
                # However, in main.py, it seems it wasn't handling this explicitly?
                # Python's json.load keys are strings.
                # Let's check main.py usage: table_id is likely int.
                # If I save {1: ...}, JSON is {"1": ...}. json.load gives {"1": ...}.
                # If code expects int keys, we need to convert.
                # Let's see main.py load_data: return json.load(f).
                # It just returns it.
                # And in usage:
                # if table_id in table_orders:
                # table_id comes from tables list: {"id": i+1, ...} -> int.
                # So if table_orders has string keys, lookup with int key will fail.
                # Wait, existing main.py L12: return json.load(f).
                # L33: table_orders = app_data["table_orders"]
                # L229: if ... table["id"] in table_orders ...
                # If table["id"] is int (L123: i+1), and table_orders keys are strings (from JSON),
                # This lookup would fail in the original code too unless table_orders wasn't being saved/loaded with int keys correctly or I am overthinking.
                # Actually, JSON supports string keys only.
                # If the original code worked, maybe it wasn't saving table_orders with int keys or wasn't persisting them across sessions effectively?
                # Or maybe it was broken?
                # Let's assume keys need to be integers for the Python logic to work as intended with int IDs.
                # I will convert keys to int if possible.
                
                temp_orders = {}
                for k, v in table_orders.items():
                    try:
                        temp_orders[int(k)] = v
                    except ValueError:
                        temp_orders[k] = v
                table_orders = temp_orders

        except Exception as e:
            print(f"Veri yükleme hatası: {e}")
            menu_items = []
            tables = []
            table_orders = {}
    else:
        menu_items = []
        tables = []
        table_orders = {}
    
    return {"menu_items": menu_items, "tables": tables, "table_orders": table_orders}

def save_data():
    """Verileri data.json dosyasına kaydeder"""
    data = {
        "menu_items": menu_items,
        "tables": tables,
        "table_orders": table_orders
    }
    try:
        with open(DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Veri kaydetme hatası: {e}")

# Initialize data on import
load_data()
