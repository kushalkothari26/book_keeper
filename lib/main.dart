import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:book_keeper/themes/theme_provider.dart';
import 'package:book_keeper/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:book_keeper/firebase_options.dart';
void main() async{
  /*firebase Initialization*/
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(create: (context)=>ThemeProvider(),child: const MyApp()));

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    /*for push notifications*/
    FirebaseMessaging pushNotificationService = FirebaseMessaging.instance;
    pushNotificationService.getToken().then((token) {
      print("FCM Token: $token");
    });
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: const Wrapper()
    );
  }
}
