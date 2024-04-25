import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operational Manual'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildManualItem('Login/Register to the application either using Email and Password or by simply using Google Authentication.'),
              _buildManualItem('Add Your Customers and Suppliers with Phone Number.'),
              _buildManualItem('Update or Delete Customers and Suppliers by long pressing them.'),
              _buildManualItem('Start recording your transactions with each of them.'),
              _buildManualItem('Send the WhatsApp reminders(Only Possible if the Phone Number is given).'),
              _buildManualItem('You can update or delete any transaction by long pressing them.'),
              _buildManualItem('You can view the individual transaction report by clicking on view report and also download it in the PDF format.'),
              _buildManualItem('You can view and download The transaction statements for all customers and Suppliers between a specific Date Range.'),
              _buildManualItem('You can change the theme of the app by going to the settings page from the drawer.'),
              _buildManualItem('You can see and Edit the account details by going to account Detail in the drawer.'),
              _buildManualItem('You can logout of the application by pressing the logout button in the drawer.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.check_circle, color: Colors.green),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
