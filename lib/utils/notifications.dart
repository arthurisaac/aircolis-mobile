import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class NotificationUtils {
  int _messageCount = 1;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'Aircolis Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Aircolis!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Future<void> sendPushMessage(String _token) async {
    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  /* showNotification(FlutterLocalNotificationsPlugin localNotification, RemoteNotification notification) async {
    var androidDetails = new AndroidNotificationDetails(channel.id, channel.name, channel.description, importance: channel.importance);
    var iosDetails = new IOSNotificationDetails();
    var notificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotification.show(0, notification.title, notification.body, notificationDetails);
  } */

  /*showNotification(RemoteNotification notification) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
            icon: 'launch_background',
          ),
        ));
  }

  setChannel() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  testNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('repeating channel id',
        'repeating channel name', 'repeating description');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }*/
}
