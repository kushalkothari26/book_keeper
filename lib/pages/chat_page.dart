import 'package:flutter/material.dart';
import 'package:book_keeper/components/message_bubble.dart';
import 'package:book_keeper/services/message_service.dart';

class ChatPage extends StatefulWidget {
  final String docID;
  final String title;

  const ChatPage({super.key, required this.docID, required this.title});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final MessageService messageService = MessageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: messageService.getMessagesStream(widget.docID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<Map<String, dynamic>> messages = [];
                snapshot.data!.docs.forEach((document) {
                  messages.add({
                    'messageID': document.id,
                    'message': document['message'],
                    'comment':document['comment'],
                    'isRight': document['isRight'],
                    'timestamp': document['timestamp'],
                  });
                });

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      docID: widget.docID,
                      messageID: messages[index]['messageID'],
                      message: messages[index]['message'],
                      comment: messages[index]['comment'],
                      isRight: messages[index]['isRight'],
                      timestamp: messages[index]['timestamp'].toDate(),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAmountDialog(true),
                  child: const Text('You Gave'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAmountDialog(false),
                  child: const Text('You Received'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAmountDialog(bool isRight) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRight ? 'Enter Amount You Gave' : 'Enter Amount You Received'),
        content: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Add a Comment'),
            )
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              messageService.addMessage(widget.docID, _amountController.text,commentController.text,isRight);
              _amountController.clear();
              commentController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
