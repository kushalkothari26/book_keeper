import 'package:flutter/material.dart';
import 'package:book_keeper/components/message_bubble.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:book_keeper/services/firestore.dart';


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
  final FirestoreService firestoreService=FirestoreService();
  int totalGiven = 0;
  int totalReceived = 0;
  int balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }
  void update(int newBalance,int newtotalgiven,int newtotalreceived) {
    setState(() {
      balance = newBalance;
      totalGiven=newtotalgiven;
      totalReceived=newtotalreceived;
    });
  }
  Future<void> _loadBalance() async {
    try {
      int fetchedtotalgiven = await firestoreService.gettotalGiven(widget.docID);
      int fetchedtotalreceived=await firestoreService.gettotalReceived(widget.docID);
      int Balance=await firestoreService.getBalance(widget.docID);
      setState(() {
        totalGiven = fetchedtotalgiven;
        totalReceived=fetchedtotalreceived;
        balance=Balance;
      });
    } catch (e) {
      print('Failed to load balance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String balanceText = balance >= 0 ? 'You Owe: $balance' : 'Owes you: ${balance.abs()}';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} | $balanceText'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
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
                      'comment': document['comment'],
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
                        update: _loadBalance,
                      );

                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAmountDialog(true),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Text('You Gave', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAmountDialog(false),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      ),
                      child: const Text('You Received', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAmountDialog(bool isRight) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRight ? 'Enter Amount You Gave' : 'Enter Amount You Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              int amount = int.tryParse(_amountController.text) ?? 0;
              if (isRight) {
                totalGiven += amount;
                balance = totalReceived - totalGiven;
                _updateBalance();
              } else {
                totalReceived += amount;
                balance = totalReceived - totalGiven;
                _updateBalance();
              }
              messageService.addMessage(widget.docID, amount.toString(), commentController.text, isRight);
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

  Future<void> _updateBalance() async {
    await firestoreService.updatetotalReceived(widget.docID, totalReceived);
    await firestoreService.updatetotalGiven(widget.docID, totalGiven);
    await firestoreService.updateBalance(widget.docID, balance);
    setState(() {
      balance=balance;
      totalReceived=totalReceived;
      totalGiven=totalGiven;
    });
  }
}
