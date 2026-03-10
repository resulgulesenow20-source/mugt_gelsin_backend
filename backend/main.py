from flask import Flask, jsonify, request
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore, storage
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin SDK
# For Cloud Run, use Default Application Credentials (ADC)
# For local testing, use the service account file
if os.path.exists('service_account.json'):
    cred = credentials.Certificate('service_account.json')
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'mugt-gelsin.appspot.com'
    })
else:
    firebase_admin.initialize_app()

db = firestore.client()
bucket = storage.bucket()

@app.route('/', methods=['GET'])
def health_check():
    return {
        "status": "online",
        "message": "Mugt Gelsin Production Backend (Cloud Ready)",
        "timestamp": datetime.now().isoformat()
    }

# --- RESTAURANTS / SHOPS ---

@app.route('/api/restaurants', methods=['GET'])
def get_restaurants():
    """Fetches all approved restaurants from Firestore"""
    shops_ref = db.collection('restaurants')
    # Filter for approved shops if needed
    # docs = shops_ref.where('status', '==', 'active').stream()
    docs = shops_ref.stream()
    
    restaurants = []
    for doc in docs:
        restaurants.append(doc.to_dict())
    return jsonify(restaurants)

@app.route('/api/restaurants/<shop_id>', methods=['GET'])
def get_restaurant_details(shop_id):
    shop_ref = db.collection('restaurants').document(shop_id)
    doc = shop_ref.get()
    if doc.exists:
        return jsonify(doc.to_dict())
    return jsonify({"error": "Dükkan bulunamadı"}), 404

# --- ORDERS ---

@app.route('/api/orders', methods=['POST'])
def place_order():
    """Receives order from mobile app and saves to Firestore"""
    order_data = request.json
    if not order_data:
        return jsonify({"error": "Sipariş verisi eksik"}), 400
    
    shop_id = order_data.get("shop_id")
    if not shop_id:
        return jsonify({"error": "shop_id gerekli"}), 400

    # Add timestamp
    order_data['timestamp'] = firestore.SERVER_TIMESTAMP
    order_data['status'] = 'pending'
    
    # Save to a global 'orders' collection
    new_order_ref = db.collection('orders').document()
    new_order_ref.set(order_data)
    
    # Also update 'unreadOrders' count for the shop
    shop_ref = db.collection('restaurants').document(shop_id)
    shop_ref.update({
        'unreadOrders': firestore.Increment(1),
        'lastOrderAt': firestore.SERVER_TIMESTAMP
    })

    return jsonify({"success": True, "order_id": new_order_ref.id})

# --- REVIEWS ---

@app.route('/api/reviews/<shop_id>', methods=['GET'])
def get_reviews(shop_id):
    reviews_ref = db.collection('restaurants').document(shop_id).collection('reviews')
    docs = reviews_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).stream()
    
    reviews = []
    for doc in docs:
        r = doc.to_dict()
        # Convert timestamp to string for JSON serialization
        if 'timestamp' in r and r['timestamp']:
            r['date'] = r['timestamp'].isoformat()
        reviews.append(r)
    return jsonify(reviews)

@app.route('/api/reviews/<shop_id>', methods=['POST'])
def post_review(shop_id):
    review_data = request.json
    if not review_data:
        return jsonify({"error": "Yorum verisi eksik"}), 400

    review_data['timestamp'] = firestore.SERVER_TIMESTAMP
    
    # Save as subcollection under restaurant
    db.collection('restaurants').document(shop_id).collection('reviews').add(review_data)
    
    return jsonify({"success": True})

# --- FILE UPLOADS (Cloud Storage) ---

@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "Dosya bulunamadı"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "Dosya adı boş"}), 400
        
    blob = bucket.blob(f"uploads/{datetime.now().timestamp()}_{file.filename}")
    blob.upload_from_file(file, content_type=file.content_type)
    blob.make_public()
    
    return jsonify({
        "success": True, 
        "url": blob.public_url
    })

if __name__ == '__main__':
    # Cloud Run assigns a port via the PORT environment variable
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
