import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  Future<void> initNotifications(int userId) async {

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('logo');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      // Save the token in Firebase Realtime Database under the user's ID
      await _databaseRef.child('Users/$userId/fcmToken').set(token);
      print("FCM token saved for user: $userId");
    } else {
      print("FCM token not retrieved.");
    }

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message)async {
      print('Received message while in foreground: ${message.notification?.title}');
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref("Users/$userId")
          .child("Notifications")
          .get();
      if(snapshot.value == 1) {
        _showNotification(message);
      }
    });

    // Set up background and terminated state message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      print('Notification caused app to open: ${message.notification?.title}');
      //if user enabled notifications
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref("Users/$userId")
          .child("Notifications")
          .get();
      if(snapshot.value == 1) {
        _showNotification(message);
      }
    });
    //if app is terminated or in background
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'gift_notification',
      'notification',
      channelDescription: 'notification',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'logo',
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Background message handler
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'gift_notification',
      'notif',
      channelDescription: 'notific',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'logo',
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    //if(FirebaseDatabase.instance.ref("Users/${userId}").child("Notifications").get() == 1){
      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    //}

  }
  Future<void> removeFCMToken(int userId) async {
    try {

      await _databaseRef.child('Users/$userId/fcmToken').remove();
      print("FCM token removed for user: $userId");
    } catch (e) {
      print("Error removing FCM token: $e");
    }
  }

}
