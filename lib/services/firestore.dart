import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final user = FirebaseAuth.instance.currentUser;


  // operations for Customers and Suppliers
  Future<void> addContact(String chatName, int type, String phoneNumber) {
    if (user != null) {
      return chats.add({
        'userID': user?.uid,
        'chatName': chatName,
        'type': type,
        'phoneNumber': phoneNumber,
        'totalGiven':0.0,
        'totalReceived':0.0,
        'balance':0.0,
        'timestamp': Timestamp.now(),
      });
    } else {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
    }
  }

  Stream<QuerySnapshot> getCustomerNamesStream() {
    final notesStream = chats.where('userID', isEqualTo: user?.uid).where('type', isEqualTo: 1).orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Stream<QuerySnapshot> getSupplierNamesStream() {
    final notesStream = chats.where('userID', isEqualTo: user?.uid).where('type', isEqualTo: 2).orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Future<void> updateChatNameAndPhoneNumber(String chatID, String newChatName, String newPhoneNumber) {
    return chats.doc(chatID).update({
      'chatName': newChatName,
      'phoneNumber':newPhoneNumber,
      'timestamp': Timestamp.now(),
    });
  }
  Future<String> getChatName(String chatID) async {
    DocumentSnapshot snapshot = await chats.doc(chatID).get();
    return snapshot['chatName'] ?? 0;
  }

  Future<void> deleteContact(String chatID) {
    return chats.doc(chatID).delete();
  }

  // operations for given, received and balance
  Future<double> getTotalGiven(String chatID) async {
    DocumentSnapshot snapshot = await chats.doc(chatID).get();
    return snapshot['totalGiven'] ?? 0;
  }
  Future<double> getTotalReceived(String chatID) async {
    DocumentSnapshot snapshot = await chats.doc(chatID).get();
    return snapshot['totalReceived'] ?? 0;
  }
  Future<double> getBalance(String chatID) async {
    DocumentSnapshot snapshot = await chats.doc(chatID).get();
    return snapshot['balance'] ?? 0;
  }
  Future<void> updateTotalGiven(String chatID, double newGiven) {
    return chats.doc(chatID).update({'totalGiven': newGiven});
  }
  Future<void> updateTotalReceived(String chatID, double newReceived) {
    return chats.doc(chatID).update({'totalReceived': newReceived});
  }
  Future<void> updateBalance(String chatID, double newBalance) {
    return chats.doc(chatID).update({'balance': newBalance});
  }


  // operations for phone Number
  Future<void> updatePhoneNumber(String chatID, String ph) {
    return chats.doc(chatID).update({'phoneNumber': ph});
  }
  Future<String> getPhoneNumber(String chatID) async {
    DocumentSnapshot snapshot = await chats.doc(chatID).get();
    return snapshot['phoneNumber'] ?? 0;
  }

  Future<int> getType(String chatID) async {
    DocumentSnapshot snapshot = await chats.doc(chatID).get();
    return snapshot['type'] ?? 0;
  }

  Future<void> updateChatTimestamp(String chatID) {
    return chats.doc(chatID).update({'timestamp': Timestamp.now()});
  }
}



