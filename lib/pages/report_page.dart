import 'package:book_keeper/services/details_service.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final DetailsService _detailsService = DetailsService();
  final MessageService _messageService = MessageService();

  final user = FirebaseAuth.instance.currentUser;

  String _transactionType = 'Customer';
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _detailsService.getDetails(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final userDetails = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Details:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    child: ListTile(
                      title: Text(userDetails['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone Number: ${userDetails['phno']}'),
                          Text('Business Name: ${userDetails['businessname']}'),
                          Text('Address: ${userDetails['address']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Select Transactions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButton<String>(
                    value: _transactionType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _transactionType = newValue!;
                      });
                    },
                    items: <String>['Customer', 'Supplier']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Select Date Range:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _startDate != null ? _startDate.toString() : '',
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null && pickedDate != _startDate) {
                              setState(() {
                                _startDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _endDate != null ? _endDate.toString() : '',
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null && pickedDate != _endDate) {
                              setState(() {
                                _endDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_startDate != null && _endDate != null) {
                        setState(() {
                          _messages = [];
                        });
                        List<Map<String, dynamic>> fetchedMessages =
                        await _messageService.getMessagesWithConTypeAndDate(
                            _transactionType == 'Customer' ? 1 : 2, _startDate!, _endDate!);
                        print('Fetched messages: $fetchedMessages');
                        setState(() {
                          _messages = fetchedMessages;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both start and end dates.')),
                        );
                      }
                    },
                    child: const Text('Generate Report'),
                  ),
                  const SizedBox(height: 16.0),
                  if (_messages.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> message = _messages[index];
                          return ListTile(
                            title: Text('Message: ${message['message']}'),
                            subtitle: Text('Comment: ${message['comment']}'),
                            // Add more details as needed...
                          );
                        },
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
