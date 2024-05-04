/* this screen is for signing up in the application*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:book_keeper/components/my_button.dart';
import 'package:book_keeper/components/my_textfield.dart';
import 'package:book_keeper/wrapper.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isloading = false;
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  TextEditingController conpassword=TextEditingController();
  /*this function is used for signing up in the application*/
  signup()async{
    setState(() {
      isloading = true;
    });
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: password.text);
      Get.offAll(const Wrapper());
    }on FirebaseAuthException catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error $e')),
      );
    }catch (e) {
      Get.snackbar("error msg", e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error $e')),
      );
    }

    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Sign Up"),centerTitle: true,backgroundColor: Colors.transparent,foregroundColor: Theme.of(context).colorScheme.primary,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.account_circle,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 40,),
              Text ("Welcome to the App!!!",style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),),
              const SizedBox(height: 50,),
              MyTextField(hintText: 'Enter Email', obscureText: false, controller:email,input: TextInputType.text,),
              const SizedBox(height: 10,),
              MyTextField(hintText: 'Enter Password', obscureText: true, controller:password,input: TextInputType.text,),
              const SizedBox(height: 10,),
              MyTextField(hintText: 'Confirm Password', obscureText: true, controller:conpassword,input: TextInputType.text,),
              MyButton(text: 'Sign Up', onTap:()=>password.text==conpassword.text?signup():ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Passwords do  not match. Please Try again.')),
              ))
        
            ],
          ),
        ),
      ),
    );
  }
}
