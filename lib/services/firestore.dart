import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference names = FirebaseFirestore.instance.collection('names');
  final user = FirebaseAuth.instance.currentUser;


  // operations for Customers and Suppliers
  Future<void> addContact(String name, int type, String phoneNumber) {
    if (user != null) {
      return names.add({
        'userID': user?.uid,
        'name': name,
        'type': type,
        'phoneNumber': phoneNumber,
        'totalGiven':0,
        'totalReceived':0,
        'balance':0,
        'timestamp': Timestamp.now(),
      });
    } else {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
    }
  }

  Stream<QuerySnapshot> getCustomerNamesStream() {
    final notesStream = names.where('userID', isEqualTo: user?.uid).where('type', isEqualTo: 1).orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Stream<QuerySnapshot> getSupplierNamesStream() {
    final notesStream = names.where('userID', isEqualTo: user?.uid).where('type', isEqualTo: 2).orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Future<void> updateName(String docID, String newName) {
    return names.doc(docID).update({
      'name': newName,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteContact(String docID) {
    return names.doc(docID).delete();
  }

  // operations for given, received and balance
  Future<int> getTotalGiven(String docID) async {
    DocumentSnapshot snapshot = await names.doc(docID).get();
    return snapshot['totalGiven'] ?? 0;
  }
  Future<int> getTotalReceived(String docID) async {
    DocumentSnapshot snapshot = await names.doc(docID).get();
    return snapshot['totalReceived'] ?? 0;
  }
  Future<int> getBalance(String docID) async {
    DocumentSnapshot snapshot = await names.doc(docID).get();
    return snapshot['balance'] ?? 0;
  }
  Future<void> updateTotalGiven(String docID, int newGiven) {
    return names.doc(docID).update({'totalGiven': newGiven});
  }
  Future<void> updateTotalReceived(String docID, int newReceived) {
    return names.doc(docID).update({'totalReceived': newReceived});
  }
  Future<void> updateBalance(String docID, int newBalance) {
    return names.doc(docID).update({'balance': newBalance});
  }


  // operations for phone Number
  Future<void> updatePhoneNumber(String docID, String ph) {
    return names.doc(docID).update({'phoneNumber': ph});
  }
  Future<String> getPhoneNumber(String docID) async {
    DocumentSnapshot snapshot = await names.doc(docID).get();
    return snapshot['phoneNumber'] ?? 0;
  }
}



