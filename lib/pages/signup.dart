import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_keeper/components/my_button.dart';
import 'package:book_keeper/components/my_textfield.dart';
import 'package:book_keeper/wrapper.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();

  signup()async{
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
    Get.offAll(const Wrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"),centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.account_circle,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 40,),
            Text ("Welcome to the App!!!",style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),),
            const SizedBox(height: 50,),
            MyTextField(hintText: 'Enter Email', obscureText: false, controller:email),
            const SizedBox(height: 10,),
            MyTextField(hintText: 'Enter Password', obscureText: true, controller:password),
            MyButton(text: 'Sign Up', onTap:()=>signup() )

          ],
        ),
      ),
    );
  }
}
