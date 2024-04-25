import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:book_keeper/pages/settings_page.dart';
import 'package:book_keeper/pages/account_page.dart';
import 'package:book_keeper/pages/report_page.dart';
import 'package:book_keeper/pages/about_page.dart';
class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});
  final user=FirebaseAuth.instance.currentUser;
  signout()async{
    await GoogleSignIn().signOut();//remove this to not show the google ids again and again
    await FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(child: Center(
                child: GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>const AccountDetailsPage()));},
                    child: Column(
                      children: [
                        Icon(Icons.account_circle,color: Theme.of(context).colorScheme.primary,size: 90,),
                        const SizedBox(height: 20,),
                        const Text('Account Details')
                      ],
                    )),
              )),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("HOME"),
                  leading: const Icon(Icons.home),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("SETTINGS"),
                  leading: const Icon(Icons.settings),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>const SettingsPage()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("VIEW TRANSACTION REPORT"),
                  leading: const Icon(Icons.list_alt_sharp),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>const ReportPage()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("ABOUT THE APP"),
                  leading: const Icon(Icons.rule),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>const AboutPage()));
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              title: const Text("L O G O U T"),
              leading: const Icon(Icons.logout),
              onTap: (){
                signout();
              },
            ),
          )
        ],
      ),
    );
  }
}
