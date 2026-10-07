// Firebase Cloud Messaging service worker (web).
// Handles background push notifications for Flutter web.
importScripts(
  'https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyAzMiBDzyGK0GcIDaBVQk4LeKByn8vp8Dk',
  appId: '1:514037743080:web:39fa92c5bb1d9ad025f85d',
  messagingSenderId: '514037743080',
  projectId: 'everqpid-2601a',
  authDomain: 'everqpid-2601a.firebaseapp.com',
  storageBucket: 'everqpid-2601a.firebasestorage.app',
  measurementId: 'G-P9X3TZHREE',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  const notification = message.notification || {};
  self.registration.showNotification(notification.title || 'EverQpid', {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
    data: message.data || {},
  });
});
