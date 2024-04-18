import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:book_keeper/services/details_service.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final firestoreService = DetailsService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDetails,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name'),
            TextFormField(
              controller: _nameController,
            ),
            const SizedBox(height: 16.0),
            const Text('Phone Number'),
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16.0),
            const Text('Business Name'),
            TextFormField(
              controller: _businessNameController,
            ),
            const SizedBox(height: 16.0),
            const Text('Address'),
            TextFormField(
              controller: _addressController,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await firestoreService.getDetails(user!.uid);
      setState(() {
        _nameController.text = details['name'];
        _phoneNumberController.text = details['phno'].toString();
        _businessNameController.text = details['businessname'];
        _addressController.text = details['address'];
      });
    } catch (e) {
      print('Failed to load details: $e');
    }
  }

  Future<void> _saveDetails() async {
    try {
      await firestoreService.updateDetails(
        user!.uid,
        _nameController.text,
        int.tryParse(_phoneNumberController.text) ?? 0,
        _businessNameController.text,
        _addressController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save details')),
      );
    }
  }
}
