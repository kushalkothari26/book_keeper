import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final CollectionReference messagesCollection =
  FirebaseFirestore.instance.collection('messages');

  Future<void> addMessage(String docID, String message,String comment,bool isRight) {
    return messagesCollection.doc(docID).collection('messages').add({
      'message': message,
      'comment':comment,
      'timestamp': Timestamp.now(),
      'isRight': isRight,
    });
  }

  Stream<QuerySnapshot> getMessagesStream(String docID) {
    return messagesCollection
        .doc(docID)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> deleteMessage(String docID, String messageID) {
    return messagesCollection
        .doc(docID)
        .collection('messages')
        .doc(messageID)
        .delete();
  }

  Future<void> updateMessage(String docID, String messageID, String newMessage) {
    return messagesCollection
        .doc(docID)
        .collection('messages')
        .doc(messageID)
        .update({'message': newMessage});
  }
}
