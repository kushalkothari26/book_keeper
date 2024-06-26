import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final CollectionReference transactionsCollection = FirebaseFirestore.instance.collection('transactions');
  final user = FirebaseAuth.instance.currentUser;

  Future<void> addTransaction(String chatID, String amount,String comment,bool gave,int conType,String name) {
    return transactionsCollection.add({
      'userID': user?.uid,
      'name':name,
      'chatID':chatID,
      'amount': amount,
      'comment':comment,
      'timestamp': Timestamp.now(),
      'gave': gave,
      'conType':conType
    });
  }

  Stream<QuerySnapshot> getTransactionsStream(String chatID) {
    return transactionsCollection
        .where('chatID', isEqualTo: chatID)
        .orderBy('timestamp')
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getTransactionsWithConTypeAndDate(int conType, DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> transactions = [];
    QuerySnapshot<Object?> chatroomSnapshot = await transactionsCollection
        .where('userID', isEqualTo: user!.uid)
        .where('conType', isEqualTo: conType)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    print(chatroomSnapshot.size);
    for (DocumentSnapshot transactionDoc in chatroomSnapshot.docs) {
      transactions.add({
        'transactionId': transactionDoc.id,
        'name':transactionDoc['name'],// ID of the message
        'amount': transactionDoc['amount'], // Message content
        'comment': transactionDoc['comment'], // Comment
        'timestamp': transactionDoc['timestamp'], // Timestamp of the message
        'gave': transactionDoc['gave'], // Flag indicating if the message is from the right side
        'conType': transactionDoc['conType'], // Type of the name (customer/supplier)
      });
    }

    return transactions;
  }



  Future<List<Map<String, dynamic>>> getTransactionsWithDate(String chatID,DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> transactions = [];
    QuerySnapshot<Object?> chatroomSnapshot = await transactionsCollection
        .where('chatID', isEqualTo: chatID)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    print(chatroomSnapshot.size);
    for (DocumentSnapshot transactionDoc in chatroomSnapshot.docs) {
      transactions.add({
        'transactionId': transactionDoc.id,
        'name':transactionDoc['name'],// ID of the message
        'amount': transactionDoc['amount'], // Message content
        'comment': transactionDoc['comment'], // Comment
        'timestamp': transactionDoc['timestamp'], // Timestamp of the message
        'gave': transactionDoc['gave'], // Flag indicating if the message is from the right side
        'conType': transactionDoc['conType'], // Type of the name (customer/supplier)
      });
    }

    return transactions;
  }



  Future<void> deleteTransactions(String chatID) async {
    QuerySnapshot<Object?> chatroomSnapshot = await transactionsCollection
        .where('chatID', isEqualTo: chatID)
        .get();
    print(chatroomSnapshot.size);
    for (DocumentSnapshot transactionDoc in chatroomSnapshot.docs) {
      await transactionsCollection.doc(transactionDoc.id).delete();
    }
  }
  Future<void> updateNameInTransactions(String name,String newName) async {
    QuerySnapshot<Object?> chatroomSnapshot = await transactionsCollection
        .where('name', isEqualTo: name)
        .get();
    print(chatroomSnapshot.size);
    for (DocumentSnapshot transactionDoc in chatroomSnapshot.docs) {
      await transactionsCollection.doc(transactionDoc.id).update({'name': newName});
    }
  }

  Future<void> deleteTransaction(String transactionID) {
    return transactionsCollection
        .doc(transactionID)
        .delete();
  }

  Future<void> updateTransaction(String transactionID, String newAmount,String newComment) {
    return transactionsCollection
        .doc(transactionID)
        .update({'amount': newAmount,'comment':newComment});
  }

}
