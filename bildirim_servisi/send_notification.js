const admin = require("firebase-admin");

// 1. ADIM: İndirdiğiniz serviceAccountKey.json dosyasını bu klasöre (bildirim_servisi) kopyalayın
// ve adını 'serviceAccountKey.json' olarak değiştirdiğinizden emin olun.
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// 2. ADIM: Bildirim göndermek istediğiniz kullanıcının FCM Token'ını buraya yapıştırın.
// Kullanıcının token'ını Firebase veritabanınızdan (Firestore'daki 'users' koleksiyonundaki 'fcmToken' alanından) bulabilirsiniz.
const targetFcmToken = "BURAYA_KULLANICI_TOKEN_GELECEK";

const message = {
  notification: {
    title: 'Mugut Gelsin',
    body: 'Siparişiniz yola çıktı, kuryemiz adresinize yaklaşıyor!'
  },
  // Arka planda / kilit ekranında çalışması için ek ayarlar
  android: {
    priority: 'high',
    notification: {
      sound: 'default'
    }
  },
  apns: {
    payload: {
      aps: {
        sound: 'default'
      }
    }
  },
  token: targetFcmToken
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Bildirim başarıyla gönderildi:', response);
  })
  .catch((error) => {
    console.log('Bildirim gönderilirken hata oluştu:', error);
  });
