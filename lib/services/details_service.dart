import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailsService {
  final CollectionReference details = FirebaseFirestore.instance.collection('details');
  final user = FirebaseAuth.instance.currentUser;

  Future<void> addDetails(String name, int phno, String bname, String address) {
    if (user != null) {
      return details.add({
        'userID': user?.uid,
        'name': name,
        'phno': phno,
        'businessname': bname,
        'address': address,
      });
    } else {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
    }
  }

  Future<Map<String, dynamic>> getDetails(String userId) async {
    try {
      final docSnapshot = await details.doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        return {
          'name': 'username',
          'phno': 1234567890,
          'businessname': 'xyzbusiness',
          'address': 'xyz',
        };
      }
    } catch (e) {
      throw 'Failed to fetch user details';
    }
  }

  Future<void> updateDetails(String userId, String name, int phno, String bname, String address) {
    return details.doc(userId).set({
      'name': name,
      'phno': phno,
      'businessname': bname,
      'address': address,
    });
  }
}
