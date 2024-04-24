import 'package:book_keeper/pages/ind_report_page.dart';
import 'package:book_keeper/services/whatsapp_service.dart';
import 'package:flutter/material.dart';
import 'package:book_keeper/components/message_bubble.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:book_keeper/services/firestore.dart';


class ChatPage extends StatefulWidget {
  final String chatID;
  final String chatName;

  const ChatPage({super.key, required this.chatID, required this.chatName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final MessageService messageService = MessageService();
  final FirestoreService firestoreService=FirestoreService();
  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int totalGiven = 0;
  int totalReceived = 0;
  int balance = 0;
  int type=0;

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
      int fetchTotalGiven = await firestoreService.getTotalGiven(widget.chatID);
      int fetchTotalReceived=await firestoreService.getTotalReceived(widget.chatID);
      int fetchedBalance=await firestoreService.getBalance(widget.chatID);
      int fetchType=await firestoreService.getType(widget.chatID);
      setState(() {
        totalGiven = fetchTotalGiven;
        totalReceived=fetchTotalReceived;
        balance=fetchedBalance;
        type=fetchType;
      });
    } catch (e) {
      SnackBar(content: Text('Failed to load balance: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    String balanceText = balance >= 0 ? 'You Owe: $balance' : 'Owes you: ${balance.abs()}';

    return Scaffold(
        appBar:AppBar(
          title: Row(
            children: [
              Text(
                widget.chatName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                Container(
                  width: 325,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Theme.of(context).colorScheme.secondary,),

                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            balanceText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(backgroundColor:  MaterialStateProperty.all<Color>(Colors.white)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IndReportPage(chatID: widget.chatID),
                                ),
                              );
                            },
                            child: const Text('View Report',),
                          ),

                        ],

                      ),
                      const SizedBox(height: 1,)
                    ],
                  ),
                ),
                const SizedBox(height: 10,)
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.onBackground, Theme.of(context).colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(

                stream: messageService.getTransactionsStream(widget.chatID),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Map<String, dynamic>> transactions = [];
                  snapshot.data!.docs.forEach((document) {
                    transactions.add({
                      'transactionID': document.id,
                      'name':widget.chatName,
                      'amount': document['amount'],
                      'comment': document['comment'],
                      'gave': document['gave'],
                      'timestamp': document['timestamp'],
                    });
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        docID: widget.chatID,
                        transactionID: transactions[index]['transactionID'],
                        amount: transactions[index]['amount'],
                        comment: transactions[index]['comment'],
                        gave: transactions[index]['gave'],
                        timestamp: transactions[index]['timestamp'].toDate(),
                        update: _loadBalance,
                      );

                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.transparent,
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
                        String phoneNumber = await firestoreService.getPhoneNumber(widget.chatID);
                        if ({phoneNumber}.isNotEmpty && phoneNumber!="" && (phoneNumber.length==12 || phoneNumber.length==10)) {
                          String reminderMessage =
                              "Hi there, just a friendly reminder that you owe us ₹${balance.abs()}. Please let us know if you need any assistance. Thank you!";
                          String link = "";
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
              messageService.addTransaction(widget.chatID, amount.toString(), commentController.text, isRight,type,widget.chatName);
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
    await firestoreService.updateTotalReceived(widget.chatID, totalReceived);
    await firestoreService.updateTotalGiven(widget.chatID, totalGiven);
    await firestoreService.updateBalance(widget.chatID, balance);
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
              await firestoreService.updatePhoneNumber(widget.chatID, newPhoneNumber);
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