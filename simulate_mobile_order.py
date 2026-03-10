import requests
import json

def simulate_order():
    url = "http://localhost:5000/api/orders"
    
    order = {
        "shop_id": "python_admin_1",
        "customer_name": "Ahmet Yılmaz",
        "customer_phone": "0555 123 4567",
        "customer_address": "Atatürk Mah. Karanfil Sok. No:5",
        "note": "Zil çalmasın lütfen.",
        "items": [
            {"name": "🍔 Özel Burger", "price": 245.0, "quantity": 2},
            {"name": "🥤 Kola", "price": 45.0, "quantity": 2}
        ]
    }
    
    try:
        response = requests.post(url, json=order)
        if response.status_code == 200:
            print("Sipariş başarıyla gönderildi!")
            print("Yanıt:", response.json())
        else:
            print("Hata oluştu:", response.status_code)
            print(response.text)
    except Exception as e:
        print("Bağlantı hatası:", e)

if __name__ == "__main__":
    simulate_order()
