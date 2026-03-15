import requests
import json

project_id = "mugt-gelsin"
url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/Restoranlar"

print(f"Listing all documents in Restoranlar...")
resp = requests.get(url)
if resp.status_code == 200:
    data = resp.json()
    documents = data.get("documents", [])
    print(f"Found {len(documents)} documents.")
    for doc in documents:
        name = doc.get("name").split("/")[-1]
        fields = doc.get("fields", {})
        display_name = fields.get("name", {}).get("stringValue", fields.get("İsim", {}).get("stringValue", "N/A"))
        print(f"- ID: {repr(name)} | Name: {display_name}")
else:
    print(f"Error {resp.status_code}: {resp.text}")
