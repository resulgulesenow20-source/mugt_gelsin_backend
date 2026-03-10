import requests
try:
    res = requests.post('http://127.0.0.1:5000/api/orders', json={'shop_id': 'python_admin_1'})
    print("STATUS", res.status_code)
    print("TEXT", res.text.encode('utf-8'))
except Exception as e:
    print(e)
