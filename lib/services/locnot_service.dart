import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification{
  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin)async{
    var androidInitialize=const AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationsSettings = InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showBigTextNotification({var id =0,required String title,required String body,var payload, required FlutterLocalNotificationsPlugin fln})async{
    AndroidNotificationDetails androidPlatformChannelSpecifics=const AndroidNotificationDetails('Kushal','Book Keeper',
        playSound: true,
        importance: Importance.high,
        priority: Priority.high);
    var not=NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0,title,body,not);
  }
}