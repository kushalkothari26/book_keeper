/* this screen represents the chat of each and every contact*/
import 'package:book_keeper/components/my_textfield.dart';
import 'package:book_keeper/pages/ind_report_page.dart';
import 'package:book_keeper/services/whatsapp_service.dart';
import 'package:decimal/decimal.dart';
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
  late ScrollController _scrollController;
  double totalGiven = 0;
  double totalReceived = 0;
  double balance = 0;
  int type=0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBalance();
  }

  void update(double newBalance,double newTotalGiven,double newTotalReceived) {
    setState(() {
      balance = newBalance;
      totalGiven=newTotalGiven;
      totalReceived=newTotalReceived;
    });
  }
  Future<void> _loadBalance() async {
    try {
      double fetchTotalGiven = await firestoreService.getTotalGiven(widget.chatID);
      double fetchTotalReceived=await firestoreService.getTotalReceived(widget.chatID);
      double fetchedBalance=await firestoreService.getBalance(widget.chatID);
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
                  fontSize: 22,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(left:12,right: 12),
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
                                      IndReportPage(chatID: widget.chatID,chatName: widget.chatName,),
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        chatID: widget.chatID,
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
                              content: const Text('Please update the phone number in your details. Make sure the number starts with the country code 91'),

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
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                        }
                      }else if(balance==0){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('No Reminder Needed'),
                            content: const Text('They don\'t owe you any money'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('No Reminder Needed'),
                            content: const Text('You owe them and not the other way around.'),
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

  Future<void> _showAmountDialog(bool gave) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gave ? 'Enter Amount You Gave' : 'Enter Amount You Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextField(
              hintText: 'Amount',
              controller: _amountController,
              obscureText: false,
              input: TextInputType.number,
            ),
            const SizedBox(height: 10,),
            MyTextField(
              hintText: 'Comment',
              obscureText: false,
              input: TextInputType.text,
              controller: commentController,
            )
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              _amountController.clear();
              commentController.clear();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () {
              Decimal amount = Decimal.tryParse(_amountController.text) ?? Decimal.zero;
              if (gave) {
                totalGiven += amount.toDouble();
              } else {
                totalReceived += amount.toDouble();
              }
              balance = (Decimal.parse(totalReceived.toString()) - Decimal.parse(totalGiven.toString())).toDouble();
              _updateBalance();
              messageService.addTransaction(widget.chatID, amount.toString(), commentController.text, gave,type,widget.chatName);
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
    await firestoreService.updateBalance(widget.chatID, double.parse(balance.toStringAsFixed(2)));
    FirestoreService().updateChatTimestamp(widget.chatID);
    setState(() {
      balance=balance;
      totalReceived=totalReceived;
      totalGiven=totalGiven;
    });
  }


  void _showUpdatePhoneNumberDialog() {
    final TextEditingController numberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: MyTextField(
          controller: numberController,
          hintText: 'Enter new phone number with 91 in front',
          obscureText: false,
          input: TextInputType.text,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await firestoreService.updatePhoneNumber(widget.chatID, numberController.text);
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