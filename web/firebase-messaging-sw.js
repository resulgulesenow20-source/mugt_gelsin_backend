importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCN9rccJKr3uDIQkCDImcqBD82fAWVE1hQ",
  authDomain: "mugt-gelsin.firebaseapp.com",
  projectId: "mugt-gelsin",
  storageBucket: "mugt-gelsin.firebasestorage.app",
  messagingSenderId: "337676615490",
  appId: "1:337676615490:web:4b9d3d4422f6884b4de64f"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Arka planda bildirim alındı ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
