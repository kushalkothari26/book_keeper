import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:book_keeper/components/my_button.dart';
import 'package:book_keeper/components/my_textfield.dart';
import 'package:book_keeper/pages/forgot.dart';
import 'package:book_keeper/pages/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isloading = false;

  signIn() async {
    setState(() {
      isloading = true;
    });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.text, password: password.text);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("error msg", e.code);
    } catch (e) {
      Get.snackbar("error msg", e.toString());
    }
    setState(() {
      isloading = false;
    });
  }

  login() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(fontSize: 28),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.account_circle,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              "Welcome back!!! you have been missed",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: 'Enter Email',
              obscureText: false,
              controller: email,
              backgroundColor: Theme.of(context).colorScheme.surface,
              textColor: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 10),
            MyTextField(
              hintText: 'Enter Password',
              obscureText: true,
              controller: password,
              backgroundColor: Theme.of(context).colorScheme.surface,
              textColor: Theme.of(context).colorScheme.onSurface,
            ),
            MyButton(
              text: 'Login',
              onTap: signIn,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a Member?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(const Signup()),
                  child: Text(
                    'Register Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.to(const Forgot()),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const Text('--------------------------------or-------------------------------------'),
            ElevatedButton(
              onPressed: login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login),
                    Text(
                      '  Sign in with Google',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
