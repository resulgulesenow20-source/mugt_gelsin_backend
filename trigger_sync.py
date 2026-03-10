import requests
import json
import os

def trigger_sync():
    shop_id = "5528595745"
    file_path = f"shops/{shop_id}.json"
    
    if not os.path.exists(file_path):
        print(f"ERROR: {file_path} not found.")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    url = f"http://localhost:5000/api/profile/{shop_id}"
    print(f"Triggering sync for {shop_id} via {url}...")
    
    try:
        resp = requests.post(url, json=data, timeout=10)
        print(f"Status: {resp.status_code}")
        print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    trigger_sync()
