import 'package:aircolis/loading.dart';
import 'package:aircolis/pages/Onboarding.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:aircolis/models/ProviderModel.dart';

int initScreen;

Future<void> main() async {
  InAppPurchaseConnection.enablePendingPurchases();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen");
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => new ProviderModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  void initState() {
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.initialize();
    super.initState();
  }

  @override
  void dispose() {
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.subscription.cancel();
    super.dispose();
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
      home: (initScreen == null || initScreen == 0)
          ? Onboarding()
          : FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return SomethingWentWrong(
              description: 'Something went wrong',
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return AuthService().handleAuth();
          }
          return Loading();
        },
      ),
    );
  }
}
