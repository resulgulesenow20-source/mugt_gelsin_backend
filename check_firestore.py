import requests
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

def check_shop_in_firestore(shop_id):
    url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/restaurants/{shop_id}"
    
    print(f"DEBUG: Checking Firestore for: {url}")
    try:
        resp = requests.get(url, timeout=10)
        print(f"DEBUG: Status Code: {resp.status_code}")
        
        if resp.status_code == 200:
            doc = resp.json()
            fields = doc.get("fields", {})
            name = fields.get("name", {}).get("stringValue", "N/A")
            status = fields.get("status", {}).get("stringValue", "N/A")
            print(f"SUCCESS: Shop '{name}' found with status '{status}'!")
        else:
            print(f"FAILURE: Shop not found or error {resp.status_code}")
            print(resp.text)
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    check_shop_in_firestore("5528595745")
