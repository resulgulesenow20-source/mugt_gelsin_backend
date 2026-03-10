import requests
import json

url = "https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents"
try:
    resp = requests.get(url, timeout=5)
    if resp.status_code == 200:
        docs = resp.json().get("documents", [])
        for d in docs:
            print(d["name"])
    else:
        print(resp.status_code, resp.text)
except Exception as e:
    import traceback
    traceback.print_exc()
