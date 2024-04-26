import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:book_keeper/components/my_button.dart';
import 'package:book_keeper/components/my_textfield.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {

  TextEditingController email=TextEditingController();


  reset()async{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password"),centerTitle: true,backgroundColor: Colors.transparent,foregroundColor: Theme.of(context).colorScheme.primary,),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 40,),
            Text ("Don't Worry. We got you Covered.",style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),),
            const SizedBox(height: 20,),
            MyTextField(hintText: 'Enter Email', obscureText: false, controller:email,input: TextInputType.text,),
            MyButton(text: 'Send Link', onTap: ()=>reset())
          ],
        ),
      ),
    );
  }
}
