import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference names = FirebaseFirestore.instance.collection('names');
  final user = FirebaseAuth.instance.currentUser;

  Future<void> addNote(String name, int type) {
    if (user != null) {
      return names.add({
        'userID': user?.uid,
        'name': name,
        'type': type,
        'timestamp': Timestamp.now(),
      });
    } else {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
    }
  }

  Stream<QuerySnapshot> getCustomerNotesStream() {
    final notesStream = names.where('userID', isEqualTo: user?.uid).where('type', isEqualTo: 1).orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Stream<QuerySnapshot> getSupplierNotesStream() {
    final notesStream = names.where('userID', isEqualTo: user?.uid).where('type', isEqualTo: 2).orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Future<void> updateNote(String docID, String newNote) {
    return names.doc(docID).update({
      'name': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteNote(String docID) {
    return names.doc(docID).delete();
  }
}
