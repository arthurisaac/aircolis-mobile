import 'dart:io';

import 'package:aircolis/pages/auth/loginWithEmail.dart';
import 'package:aircolis/pages/auth/phoneValidation.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/pages/user/registerFromSocial.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var login = false; // Connexion en cours
  bool errorState = false;
  String errorDescription;
  final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bag.jpg"), fit: BoxFit.cover),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(space),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black26.withOpacity(0.1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: space / 2,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(0, space, 0, space),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate("welcome")}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline4
                            .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${AppLocalizations.of(context).translate("signInToContinue")}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: space),
                      Container(
                        child: Column(
                          children: [
                            SizedBox(height: space * 2),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        LoginWithEmailScreen()));
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                padding: EdgeInsets.all(space),
                                decoration: BoxDecoration(
                                  color: Colors.cyan[100],
                                  borderRadius: BorderRadius.circular(padding),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "images/icons/email.svg",
                                      width: 20,
                                    ),
                                    SizedBox(width: space),
                                    Text(
                                      '${AppLocalizations.of(context).translate("loginWithEmail")}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: space),
                            InkWell(
                              onTap: () {
                                _loginWithGoogle();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                padding: EdgeInsets.all(space),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(padding),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "images/icons/google.svg",
                                      width: 20,
                                    ),
                                    SizedBox(width: space),
                                    Text(
                                        '${AppLocalizations.of(context).translate("loginGoogle")}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: space),
                            (Platform.isIOS)
                                ? FutureBuilder<bool>(
                                    future: _isAvailableFuture,
                                    builder: (context, isAvailableSnapshot) {
                                      if (!isAvailableSnapshot.hasData) {
                                        return Container(
                                            child: Text('Loading...'));
                                      }
                                      return isAvailableSnapshot.data
                                          ? InkWell(
                                              onTap: () {
                                                _loginWithApple();
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: double.infinity,
                                                padding: EdgeInsets.all(space),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          padding),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "images/icons/apple.svg",
                                                      width: 20,
                                                    ),
                                                    SizedBox(width: space),
                                                    Text(
                                                      '${AppLocalizations.of(context).translate("loginApple")}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Text(
                                              "Sign in With Apple not available.");
                                    })
                                : Container(),
                            SizedBox(height: space),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("ou",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: space),
                            !login
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.transparent,
                                      onPrimary: Colors.transparent,
                                      elevation: 0.0,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      //padding: EdgeInsets.all(space),
                                      child: Text(
                                        'Pas maintenant',
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        login = true;
                                      });
                                      await FirebaseAuth.instance.signOut();
                                      FirebaseAuth.instance
                                          .signInAnonymously()
                                          .then((value) {
                                        setState(() {
                                          login = false;
                                        });
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()));
                                      }).catchError((onError) {
                                        setState(() {
                                          login = false;
                                          errorState = true;
                                          errorDescription = onError.toString();
                                        });
                                      });
                                    },
                                  )
                                : Container(
                                    margin: EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            '${AppLocalizations.of(context).translate("loading")}'),
                                        Container(
                                          margin:
                                              EdgeInsets.only(left: space / 2),
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 1),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: space),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PhoneValidationScreen()));
                        },
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).primaryTextTheme.bodyText2,
                            children: [
                              TextSpan(
                                text:
                                    '${AppLocalizations.of(context).translate("dontYouHaveAnAccount")}',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(text: ' '),
                              TextSpan(
                                text:
                                    '${AppLocalizations.of(context).translate("registerAccount")}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorLight),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _loginWithApple() async {
    await AuthService().signInWithApple().then((value) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    }).catchError((onError) {
      print(onError);
      Utils.showSnack(context, onError.toString());
    });
  }

  _loginWithGoogle() {
    setState(() {
      errorState = false;
      errorDescription = "";
    });

    AuthService().signInWithGoogle().then((value) {
      print(value.user);
      AuthService()
          .checkAccountExist(FirebaseAuth.instance.currentUser?.uid)
          .then((doc) {
        if (doc.exists) {
          AuthService().updateLastSignIn().then((value) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        } else {
          AuthService().saveUser().then((value) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RegisterFromSocialScreen()));
          }).catchError((onError) {
            print(onError.toString());
            setState(() {
              errorState = true;
              errorDescription = onError.toString();
            });
          });
        }
      }).catchError((onError) {
        print(onError.toString());
        setState(() {
          errorState = true;
          errorDescription = onError.toString();
        });
      });
    }).catchError((onError) {
      print(onError.toString());
      setState(() {
        login = false;
        errorState = true;
        errorDescription = onError.toString();
      });
    });
  }

/*_loginWithEmailAndPassword() {
    setState(() {
      login = true;
      errorState = false;
      errorDescription = "";
    });
    // remove error description
    // login with google email and password
    AuthService()
        .signInEmailAndPassword(emailController.text, passwordController.text)
        .then((value) {
      setState(() {
        login = false;
      });
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    }).onError((FirebaseAuthException e, stackTrace) {
      setState(() {
        login = false;
        errorState = true;
        errorDescription = e.message;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    });
  }*/
}
