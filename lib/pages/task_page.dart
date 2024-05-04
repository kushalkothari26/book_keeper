import 'package:book_keeper/components/my_textfield.dart';
import 'package:book_keeper/services/task_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final TextEditingController _titleController = TextEditingController();
  final TaskService taskService=TaskService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks'),backgroundColor: Colors.transparent,foregroundColor: Theme.of(context).colorScheme.primary,),
      body: StreamBuilder<QuerySnapshot>(
        stream: taskService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List tasks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = tasks[index];
              String taskID = document.id;
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String title = data['task'];
              DateTime dateTime = (data['dateTime'] as Timestamp).toDate();
              bool isDone = data['isDone'];

              String formattedDate = DateFormat("d MMMM''yy hh:mm a").format(dateTime);
              return Dismissible(
                key: Key(taskID),
                background: Container(color: Colors.red),
                direction: DismissDirection.endToStart,
                onDismissed:(_){
                  taskService.deleteTask(taskID);
                },

                child: Stack(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: ListTile(
                        leading: Checkbox(
                          value: isDone,
                          onChanged: (value) {
                            taskService.updateIsDone(value!,taskID);
                          },
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            decoration: isDone ? TextDecoration.lineThrough : null,

                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                        ),
                        tileColor: Theme.of(context).colorScheme.surface,
                        onLongPress: ()async{
                          final cTask=await taskService.getTask(taskID);
                          newTaskBox(taskID: taskID,cTask:cTask);
                          },
                      ),
                    ),
                    if (isDone)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            taskService.deleteTask(taskID);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newTaskBox,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }

  void newTaskBox({String? taskID,String? cTask}) {
    if (taskID == null) {
      _titleController.clear();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Task'),
          content: MyTextField(
            controller: _titleController,
            input: TextInputType.text,
            obscureText: false,
            hintText: 'Task',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                _titleController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                taskService.addTask(_titleController.text,false);
                _titleController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _titleController.text=cTask!;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Task'),
          content: MyTextField(
            controller: _titleController,
            obscureText: false,
            hintText: 'Task',
            input: TextInputType.text,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                _titleController.clear();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Edit'),
              onPressed: () {
                taskService.updateTask(_titleController.text,taskID);
                _titleController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}
