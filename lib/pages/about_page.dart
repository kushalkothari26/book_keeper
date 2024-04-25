import 'package:flutter/material.dart';
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('About The App'),
      ),
      body: const Text('this is an app which acts as a ledger which stores transaction'),
    );
  }
}
