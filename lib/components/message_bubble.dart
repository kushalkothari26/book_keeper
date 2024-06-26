/*this is to load the transactions in the chat*/
import 'package:book_keeper/components/my_textfield.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:book_keeper/services/firestore.dart';

class MessageBubble extends StatelessWidget {
  final String amount;
  final String comment;
  final bool gave;
  final DateTime timestamp;
  final String chatID;
  final String transactionID;
  final Function() update;

  MessageBubble({
    super.key,
    required this.amount,
    required this.gave,
    required this.timestamp,
    required this.chatID,
    required this.transactionID,
    required this.comment,
    required this.update
  });

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FirestoreService firestoreService= FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          gave ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showOptionsDialog(context),
          onLongPress: () => _showOptionsDialog(context),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: gave ? Colors.red : Colors.green,
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
                      color: gave ? Colors.red : Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    style: TextStyle(
                      color: gave ? Colors.red : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(timestamp),
                    style: TextStyle(
                      color: gave ? Colors.red : Colors.green,
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
    /*Dialog box to show update and delete options*/
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
                  Navigator.pop(context);
                  _showAmountDialog(context,amount,comment);
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
                  double currentAmount = double.tryParse(amount) ?? 0;
                  double totalGiven = await firestoreService.getTotalGiven(chatID);
                  double totalReceived=await firestoreService.getTotalReceived(chatID);
                  if (gave) {
                    totalGiven=(Decimal.parse(totalGiven.toString()) - Decimal.parse(currentAmount.toString())).toDouble();
                  } else {
                    totalReceived=(Decimal.parse(totalReceived.toString()) - Decimal.parse(currentAmount.toString())).toDouble();
                  }
                  double balance = (Decimal.parse(totalReceived.toString()) - Decimal.parse(totalGiven.toString())).toDouble();
                  await firestoreService.updateTotalGiven(chatID, totalGiven);
                  await firestoreService.updateTotalReceived(chatID, totalReceived);
                  await firestoreService.updateBalance(chatID, double.parse(balance.toStringAsFixed(2)));
                  update();
                  MessageService().deleteTransaction(transactionID);
                  FirestoreService().updateChatTimestamp(chatID);
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

  Future<void> _showAmountDialog(BuildContext context,String initialAmount,String initialComment) async {
    /*dialog box to take the new amount and new comment of the transaction*/
    _amountController.text = initialAmount;
    _commentController.text=initialComment;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Updated Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextField(
              controller: _amountController,
              input: TextInputType.number,
              hintText:'Amount',
              obscureText:false
            ),
            const SizedBox(height: 10,),
            MyTextField(
              hintText: 'Comment',
              obscureText: false,
              input: TextInputType.text,
              controller: _commentController,
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              _amountController.clear();
              _commentController.clear();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () async{
              double totalGiven = await firestoreService.getTotalGiven(chatID);
              double totalReceived=await firestoreService.getTotalReceived(chatID);
              double newAmount = double.tryParse(_amountController.text) ?? 0;
              double oldAmount = double.tryParse(amount) ?? 0;
              double diff =(Decimal.parse(newAmount.toString()) - Decimal.parse(oldAmount.toString())).toDouble();
              double balance=0;
              if (gave) {
                totalGiven=(Decimal.parse(totalGiven.toString()) + Decimal.parse(diff.toString())).toDouble();
              } else {
                totalReceived=(Decimal.parse(totalReceived.toString()) + Decimal.parse(diff.toString())).toDouble();
              }
              balance = (Decimal.parse(totalReceived.toString()) - Decimal.parse(totalGiven.toString())).toDouble();
              await firestoreService.updateTotalGiven(chatID, totalGiven);
              await firestoreService.updateTotalReceived(chatID, totalReceived);
              await firestoreService.updateBalance(chatID, double.parse(balance.toStringAsFixed(2)));
              update();
              FirestoreService().updateChatTimestamp(chatID);
              MessageService().updateTransaction(transactionID, _amountController.text,_commentController.text);
              _amountController.clear();
              _commentController.clear();

              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
