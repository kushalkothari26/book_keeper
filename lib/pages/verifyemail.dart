import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_keeper/wrapper.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  void initState(){
    sendverifylink();
    super.initState();
  }
  sendverifylink()async{
    final user=FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification().then((value) => {
      Get.snackbar('Link sent','A link has been sent to your email id',margin: const EdgeInsets.all(30))
    });
  }
  reload()async{
    await FirebaseAuth.instance.currentUser!.reload().then((value) => {Get.offAll(const Wrapper())});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verification"),centerTitle: true,backgroundColor: Colors.transparent,foregroundColor: Theme.of(context).colorScheme.primary,),
      body: const Padding(
        padding: EdgeInsets.all(28),
        child: Center(
          child: Text('open Your mail and click on the link provided to verify the mail and reload this page'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (()=>reload()),
        child: const Icon(Icons.restart_alt_rounded),
      ),
    );
  }
}
