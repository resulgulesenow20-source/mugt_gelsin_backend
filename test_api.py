import requests
import json

base_url = "https://mugt-gelsin-backend-1.onrender.com"
shop_id = "5528595745"

print(f"Testing Backend API: {base_url}/api/status/{shop_id}")
try:
    resp = requests.get(f"{base_url}/api/status/{shop_id}", timeout=10)
    print(f"Status Code: {resp.status_code}")
    print(f"Response Body: {resp.text}")
except Exception as e:
    print(f"Error: {e}")
