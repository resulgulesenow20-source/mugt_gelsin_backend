import requests
import json

shop_id = "5542221111"
url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/Restoranlar/{shop_id}"

print(f"Checking Firestore for {shop_id}...")
resp = requests.get(url)
if resp.status_code == 200:
    data = resp.json()
    print("\n--- FIRESTORE DATA ---")
    print(json.dumps(data, indent=2, ensure_ascii=False))
else:
    print(f"Error {resp.status_code}: {resp.text}")
