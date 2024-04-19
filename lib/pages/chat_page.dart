import 'package:book_keeper/services/whatsapp_service.dart';
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
  void update(int newBalance,int newTotalGiven,int newTotalReceived) {
    setState(() {
      balance = newBalance;
      totalGiven=newTotalGiven;
      totalReceived=newTotalReceived;
    });
  }
  Future<void> _loadBalance() async {
    try {
      int fetchTotalGiven = await firestoreService.getTotalGiven(widget.docID);
      int fetchTotalReceived=await firestoreService.getTotalReceived(widget.docID);
      int fetchedBalance=await firestoreService.getBalance(widget.docID);
      setState(() {
        totalGiven = fetchTotalGiven;
        totalReceived=fetchTotalReceived;
        balance=fetchedBalance;
      });
    } catch (e) {
      SnackBar(content: Text('Failed to load balance: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    String balanceText = balance >= 0 ? 'You Owe: $balance' : 'Owes you: ${balance.abs()}';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} | $balanceText',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.tertiary, Theme.of(context).colorScheme.onTertiary],
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
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
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
                  ElevatedButton(
                    onPressed: () async {
                      if (balance<0) {
                        String phoneNumber = await firestoreService.getPhoneNumber(widget.docID);
                        if ({phoneNumber}.isNotEmpty && phoneNumber!="" && (phoneNumber.length==12 || phoneNumber.length==10)) {
                          String reminderMessage =
                              "Hi there, just a friendly reminder that you owe us ₹$balance. Please let us know if you need any assistance. Thank you!";
                          String link = ""; // Add the link here if needed
                          await share(reminderMessage, link, phoneNumber);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Phone Number Error!!!'),
                              content: const Text('Please update the phone number in your details. Make sure the number starts with 91'),

                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showUpdatePhoneNumberDialog();
                                  },
                                  child: const Text('Update'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('No Reminder Needed'),
                            content: const Text('The total given is not greater than the total received.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text('Send Reminder', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
    await firestoreService.updateTotalReceived(widget.docID, totalReceived);
    await firestoreService.updateTotalGiven(widget.docID, totalGiven);
    await firestoreService.updateBalance(widget.docID, balance);
    setState(() {
      balance=balance;
      totalReceived=totalReceived;
      totalGiven=totalGiven;
    });
  }


  void _showUpdatePhoneNumberDialog() {
    String newPhoneNumber = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: TextField(
          onChanged: (value) => newPhoneNumber = value,
          decoration: const InputDecoration(
            hintText: 'Enter new phone number with 91 in front',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // Update the phone number in the database
              await firestoreService.updatePhoneNumber(widget.docID, newPhoneNumber);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


