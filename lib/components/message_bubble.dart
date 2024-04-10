import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_keeper/services/message_service.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String comment;
  final bool isRight;
  final DateTime timestamp;
  final String docID;
  final String messageID;

  MessageBubble({
    super.key,
    required this.message,
    required this.isRight,
    required this.timestamp,
    required this.docID,
    required this.messageID,
    required this.comment,
  });

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () => _showOptionsDialog(context),
          child: Container(
            decoration: BoxDecoration(
              color: isRight ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "₹$message",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        comment,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      )
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy HH:mm').format(timestamp),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select an option'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _showAmountDialog(context);
                },
                child: const Text('Update'),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  MessageService().deleteMessage(docID, messageID);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAmountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Updated Amount'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              MessageService()
                  .updateMessage(docID, messageID, _amountController.text);
              _amountController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
