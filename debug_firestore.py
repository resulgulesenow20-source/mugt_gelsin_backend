import requests
import json
from datetime import datetime, timezone
import sys

# Prevent Unicode errors on Windows
sys.stdout.reconfigure(encoding='utf-8')

def test_firestore_direct():
    shop_id = "test_shop_debug_v2"
    # Using project ID: mugt-gelsin
    url = f"https://firestore.googleapis.com/v1/projects/mugt-gelsin/databases/(default)/documents/restaurants/{shop_id}"
    
    now_str = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    
    payload = {
        "fields": {
            "id": {"stringValue": shop_id},
            "name": {"stringValue": "Debug Test Store"},
            "status": {"stringValue": "debug_testing"},
            "updatedAt": {"timestampValue": now_str}
        }
    }
    
    print(f"DEBUG: Sending PATCH to: {url}")
    try:
        resp = requests.patch(url, json=payload, timeout=10)
        print(f"DEBUG: Status Code: {resp.status_code}")
        print(f"DEBUG: Response Text: {resp.text}")
        
        if resp.status_code == 200:
            print("SUCCESS: Data written to Firestore!")
        else:
            print(f"FAILURE: Status {resp.status_code}")
            if "PERMISSION_DENIED" in resp.text:
                print("REASON: Permission Denied. Rules might be blocking anonymous writes.")
            elif "NOT_FOUND" in resp.text:
                print("REASON: Document or collection path not found.")
    except Exception as e:
        print(f"ERROR: Execution failed: {e}")

if __name__ == "__main__":
    test_firestore_direct()
