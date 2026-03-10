import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserName => _auth.currentUser?.displayName ?? 'Müşteri';

  // Get chat messages as a stream
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(String chatId, String text, {required String type}) async {
    if (text.trim().isEmpty) return;

    final batch = _firestore.batch();

    // 1. Update/Set Chat document
    final chatDoc = _firestore.collection('chats').doc(chatId);
    batch.set(chatDoc, {
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': currentUserId,
      'userName': currentUserName,
      'type': type, // 'customer' or 'restaurant'
      'unreadByAdmin': FieldValue.increment(1),
      'unreadByUser': 0,
    }, SetOptions(merge: true));

    // 2. Add message to sub-collection
    final messageDoc = chatDoc.collection('messages').doc();
    batch.set(messageDoc, {
      'text': text,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'timestamp': FieldValue.serverTimestamp(),
      'isAdmin': false,
    });

    await batch.commit();
  }

  // Mark messages as read by user
  Future<void> markAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadByUser': 0,
    });
  }
}
