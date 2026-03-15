import requests
import json

project_id = "mugt-gelsin"
shop_id = "5528595745"
url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/Restoranlar/{shop_id}"

resp = requests.get(url)
if resp.status_code == 200:
    print(json.dumps(resp.json(), indent=2, ensure_ascii=False))
else:
    print(f"Error {resp.status_code}")
