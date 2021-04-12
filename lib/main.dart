import 'package:aircolis/loading.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: 'Aircolis',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: Color(0xFF38ADA9),
        primaryColorLight: Color(0xFF44CFCA),
        accentColor: Color(0xFF1E2F47),
        //accentColor: Color(0xFF1E2F47),
        fontFamily: 'Montserrat',
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return SomethingWentWrong(description: 'Something went wrong',);
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return AuthService().isUserLogged();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Loading();
        },
      ),
    );
  }
}
