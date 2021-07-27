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
  FocusScopeNode currentFocus;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var login = false; // Connexion en cours
  bool errorState = false;
  String errorDescription;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentFocus = FocusScope.of(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        height: double.infinity,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            brightness: Brightness.dark,
            elevation: 0,
            title: Text(
              '${AppLocalizations.of(context).translate("loginWithEmail")}',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/bag.jpg"), fit: BoxFit.cover),
            ),
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration:
                    BoxDecoration(color: Colors.black26.withOpacity(0.1)),
                child: Padding(
                  padding: const EdgeInsets.all(space),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: space),
                                  TextFormField(
                                    controller: passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
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
                                    style: TextStyle(color: Colors.white),
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
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: space * 2),
                            login
                                ? Container(
                                    /*decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(space)),
                                          color: Theme.of(context).primaryColorLight,
                                        ),*/
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
                                    decoration:
                                        BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(padding)),
                                    child: Text(
                                      '$errorDescription',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Container()
                            //SizedBox(height: space),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: space),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PhoneValidationScreen()));
                          },
                          child: RichText(
                            text: TextSpan(
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText2,
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
                                      color:
                                          Theme.of(context).primaryColorLight),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        errorDescription = e.message;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        setState(() {
          errorDescription = "Aucun utilisateur trouvé pour cet e-mail.";
        });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          errorDescription = "Mot de passe incorrect fourni pour cet utilisateur.";
        });
      }
    });
  }
}
