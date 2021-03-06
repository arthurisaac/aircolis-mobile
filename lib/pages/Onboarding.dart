import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool isConsent = false;
  SharedPreferences prefs;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPage = 3;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPage; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
          color: isActive ? Colors.white : Color(0xFF2D928E),
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
  }

  showConsentDialogIOS() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: CupertinoAlertDialog(
            title: Text("Consentement utilisateur"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyText2
                            .copyWith(color: Colors.black),
                        children: [
                          TextSpan(
                              text:
                                  "Nous aimerions vous informer quant au consentement ?? la collecte et l'utilisation des donn??es. Comme la majorit??e des applications, lorsque vous utilisez Aircolis, nous collectons des informations d'ordre analytique afin d'optimiser la performance de nos services. Afin de pouvoir de pouvoir collecter ces informations et vous proposer une meilleure exp??rience personnalis??e, nous utilisons des services provenants de Google et Facebook. \n \n"),
                          TextSpan(
                              text:
                                  "Afin de se conformer aux nouvelles r??gulations de protection des donn??es de l'Union Europ??enne, ainsi que de nous assurer que vous soyez bien inform?? quand ?? vos droits ainsi qu'au contr??le que vous poss??dez sur vos donn??es personnelles, nous avons mis-??-jour nos conditions d'utilisations et notre Politique de confidentialit?? afin de vous apporter plus de transparence quant?? la collecte et les modalit??s d'utilisation de vos donn??es. \n\n"),
                          TextSpan(text: "Voir nos "),
                          TextSpan(text: "conditions d'utilisation", style: TextStyle(color: Theme.of(context).primaryColor)),
                        ]),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  textStyle: TextStyle(color: Colors.black),
                  isDefaultAction: false,
                  onPressed: () {
                    Navigator.pop(context);
                    SystemNavigator.pop();
                  },
                  child: Text("Refuser")),
              CupertinoDialogAction(
                  textStyle: TextStyle(color: Theme.of(context).primaryColor),
                  isDefaultAction: true,
                  onPressed: () async {
                    await prefs.setBool("isConsent", true);
                    Navigator.pop(context);
                  },
                  child: Text("Approver")),
            ],
          ),
        );
      },
    );
  }

  showConsentDialogAndroid() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            title: Text("Consentement utilisateur"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodyText2
                          .copyWith(color: Colors.black),
                      children: [
                        TextSpan(
                            text:
                                "Nous aimerions vous informer quant au consentement ?? la collecte et l'utilisation des donn??es. Comme la majorit??e des applications, lorsque vous utilisez Aircolis, nous collectons des informations d'ordre analytique afin d'optimiser la performance de nos services. Afin de pouvoir de pouvoir collecter ces informations et vous proposer une meilleure exp??rience personnalis??e, nous utilisons des services provenants de Google et Facebook. \n \n"),
                        TextSpan(
                            text:
                                "Afin de se conformer aux nouvelles r??gulations de protection de donn??es de l'Union Europ??enne, ainsi que de nous assurer que vous soyez bien inform?? quand ?? vos droits ainsi qu'au contr??le que vous poss??dez sur vos donn??es personnelles, nous avons mis-??-jour nos conditions d'utilisations et notre Politique de confidentialit?? afin de vous apporter plus de transparence quant?? la collecte et les modalit??s d'utilisation de vos donn??es. \n\n"),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () async {
                        String uri = CGU_LINK;
                        await canLaunch(Uri.encodeFull(uri));
                        await launch(Uri.encodeFull(uri));
                      },
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyText2
                              .copyWith(color: Colors.black),
                          children: [
                            TextSpan(text: "Voir nos "),
                            TextSpan(text: "conditions d'utilisation", style: TextStyle(color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              GestureDetector(
                  onTap: () {
                    //Navigator.pop(context);
                    SystemNavigator.pop();
                  },
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        "Refuser",
                        style: TextStyle(color: Colors.black),
                      ))),
              GestureDetector(
                onTap: () async {
                  await prefs.setBool("isConsent", true);
                  await prefs.setInt("initScreen", 1);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    "Approver",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getConsent() async {
    prefs = await SharedPreferences.getInstance();
    bool consent = prefs.getBool("isConsent");
    print(consent);
    if (consent == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showConsentDialogAndroid();
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
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.4, 0.7, 0.9],
              colors: [
                Color(0xB444CFCA),
                Color(0xFF44CFCA),
                Color(0xFF5CC4C0),
                Color(0xFF38ADA9),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        "Passer",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Spacer(),
                            Center(
                              child: Image(
                                image: AssetImage("images/1.png"),
                                height: size.height * 0.3,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "Rencontrer des voyageurs pr??s de chez vous",
                              style:
                                  Theme.of(context).primaryTextTheme.headline5,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Trouver des personnes qui voyagent ?? la bonne date pour envoyer vos colis ?? vos proches",
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(),
                            Center(
                              child: Image(
                                image: AssetImage("images/2.png"),
                                width: 300,
                                height: size.height * 0.3,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "Suivez vos colis",
                              style:
                                  Theme.of(context).primaryTextTheme.headline5,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Suivre le parcours de votre colis tout le long du trajet",
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Spacer(),
                            Center(
                              child: Image(
                                image: AssetImage("images/3.png"),
                                width: 300,
                                height: size.height * 0.3,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "Gagner de l'argent",
                              style:
                                  Theme.of(context).primaryTextTheme.headline5,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Enregistrer vos prochains voyages afin de recevoir des colis ?? emporter moyennant une r??mun??ration au kilo;",
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText1,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPage - 1
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.transparent,
                              onPrimary: Colors.transparent,
                              elevation: 0.0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Suivant",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 30,
                                )
                              ],
                            ),
                            onPressed: () {
                              _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                      )
                    : Text(""),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPage - 1
          ? Container(
              height: 80,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      "Commencer",
                      style:
                          Theme.of(context).primaryTextTheme.headline6.copyWith(
                                color: Color(0xFF2D928E),
                              ),
                    ),
                  ),
                ),
              ),
            )
          : Text(""),
    );
  }
}
