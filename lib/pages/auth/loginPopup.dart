import 'dart:io';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/passwordForget.dart';
import 'package:aircolis/pages/auth/phoneValidation.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/pages/user/registerFromSocial.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginPopupScreen extends StatefulWidget {
  final bool showBack;
  const LoginPopupScreen({Key? key, this.showBack = true}) : super(key: key);

  @override
  _LoginPopupScreenState createState() => _LoginPopupScreenState();
}

class _LoginPopupScreenState extends State<LoginPopupScreen> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var login = false; // Connexion en cours
  bool errorState = false;
  String errorDescription = "";
  //final Future<bool> _isAvailableFuture = AppleSignIn.isAvailable();

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: !widget.showBack ? 0 : null,
          leading: widget.showBack
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(space),
            height: MediaQuery.of(context).size.height - 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white70.withOpacity(0.9)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Vous devez être connecté pour continuer',
                  style: Theme.of(context).primaryTextTheme.headline6?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: [
                    SizedBox(height: space),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .translate('emailAddress'),
                              labelText: AppLocalizations.of(context)!
                                  .translate('emailAddress'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(padding),
                              ),
                            ),
                          ),
                          SizedBox(height: space),
                          TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .translate('password'),
                              labelText: AppLocalizations.of(context)!
                                  .translate('password'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(padding)),
                            ),
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
                                  builder: (context) => PasswordForgetScreen(),
                                );
                              },
                              child: Text(
                                '${AppLocalizations.of(context)!.translate("passwordForget")}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          errorState ? SizedBox(height: space) : Container(),
                          errorState
                              ? Text(
                                  '$errorDescription',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(height: space * 2),
                    login
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(space)),
                              color: Theme.of(context).primaryColorLight,
                            ),
                            child: CircularProgressIndicator(),
                          )
                        : AirButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _loginWithEmailAndPassword();
                              }
                            },
                            text: Text(
                              '${AppLocalizations.of(context)!.translate("login").toString()[0].toUpperCase()}${AppLocalizations.of(context)!.translate("login").toString().substring(1)}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                            ),
                          ),
                    SizedBox(height: space),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                            child: Divider(
                          color: Colors.black,
                        )),
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Text(
                              "${AppLocalizations.of(context)!.translate("or")}"),
                          padding: EdgeInsets.all(space / 2),
                        ),
                      ],
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
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
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
                                '${AppLocalizations.of(context)!.translate("loginGoogle")}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: space),
                    (Platform.isIOS)
                        ?
                        /*FutureBuilder<bool>(
                            future: _isAvailableFuture,
                            builder: (context, isAvailableSnapshot) {
                              if (!isAvailableSnapshot.hasData) {
                                return Container(child: Text('Loading...'));
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
                                              BorderRadius.circular(padding),
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
                                              '${AppLocalizations.of(context)!.translate("loginApple")}',
                                              style: TextStyle(
                                                  color: Colors.white,
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
                                  : Text("Sign in With Apple not available.");
                            })*/
                        InkWell(
                            onTap: () {
                              _loginWithApple();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(space),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                "images/icons/apple.svg",
                                width: 20,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(height: space),
                  ],
                ),
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
                              '${AppLocalizations.of(context)!.translate("dontYouHaveAnAccount")}',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(text: ' '),
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.translate("registerAccount")}',
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
          .checkAccountExist(FirebaseAuth.instance.currentUser!.uid)
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
        errorDescription = e.message!;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
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
