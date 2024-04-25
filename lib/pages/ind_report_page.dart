import 'dart:io';

import 'package:book_keeper/services/details_service.dart';
import 'package:book_keeper/services/message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:book_keeper/services/locnot_service.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
class IndReportPage extends StatefulWidget {

  final String chatID;
  final String chatName;
  const IndReportPage({super.key,required this.chatID,required this.chatName});

  @override
  State<IndReportPage> createState() => _IndReportPageState();
}

class _IndReportPageState extends State<IndReportPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
  final DetailsService _detailsService = DetailsService();
  final MessageService _messageService = MessageService();
  final user = FirebaseAuth.instance.currentUser;

  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> _transactions = [];

  @override
  Widget build(BuildContext context) {
    LocalNotification.initialize(flutterLocalNotificationsPlugin);
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
                                _transactions = [];
                              });
                              List<Map<String, dynamic>> fetchedMessages =
                              await _messageService.getTransactionsWithDate(widget.chatID,_startDate!, _endDate!);
                              setState(() {
                                _transactions = fetchedMessages;
                              });
                              LocalNotification.showBigTextNotification(title: 'Notification', body: 'Report Generated Successfully', fln: flutterLocalNotificationsPlugin);
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
                    if (_transactions.isNotEmpty)
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
                          Text('Business  Contact Name :${widget.chatName}'),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Debit')),
                                DataColumn(label: Text('Credit')),
                              ],
                              rows: _transactions.map<DataRow>((transaction) {
                                DateTime dt = (transaction['timestamp'] as Timestamp).toDate();
                                bool isDebit = transaction['gave'];
                                double amount = double.parse(transaction['amount']);
                                return DataRow(
                                  cells: [
                                    DataCell(Text('$dt')),
                                    DataCell(Text('${transaction['comment']}')),
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
              pw.Text('Business  Contact Name :${widget.chatName}'),
              pw.Table(
                border: const pw.TableBorder(),
                children: [
                  pw.TableRow(
                      children: [
                        pw.Text('Date'),
                        pw.Text('Description'),
                        pw.Text('Debit'),
                        pw.Text('Credit'),
                      ]
                  ),
                  ..._transactions.map((transaction) {
                    DateTime dt = (transaction['timestamp'] as Timestamp).toDate();
                    bool isDebit = transaction['gave'];
                    double amount = double.parse(transaction['amount']);
                    return pw.TableRow(
                      children: [
                        pw.Text('$dt'),
                        pw.Text('${transaction['comment']}'),
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

    final file = File('${outputDir.path}/ledger_report_${widget.chatName}.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF saved to Downloads folder.')));
    LocalNotification.showBigTextNotification(title: 'PDF Downloaded', body: 'Tap to open it', fln: flutterLocalNotificationsPlugin);
    // final output = await getTemporaryDirectory();
    // print(output.path);
    // final file = File('${output.path}/bank_statement.pdf');
    // await file.writeAsBytes(await pdf.save());
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF saved to Downloads folder.')));
  }


  double _calculateTotalDebit() {
    double totalDebit = 0;
    for (var transaction in _transactions) {
      if (transaction['gave']) {
        totalDebit += double.parse(transaction['amount']);
      }
    }
    return totalDebit;
  }

  double _calculateTotalCredit() {
    double totalCredit = 0;
    for (var transaction in _transactions) {
      if (!transaction['gave']) {
        totalCredit += double.parse(transaction['amount']);
      }
    }
    return totalCredit;
  }
}
