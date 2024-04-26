import 'dart:async';

import 'package:aircolis/pages/alertes/alertesScreen.dart';
import 'package:aircolis/pages/dash/dash.dart';
import 'package:aircolis/pages/parcel/currentTasks.dart';
import 'package:aircolis/pages/posts/myposts/myPostsScreen.dart';
import 'package:aircolis/pages/user/profile.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final bool? showWelcomeDialog;

  const HomeScreen({Key? key, this.showWelcomeDialog = false})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /*FlutterLocalNotificationsPlugin localNotification;
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }*/

  late Timer _timer;

  User? user = FirebaseAuth.instance.currentUser;

  int _index = 0;
  List screens = [
    DashScreen(),
    AlertesScreen(), //FindPostScreen(),
    MyPostsScreen(),
    CurrentTasks(
      showBack: false,
    ),
    ProfileScreen(
      showBack: false,
    ),
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
        FirebaseAuth.instance.currentUser!.reload().catchError((onError) {
          print(onError.toString());
        });
        setState(() {
          user = FirebaseAuth.instance.currentUser;
        });
      });
    } else {
      if (_timer.isActive) _timer.cancel();
    }
  }

  void checkSubscription() async {
    DocumentSnapshot<Object?> doc = await AuthService().getUserDoc();

    var data = doc.data() as Map<String, dynamic>;

    //var data = new Map<String, dynamic>.of(doc.data());
    /*if (!data.containsKey("subscriptionVoyageur")) {
      print('subscription not exist... Adding now');
      AuthService().updateSubscriptionVoyageur(0);
    }*/
    if (!data.containsKey("subscription")) {
      print('subscription expeditor not exist... Adding now');
      AuthService().updateSubscriptionExpediteur(0);
    }
  }

  @override
  void initState() {
    /* var androidInitialize = new AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
   localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);*/

    listenForUser();
    checkSubscription();
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
    if (user!.emailVerified) {
      _timer.cancel();
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: screens[_index],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppLocalizations.of(context)!.translate("home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: "Alertes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: AppLocalizations.of(context)!.translate("post"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.padding),
              label: AppLocalizations.of(context)!.translate("parcel"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppLocalizations.of(context)!.translate("profile"),
            ),
          ],
          currentIndex: _index, //New
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          //backgroundColor: Colors.black,
          selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.secondary, size: 40),
          unselectedIconTheme: IconThemeData(
            color: Colors.black,
          ),
          unselectedItemColor: Colors.black,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

/*void registerNotification() async {
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
        "0", "aircolis", "aircolis notifications",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var notificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotification.show(0, title, body, notificationDetails);
  }*/
}
