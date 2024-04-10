import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:book_keeper/pages/settings_page.dart';
// import 'package:logreg/services/auth/auth_service.dart';
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
                child: Icon(Icons.message,color: Theme.of(context).colorScheme.primary,size: 40,),
              )),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("H O M E"),
                  leading: const Icon(Icons.home),
                  onTap: (){
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("S E T T I N G S"),
                  leading: const Icon(Icons.settings),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>const SettingsPage()));
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
