import 'dart:io';

import 'package:book_keeper/services/details_service.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

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
        title: Text('Transaction Report',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
        backgroundColor: Theme.of(context).colorScheme.primary),
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
              return SingleChildScrollView( // Wrap the Column in SingleChildScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                lastDate: DateTime(2025),
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
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_startDate != null && _endDate != null) {
                              setState(() {
                                _messages = [];
                              });
                              List<Map<String, dynamic>> fetchedMessages =
                              await _messageService.getTransactionsWithConTypeAndDate(
                                  _transactionType == 'Customer' ? 1 : 2, _startDate!, _endDate!);
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
                        const SizedBox(width: 10,),
                        ElevatedButton(
                          onPressed: () async {
                            await _generateAndSavePDF(userDetails['name'],userDetails['businessname'],userDetails['address'],userDetails['phno']);
                          },
                          child: const Text('Download Report'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    if (_messages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ledger Report:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          const SizedBox(height: 8.0),
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Debit')),
                                DataColumn(label: Text('Credit')),
                              ],
                              rows: _messages.map<DataRow>((message) {
                                DateTime dt = (message['timestamp'] as Timestamp).toDate();
                                bool isDebit = message['gave'];
                                double amount = double.parse(message['amount']);
                                return DataRow(
                                  cells: [
                                    DataCell(Text('$dt')),
                                    DataCell(Text('${message['name']}')),
                                    isDebit ? DataCell(Text('₹$amount')) : const DataCell(Text('')),
                                    isDebit ? const DataCell(Text('')) : DataCell(Text('₹$amount')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text('Total Debit: ₹${_calculateTotalDebit().toStringAsFixed(2)}'),
                          Text('Total Credit: ₹${_calculateTotalCredit().toStringAsFixed(2)}'),
                        ],
                      ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
  Future<void> _generateAndSavePDF(String name,String bname,String badd,int phno) async {
    final pdf = pw.Document();
    final DetailsService _detailsService = DetailsService();
    _detailsService.getDetails(user!.uid);
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Ledger Report:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18.0)),
              pw.SizedBox(height: 8.0),
              pw.Text(
                'Account Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16.0),
              ),
              pw.Text(name),
              pw.Text('Phone Number: $phno'),
              pw.Text('Business Name: $bname'),
              pw.Text('Address: $badd'),
              pw.Text('Statement:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16.0)),
              pw.SizedBox(height: 8.0),
              pw.Table(
                border: const pw.TableBorder(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Date'),
                      pw.Text('Name'),
                      pw.Text('Debit'),
                      pw.Text('Credit'),
                    ]
                  ),
                  ..._messages.map((message) {
                    DateTime dt = (message['timestamp'] as Timestamp).toDate();
                    bool isDebit = message['gave'];
                    double amount = double.parse(message['amount']);
                    return pw.TableRow(
                      children: [
                        pw.Text('$dt'),
                        pw.Text('${message['name']}'),
                        isDebit ? pw.Text('$amount'): pw.Text(''),
                        isDebit ? pw.Text('') : pw.Text('$amount'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16.0),
              pw.Text('Total Debit: ${_calculateTotalDebit().toStringAsFixed(2)}'),
              pw.Text('Total Credit: ${_calculateTotalCredit().toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );
    final outputDir = Directory('/storage/emulated/0/Download');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final file = File('${outputDir.path}/ledger_report.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF saved to Downloads folder.')));
    // final output = await getTemporaryDirectory();
    // print(output.path);
    // final file = File('${output.path}/bank_statement.pdf');
    // await file.writeAsBytes(await pdf.save());
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF saved to Downloads folder.')));
  }


  double _calculateTotalDebit() {
    double totalDebit = 0;
    for (var message in _messages) {
      if (message['gave']) {
        totalDebit += double.parse(message['amount']);
      }
    }
    return totalDebit;
  }

  double _calculateTotalCredit() {
    double totalCredit = 0;
    for (var message in _messages) {
      if (!message['gave']) {
        totalCredit += double.parse(message['amount']);
      }
    }
    return totalCredit;
  }

}
