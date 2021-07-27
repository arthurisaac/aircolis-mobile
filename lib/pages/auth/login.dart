import 'dart:io';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/loginWithEmail.dart';
import 'package:aircolis/pages/auth/passwordForget.dart';
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
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var login = false; // Connexion en cours
  bool errorState = false;
  String errorDescription;
  final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();
  FocusScopeNode currentFocus;
  double maxScreen = 750;
  Color _colors = Colors.black;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentFocus = FocusScope.of(context);
    });
    _colors = Platform.isIOS ? Colors.black : Colors.white;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage((Platform.isAndroid)
                      ? "images/bag.jpg"
                      : "images/login-bg.png"),
                  fit: BoxFit.cover),
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
                    height: space * 3,
                  ),
                  (screenHeight < maxScreen)
                      ? Container(
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
                                        color: _colors,
                                        fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  '${AppLocalizations.of(context).translate("signInToContinue")}',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headline6
                                      .copyWith(color: _colors)),
                            ],
                          ),
                        )
                      : Container(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  //padding: EdgeInsets.all(space / 2),
                                  child: Text(
                                    'Pour une expérience personnalisée, connectez-vous à votre compte',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6
                                        .copyWith(color: _colors),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: space,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: _colors),
                                    hintText: AppLocalizations.of(context)
                                        .translate('emailAddress'),
                                    /*labelText: AppLocalizations.of(context)
                                                .translate('emailAddress'),*/
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(padding),
                                    ),
                                    fillColor: Colors.white24,
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(color: _colors),
                                ),
                                SizedBox(height: space),
                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: _colors),
                                    hintText: AppLocalizations.of(context)
                                        .translate('password'),
                                    /*labelText: AppLocalizations.of(context)
                                                .translate('password'),*/
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(padding),
                                    ),
                                    fillColor: Colors.white38,
                                    filled: true,
                                    focusColor: Colors.black,
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(color: _colors),
                                ),
                                SizedBox(
                                  height: space / 2,
                                ),
                                Container(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            PasswordForgetScreen(),
                                      );
                                    },
                                    child: Text(
                                      '${AppLocalizations.of(context).translate("passwordForget")}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _colors),
                                    ),
                                  ),
                                ),
                                SizedBox(height: space * 2),
                                login
                                    ? Container(
                                        child: CircularProgressIndicator(),
                                      )
                                    : AirButton(
                                        onPressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            _loginWithEmailAndPassword();
                                          }
                                        },
                                        text: Text(
                                          '${AppLocalizations.of(context).translate("login")[0].toUpperCase()}${AppLocalizations.of(context).translate("login").substring(1)}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04),
                                        ),
                                      ),
                                errorState
                                    ? Container(
                                        margin: EdgeInsets.only(top: space),
                                        width: double.infinity,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(padding)),
                                        child: Text(
                                          '$errorDescription',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                (Platform.isIOS)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PhoneValidationScreen()));
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyText2,
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${AppLocalizations.of(context).translate("dontYouHaveAnAccount")}',
                                                  style: TextStyle(
                                                    color: _colors,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(text: ' '),
                                                TextSpan(
                                                  text:
                                                      '${AppLocalizations.of(context).translate("registerAccount")}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .primaryColorDark),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(height: space),
                              ],
                            ),
                          ),
                        ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              (screenHeight < maxScreen)
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginWithEmailScreen()));
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        padding: EdgeInsets.all(space),
                                        decoration: BoxDecoration(
                                          color: Colors.cyan[100],
                                          borderRadius:
                                              BorderRadius.circular(padding),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              Platform.isIOS
                                  ? Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: space),
                                          child: Text(
                                            "Ou connectez-vous avec :",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(height: space),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _loginWithGoogle();
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.all(space),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: SvgPicture.asset(
                                                  "images/icons/google.svg",
                                                  width: 20,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: space),
                                            (Platform.isIOS)
                                                ? FutureBuilder<bool>(
                                                    future: _isAvailableFuture,
                                                    builder: (context,
                                                        isAvailableSnapshot) {
                                                      if (!isAvailableSnapshot
                                                          .hasData) {
                                                        return Container(
                                                          child: Text(
                                                              'Loading...'),
                                                        );
                                                      }
                                                      return isAvailableSnapshot
                                                              .data
                                                          ? InkWell(
                                                              onTap: () {
                                                                _loginWithApple();
                                                              },
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        space),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .black,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  "images/icons/apple.svg",
                                                                  width: 20,
                                                                ),
                                                              ),
                                                            )
                                                          : Text(
                                                              "Sign in With Apple not available.");
                                                    })
                                                : Container(),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
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
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      padding),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.04)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: space),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: _colors,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("ou",
                                        style: TextStyle(color: _colors)),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: _colors,
                                    ),
                                  ),
                                ],
                              ),
                              !login
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        onPrimary: Colors.transparent,
                                        elevation: 0.0,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: Container(
                                        //width: double.infinity,
                                        color: Colors.white30,
                                        //padding: EdgeInsets.all(space),
                                        child: Text(
                                          'Pas maintenant',
                                          style: TextStyle(
                                              color: _colors,
                                              fontWeight: FontWeight.bold),
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
                                            errorDescription =
                                                onError.toString();
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
                                            margin: EdgeInsets.only(
                                                left: space / 2),
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
                        (Platform.isAndroid)
                            ? InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          PhoneValidationScreen()));
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText2,
                                    children: [
                                      TextSpan(
                                        text:
                                            '${AppLocalizations.of(context).translate("dontYouHaveAnAccount")}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ' '),
                                      TextSpan(
                                        text:
                                            '${AppLocalizations.of(context).translate("registerAccount")}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorLight),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
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

  _loginWithEmailAndPassword() {
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
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
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        setState(() {
          errorDescription = "Aucun utilisateur trouvé pour cet e-mail.";
        });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          errorDescription =
              "Mot de passe incorrect fourni pour cet utilisateur.";
        });
      }
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
