import 'dart:io';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool isConsent = false;
  SharedPreferences prefs;

  showConsentDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: CupertinoAlertDialog(
              title: Text("Consentement utilisateur"),
              content: Column(
                children: [
                  SizedBox(height: 20,),
                  SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).primaryTextTheme.bodyText2.copyWith(color: Colors.black),
                        children: [
                          TextSpan(text: "Nous aimerions vous informer quant au consentement à la collecte et l'utilisation des données. Comme la majoritée des applications, lorsque vous utilisez Aircolis, nous collectons des informations d'ordre analytique afin d'optimiser la performance de nos services. Afin de pouvoir de pouvoir collecter ces informations et vous proposer une meilleure expérience personnalisée, nous utilisons des services provenants de Google et Facebook. \n \n"),
                          TextSpan(text: "Afin de se conformer aux nouvelles régulations de protection de données de l'Union Européenne, ainsi que de nous assurer que vous soyez bien informé quand à vos droits ainsi qu'au contrôle que vous possédez sur vos données personnelles, nous avons mis-à-jour nos conditions d'utilisations et notre Politique de confidentialité afin de vous apporter plus de transparence quantà la collecte et les modalités d'utilisation de vos données. \n"),
                        ]
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                    textStyle: TextStyle(color: Colors.black),
                    isDefaultAction: false,
                    onPressed: (){
                      Navigator.pop(context);
                      SystemNavigator.pop();
                    },
                    child: Text("Refuser")
                ),
                CupertinoDialogAction(
                    textStyle: TextStyle(color: Theme.of(context).primaryColor),
                    isDefaultAction: true,
                    onPressed: () async {
                      await prefs.setBool("isConsent", true);
                      Navigator.pop(context);
                    },
                    child: Text("Approver")
                ),
              ],
            ),
          );
        }
    );
  }

  getConsent() async {
    prefs = await SharedPreferences.getInstance();
    bool consent = prefs.getBool("isConsent");
    print(consent);
    if (consent == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Platform.isIOS) {
          // TODO
          print("platform is iOS");
        }
        if (Platform.isAndroid) {
          print("platform is android");
        }
        showConsentDialog();
      });
    }
  }

  @override
  void initState() {
    getConsent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(14),
            child: AirButton(
              text: Text('${AppLocalizations.of(context).translate("login")}'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (builder) => LoginScreen()));
              },
            ),
          ),
        ),
      ),
    );
  }
}
