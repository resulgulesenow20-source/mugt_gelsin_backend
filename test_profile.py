import requests

try:
    url = 'http://127.0.0.1:5000/api/profile/python_admin_1'
    data = {"name": "Test Restoran 123", "phone": "555123", "address": "Test Adres"}
    res = requests.post(url, json=data)
    print("STATUS", res.status_code)
    print("TEXT", res.text.encode('utf-8'))
    
    # Verify by getting the restaurant details
    res_get = requests.get('http://127.0.0.1:5000/api/restaurants/python_admin_1')
    print("GET STATUS", res_get.status_code)
    res_data = res_get.json()
    print("NEW NAME:", res_data.get('name'))
    
except Exception as e:
    print(e)
