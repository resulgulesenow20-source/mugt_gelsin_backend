import requests
import json
import urllib.parse

shop_id = "5528595745"
project_id = "mugt-gelsin"
collections = ["Restoranlar", "restaurants"]

for coll in collections:
    safe_id = urllib.parse.quote(shop_id)
    url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/{coll}/{safe_id}"
    print(f"\nChecking {coll} via URL: {url}")
    resp = requests.get(url)
    if resp.status_code == 200:
        data = resp.json()
        print(f"FOUND in {coll}!")
        fields = data.get("fields", {})
        for k, v in fields.items():
            val = v.get("stringValue", v.get("doubleValue", v.get("mapValue", "OTHER")))
            print(f"  Field '{k}': {repr(val)}")
    else:
        print(f"NOT FOUND in {coll} (Status: {resp.status_code})")
