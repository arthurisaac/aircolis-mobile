import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/passwordForget.dart';
import 'package:aircolis/pages/auth/phoneValidation.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool loginState = false; // Connexion en cours
  bool errorState = false;
  String errorDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/travel.jpeg"), fit: BoxFit.cover),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.all(space),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Spacer(),
                SizedBox(height: space),
                Text(
                  '${AppLocalizations.of(context).translate("welcome")}',
                  style: Theme.of(context).primaryTextTheme.headline3,
                ),
                SizedBox(height: space * 2),
                Container(
                  padding: EdgeInsets.only(top: space / 2, right: space / 2, left: space / 2, bottom: space),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(padding)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.alternate_email,
                            ),
                            hintText: AppLocalizations.of(context)
                                .translate('emailAddress'),
                            labelText: AppLocalizations.of(context)
                                .translate('emailAddress'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(padding)),
                          ),
                        ),
                        SizedBox(height: space),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.lock_outline,
                            ),
                            hintText: AppLocalizations.of(context)
                                .translate('password'),
                            labelText: AppLocalizations.of(context)
                                .translate('password'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(padding)),
                          ),
                        ),
                        errorState ? SizedBox(height: space) : Container(),
                        errorState
                            ? Text(
                                '$errorDescription',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red[300]),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
                SizedBox(height: space),
                AirButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      // remove error description
                      setState(() {
                        loginState = true;
                        errorState = false;
                        errorDescription = "";
                      });
                      // login with google email and password
                      AuthService()
                          .signInEmailAndPassword(
                              emailController.text, passwordController.text)
                          .then((value) {
                            setState(() {
                              loginState = false;
                            });
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomeScreen()));
                      }).onError((FirebaseAuthException e, stackTrace) {
                        setState(() {
                          loginState = false;
                          errorState = true;
                          errorDescription = e.message;
                        });
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                        }
                      });
                    }
                  },
                  text: Text('${AppLocalizations.of(context).translate("login").toUpperCase()}',),
                ),
                SizedBox(height: space * 2),
                Text(
                  '${AppLocalizations.of(context).translate("or").toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: space * 2),
                ElevatedButton(
                  onPressed: () {
                    AuthService().signInWithGoogle().then((value) {
                      print(value.user);
                      AuthService().checkAccountExist().then((doc) {
                        if (doc.exists) {
                          AuthService().updateLastSignIn().then((value) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                          });
                        } else {
                          AuthService().saveUser().then((value) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(showWelcomeDialog: true)));
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
                      });
                    }).catchError((onError) {
                      print(onError.toString());
                      setState(() {
                        errorState = true;
                        errorDescription = onError.toString();
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(padding),
                      ),
                      primary: Colors.white),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "images/icons/google.svg",
                          width: 20,
                        ),
                        SizedBox(width: space),
                        Text(
                            '${AppLocalizations.of(context).translate("loginGoogle").toUpperCase()}',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: space),
                InkWell(
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => PasswordForgetScreen(),
                    );
                  },
                  child: Text(
                    '${AppLocalizations.of(context).translate("passwordForget")}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
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
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                      children: [
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context).translate("dontYouHaveAnAccount")}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
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
                SizedBox(height: space),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
