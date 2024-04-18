import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:book_keeper/services/firestore.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String comment;
  final bool isRight;
  final DateTime timestamp;
  final String docID;
  final String messageID;
  final Function() update;

  MessageBubble({
    super.key,
    required this.message,
    required this.isRight,
    required this.timestamp,
    required this.docID,
    required this.messageID,
    required this.comment,
    required this.update
  });

  final TextEditingController _amountController = TextEditingController();
  final FirestoreService firestoreService= FirestoreService();

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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _showAmountDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      // SizedBox(width: 10),
                      Text('Update', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async{
                  int amount = int.tryParse(message) ?? 0;
                  int totalGiven = await firestoreService.gettotalGiven(docID);
                  int totalReceived=await firestoreService.gettotalReceived(docID);
                  if (isRight) {
                    totalGiven=totalGiven-amount;
                    int balance=totalReceived - totalGiven;
                    await firestoreService.updatetotalGiven(docID, totalGiven);
                    await firestoreService.updateBalance(docID, balance);
                    update();

                  } else {
                    totalReceived=totalReceived-amount;
                    int balance=totalReceived - totalGiven;
                    await firestoreService.updatetotalReceived(docID, totalReceived);
                    await firestoreService.updateBalance(docID, balance);
                    update();
                  }

                  MessageService().deleteMessage(docID, messageID);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      // SizedBox(width: 5),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
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
            onPressed: () async{
              int totalGiven = await firestoreService.gettotalGiven(docID);
              int totalReceived=await firestoreService.gettotalReceived(docID);
              int newAmount = int.tryParse(_amountController.text) ?? 0;
              int oldAmount = int.tryParse(message) ?? 0;
              int diff = newAmount - oldAmount;
              int balance=0;
              if (isRight) {
                totalGiven=totalGiven+diff;
                balance=totalReceived - totalGiven;
                await firestoreService.updatetotalGiven(docID, totalGiven);
                await firestoreService.updateBalance(docID, balance);
                update();

              } else {
                totalReceived=totalReceived+diff;
                balance=totalReceived - totalGiven;
                await firestoreService.updatetotalReceived(docID, totalReceived);
                await firestoreService.updateBalance(docID, balance);
                update();
              }
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
