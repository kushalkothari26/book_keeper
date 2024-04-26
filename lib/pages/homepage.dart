import 'package:book_keeper/pages/ind_report_page.dart';
import 'package:book_keeper/pages/report_page.dart';
import 'package:book_keeper/services/pushnot_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:book_keeper/components/my_drawer.dart';
import 'package:book_keeper/components/my_textfield.dart';
import 'package:book_keeper/pages/chat_page.dart';
import 'package:book_keeper/services/firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  final MessageService messageService=MessageService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  int _selectedValue = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void newNameBox({String? chatID,String? cn,String? cphno}) {
    if (chatID == null) {
      textController.clear();
      numberController.clear();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(hintText: 'Enter Name', obscureText: false, controller: textController,input: TextInputType.text,),
              const SizedBox(height: 10,),
              MyTextField(hintText: 'Enter Phone Number', obscureText: false, controller: numberController,input: TextInputType.text,),
              RadioListTile(
                title: const Text('Customer'),
                value: 1,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value as int;
                  });
                  Navigator.pop(context);
                  newNameBox(chatID: chatID);
                },
              ),
              RadioListTile(
                title: const Text('Supplier'),
                value: 2,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value as int;
                  });
                  Navigator.pop(context);
                  newNameBox(chatID: chatID);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (chatID == null) {
                  firestoreService.addContact(textController.text, _selectedValue, numberController.text);
                }
                textController.clear();
                numberController.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        textController.text=cn!;
        numberController.text=cphno!;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(
                input: TextInputType.text,
                hintText: 'Name',
                obscureText: false,
                controller: textController,
              ),
              const SizedBox(height: 10,),
              MyTextField(
                input: TextInputType.text,
                hintText: 'Phone Number',
                obscureText: false,
                controller: numberController,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                firestoreService.updateChatNameAndPhoneNumber(chatID, textController.text,numberController.text);
                messageService.updateNameInTransactions(cn!,textController.text);
                textController.clear();
                numberController.clear();
                Navigator.pop(context);
              },
              child: const Text("Edit"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Ledger",style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
        backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Customers'),
            Tab(text: 'Suppliers'),
          ],
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      drawer: MyDrawer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: newNameBox,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Customer tab
                StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getCustomerNamesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    List namesList = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: namesList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = namesList[index];
                        String chatID = document.id;

                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String nameText = data['chatName'];
                        int balance=data['balance'];
                        String balanceText = balance==0 ? 'Settled up' : balance > 0 ? 'You Owe:' : 'Owes you:';
                        Color balanceColor = balance==0 ?Theme.of(context).colorScheme.onSurface : balance > 0 ? Colors.green : Colors.red;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              title: Text(
                                nameText,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(balanceText,style: TextStyle(color: balanceColor,fontSize: 13),),
                                  Text('${balance.abs()}',style: TextStyle(color: balanceColor,fontSize: 15,fontWeight: FontWeight.bold),)
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(chatID: chatID, chatName: nameText),
                                  ),
                                );
                              },
                              onLongPress: () => _showOptionsDialog(context,chatID,nameText),

                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Supplier tab
                StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getSupplierNamesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    List namesList = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: namesList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = namesList[index];
                        String chatID = document.id;

                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        String nameText = data['chatName'];
                        int balance=data['balance'];
                        String balanceText = balance==0 ? 'Settled up' : balance > 0 ? 'You Owe:' : 'Owes you:';
                        Color balanceColor = balance==0 ?Theme.of(context).colorScheme.onSurface : balance > 0 ? Colors.green : Colors.red;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              title: Text(
                                nameText,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(balanceText,style: TextStyle(color: balanceColor,fontSize: 13),),
                                  Text('${balance.abs()}',style: TextStyle(color: balanceColor,fontSize: 15,fontWeight: FontWeight.bold),)
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(chatID: chatID, chatName: nameText),
                                  ),
                                );
                              },
                              onLongPress: () => _showOptionsDialog(context,chatID,nameText),

                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: Theme.of(context).colorScheme.primary,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>const ReportPage()));
              },
              child: const Text('View Transaction Statements'),
            ),
          ),
        ],
      ),
    );
  }
  void _showOptionsDialog(BuildContext context, String chatID,String chatName) {
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
                onTap: () async{
                  final cphno = await firestoreService.getPhoneNumber(chatID);
                  final cn=await firestoreService.getChatName(chatID);
                  Navigator.pop(context);
                  newNameBox(chatID: chatID,cphno: cphno,cn: cn);
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
                onTap: () {
                  firestoreService.deleteContact(chatID);
                  messageService.deleteTransactions(chatID);
                  Navigator.pop(context);
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
                      Icon(Icons.delete, color: Colors.red),
                      // SizedBox(width: 5),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {

                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndReportPage(chatID: chatID,chatName: chatName),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt_sharp, color: Colors.green),
                      // SizedBox(width: 5),
                      Text('View Report', style: TextStyle(color: Colors.green)),
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
}
