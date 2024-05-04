
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final CollectionReference tasks = FirebaseFirestore.instance.collection('tasks');
  final user = FirebaseAuth.instance.currentUser;

  Future<void> addTask(String task,bool isDone){
    if(user!=null){
      return tasks.add({
        'userID': user?.uid,
        'task': task,
        'dateTime': Timestamp.now(),
        'isDone': isDone,
      });
    }else{
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
    }
  }
  Stream<QuerySnapshot> getTasksStream() {
    final tasksStream = tasks.where('userID', isEqualTo: user?.uid).orderBy('dateTime', descending: true).snapshots();
    return tasksStream;
  }

  Future<void> updateTask(String task,String id) async {
    await tasks.doc(id).update({
      'task': task,
      'dateTime': Timestamp.now(),
      'isDone': false,
    });
  }
  Future<void> updateIsDone(bool isDone,String id) async {
    await tasks.doc(id).update({
      'isDone': isDone,
    });
  }

  Future<String> getTask(String taskID) async {
    DocumentSnapshot snapshot = await tasks.doc(taskID).get();
    return snapshot['task'];
  }

  Future<void> deleteTask(String taskId){
    return tasks.doc(taskId).delete();
  }
}
