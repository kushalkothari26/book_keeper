import 'package:cloud_firestore/cloud_firestore.dart';
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

  void openNoteBox({String? docID}) {
    if (docID == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Business Contact'),
          content: Column(
            children: [
              MyTextField(hintText: 'Enter Name', obscureText: false, controller: textController),
              const SizedBox(height: 10,),
              MyTextField(hintText: 'Enter Phone Number', obscureText: false, controller: numberController),
              RadioListTile(
                title: const Text('Customer'),
                value: 1,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value as int;
                  });
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
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docID == null) {
                  firestoreService.addNote(textController.text, _selectedValue, numberController.text);
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Name'),
          content: Column(
            children: [
              MyTextField(hintText: 'Enter Name', obscureText: false, controller: textController),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                firestoreService.updateNote(docID, textController.text);
                textController.clear();
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
        title: const Text("Your Ledger"),
        backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Customers'),
            Tab(text: 'Suppliers'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
        ),
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add), // Use primary color from theme
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Customer tab
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getCustomerNotesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List notesList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String noteText = data['name'];
                  int balance=data['balance'];
                  String balanceText = balance==0 ? 'Settled up' : balance > 0 ? 'You Owe: $balance' : 'Owes you: ${balance.abs()}';
                  Color balanceColor = balance==0 ?Colors.black : balance > 0 ? Colors.green : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 2.0,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: ListTile(
                        title: Text(
                          noteText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(balanceText,style: TextStyle(color: balanceColor,fontSize: 13),),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(docID: docID, title: noteText),
                            ),
                          );
                        },
                        onLongPress: () => _showOptionsDialog(context,docID),

                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Supplier tab
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getSupplierNotesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List notesList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String noteText = data['name'];
                  int balance=data['balance'];
                  String balanceText = balance==0 ? 'Settled up' : balance > 0 ? 'You Owe: $balance' : 'Owes you: ${balance.abs()}';
                  Color balanceColor = balance==0 ?Colors.black : balance > 0 ? Colors.green : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 2.0,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: ListTile(
                        title: Text(
                          noteText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(balanceText,style: TextStyle(color: balanceColor,fontSize: 13),),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(docID: docID, title: noteText),
                            ),
                          );
                        },
                        onLongPress: () => _showOptionsDialog(context,docID),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  void _showOptionsDialog(BuildContext context, String docID) {
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
                  openNoteBox(docID: docID);
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
                  firestoreService.deleteNote(docID);
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
}
