import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:book_keeper/services/firestore.dart';

class MessageBubble extends StatelessWidget {
  final String amount;
  final String comment;
  final bool isRight;
  final DateTime timestamp;
  final String docID;
  final String transactionID;
  final Function() update;

  MessageBubble({
    super.key,
    required this.amount,
    required this.isRight,
    required this.timestamp,
    required this.docID,
    required this.transactionID,
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
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isRight ? Colors.red : Colors.green,
                width: 2,
              ),
            ),
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹$amount",
                    style: TextStyle(
                      color: isRight ? Colors.red : Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    style: TextStyle(
                      color: isRight ? Colors.red : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(timestamp),
                    style: TextStyle(
                      color: isRight ? Colors.red : Colors.green,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
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
                  int currentAmount = int.tryParse(amount) ?? 0;
                  int totalGiven = await firestoreService.getTotalGiven(docID);
                  int totalReceived=await firestoreService.getTotalReceived(docID);
                  if (isRight) {
                    totalGiven=totalGiven-currentAmount;
                    int balance=totalReceived - totalGiven;
                    await firestoreService.updateTotalGiven(docID, totalGiven);
                    await firestoreService.updateBalance(docID, balance);
                    update();

                  } else {
                    totalReceived=totalReceived-currentAmount;
                    int balance=totalReceived - totalGiven;
                    await firestoreService.updateTotalReceived(docID, totalReceived);
                    await firestoreService.updateBalance(docID, balance);
                    update();
                  }
                  MessageService().deleteTransaction(transactionID);
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
              int totalGiven = await firestoreService.getTotalGiven(docID);
              int totalReceived=await firestoreService.getTotalReceived(docID);
              int newAmount = int.tryParse(_amountController.text) ?? 0;
              int oldAmount = int.tryParse(amount) ?? 0;
              int diff = newAmount - oldAmount;
              int balance=0;
              if (isRight) {
                totalGiven=totalGiven+diff;
                balance=totalReceived - totalGiven;
                await firestoreService.updateTotalGiven(docID, totalGiven);
                await firestoreService.updateBalance(docID, balance);
                update();

              } else {
                totalReceived=totalReceived+diff;
                balance=totalReceived - totalGiven;
                await firestoreService.updateTotalReceived(docID, totalReceived);
                await firestoreService.updateBalance(docID, balance);
                update();
              }
              MessageService()
                  .updateTransaction(transactionID, _amountController.text);
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
