
import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/passwordForget.dart';
import 'package:aircolis/pages/auth/phoneValidation.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginWithEmailScreen extends StatefulWidget {
  @override
  _LoginWithEmailScreenState createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var login = false; // Connexion en cours
  bool errorState = false;
  String errorDescription;

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
      /*DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/travel.jpeg"), fit: BoxFit.cover),
          ),*/
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          elevation: 0,
          title: Text(
            '${AppLocalizations.of(context).translate("loginWithEmail")}',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(space),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Colors.white70.withOpacity(0.9)),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('emailAddress'),
                          labelText: AppLocalizations.of(context)
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
                          hintText: AppLocalizations.of(context)
                              .translate('password'),
                          labelText: AppLocalizations.of(context)
                              .translate('password'),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(padding)),
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
                              builder: (context) =>
                                  PasswordForgetScreen(),
                            );
                          },
                          child: Text(
                            '${AppLocalizations.of(context).translate("passwordForget")}',
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
                          if (_formKey.currentState.validate()) {
                            _loginWithEmailAndPassword();
                          }
                        },
                        text: Text(
                          '${AppLocalizations.of(context).translate("login")[0].toUpperCase()}${AppLocalizations.of(context).translate("login").substring(1)}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  MediaQuery.of(context).size.width *
                                      0.04),
                        ),
                      ),
                SizedBox(height: space),
                Container(
                  margin: EdgeInsets.symmetric(vertical: space),
                  child: InkWell(
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
                            style: TextStyle(color: Colors.black),
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
                ),
                //SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
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
        errorDescription = e.message;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    });
  }
}
