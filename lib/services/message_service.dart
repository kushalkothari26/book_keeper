import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final CollectionReference messagesCollection =
  FirebaseFirestore.instance.collection('chats');
  final user = FirebaseAuth.instance.currentUser;
  Future<void> addMessage(String docID, String message,String comment,bool isRight,int conType) {
    return messagesCollection.doc(docID).collection('transactions').add({
      'userID': user?.uid,
      'amount': message,
      'comment':comment,
      'timestamp': Timestamp.now(),
      'isRight': isRight,
      'conType':conType
    });
  }

  Stream<QuerySnapshot> getMessagesStream(String docID) {
    return messagesCollection
        .doc(docID)
        .collection('transactions')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getMessagesWithConTypeAndDate(int conType, DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> messages = [];

    QuerySnapshot chatroomSnapshot = await messagesCollection.get();
    // print(chatroomSnapshot.docs.length);
    for (DocumentSnapshot chatroomDoc in chatroomSnapshot.docs) {

      QuerySnapshot messageSnapshot = await chatroomDoc.reference
          .collection('transactions')
          .where('userID',isEqualTo:user)
          .where('conType', isEqualTo: conType)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      for (DocumentSnapshot messageDoc in messageSnapshot.docs) {
        messages.add({
          'chatroomId': chatroomDoc.id, // ID of the chatroom containing the message
          'messageId': messageDoc.id, // ID of the message
          'amount': messageDoc['amount'], // Message content
          'comment': messageDoc['comment'], // Comment
          'timestamp': messageDoc['timestamp'], // Timestamp of the message
          'isRight': messageDoc['isRight'], // Flag indicating if the message is from the right side
          'conType': messageDoc['conType'], // Type of the name (customer/supplier)
        });
      }
    }

    return messages;
  }
  Future<void> deleteMessage(String docID, String messageID) {
    return messagesCollection
        .doc(docID)
        .collection('transactions')
        .doc(messageID)
        .delete();
  }

  Future<void> updateMessage(String docID, String messageID, String newMessage) {
    return messagesCollection
        .doc(docID)
        .collection('transactions')
        .doc(messageID)
        .update({'amount': newMessage});
  }
}
