import 'dart:async';

import 'package:aircolis/pages/dash/dash.dart';
import 'package:aircolis/pages/findPost/findPostScreen.dart';
import 'package:aircolis/pages/help/helpScreen.dart';
import 'package:aircolis/pages/home/airBottomNavigation.dart';
import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/posts/myposts/myPostsScreen.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:aircolis/pages/userNotVerified.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  final bool showWelcomeDialog;

  const HomeScreen({Key key, this.showWelcomeDialog}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin localNotification;
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  Timer _timer;

  User user = FirebaseAuth.instance.currentUser;

  int _index = 0;
  List screens = [
    DashScreen(),
    FindPostScreen(),
    MyPostsScreen(),
    HelpScreen(),
  ];

  setScreen(int index) {
    setState(() {
      _index = index;
    });
  }

  listenForUser() {
    const oneSec = const Duration(seconds: 5);
    if (user != null) {
      _timer = Timer.periodic(oneSec, (Timer t) {
        FirebaseAuth.instance.currentUser.reload();
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      });
    } else {
      if (_timer.isActive) _timer.cancel();
    }
  }

  @override
  void initState() {
    var androidInitialize = new AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    if (user == null) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    listenForUser();
    Utils().getLocation();
    Utils().getToken();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user.emailVerified) {
      _timer.cancel();
    }
    return (user.emailVerified)
        ? Scaffold(
            body: screens[_index],
            bottomNavigationBar: MyInheritedWidget(
              child: AirBottomNavigation(),
              myState: this,
            ),
          )
        : UserNotVerified();
  }

  void registerNotification() async {
    // On iOS, this helps to take the user permissions
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // For handling the received notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      _notification('Hello', '${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future _notification(String title, String body) async {
    var androidDetails = new AndroidNotificationDetails(
        "24", "aircolis", "aircolis notifications",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var notificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotification.show(0, title, body, notificationDetails);
  }
}

/// -------------------
/// MyInheritedWidget
/// --------------------

class MyInheritedWidget extends InheritedWidget {
  final _HomeScreenState myState;

  const MyInheritedWidget(
      {Key key, @required Widget child, @required this.myState})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return this.myState._index != oldWidget.myState._index;
  }

  static MyInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}
