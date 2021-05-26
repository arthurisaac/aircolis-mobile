import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;

  const RegisterScreen({Key key, @required this.phoneNumber}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var firstnameController = TextEditingController();
  var lastnameController = TextEditingController();

  bool errorState = false;
  String errorDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('${AppLocalizations.of(context).translate("signup")}'),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(space),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: space,
                  ),
                  Container(
                    //width: MediaQuery.of(context).size.width * 0.70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).translate('signup')}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline4
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '${AppLocalizations.of(context).translate('tellUusWhoYouAreToGetStarted')}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .copyWith(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: space * 2),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText:
                          "${AppLocalizations.of(context).translate('emailAddress')}",
                      labelText:
                          "${AppLocalizations.of(context).translate('emailAddress')}",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(padding)),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: space),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context).translate('password'),
                      labelText:
                          AppLocalizations.of(context).translate('password'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(padding)),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: space),
                  TextFormField(
                    controller: firstnameController,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context).translate('firstname'),
                      labelText:
                          AppLocalizations.of(context).translate('firstname'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(padding)),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: space),
                  TextFormField(
                    controller: lastnameController,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context).translate('lastname'),
                      labelText:
                          AppLocalizations.of(context).translate('lastname'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(padding)),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: space),
                  errorState ? SizedBox(height: space) : Container(),
                  errorState
                      ? Text(
                          '$errorDescription',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[300]),
                        )
                      : Container(),
                  SizedBox(height: space * 3),
                  AirButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _save();
                      }
                    },
                    text: Text(
                        '${AppLocalizations.of(context).translate("save")}',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.04)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    setState(() {
      errorState = false;
      errorDescription = "";
    });
    AuthService()
        .createUserWithEmailAndPassword(
            emailController.text, passwordController.text)
        .then((value) {
      print(value.user);
      AuthService()
          .saveNewUser(firstnameController.text, lastnameController.text,
              widget.phoneNumber)
          .then((value) {
        Utils.sendWelcomeMail(emailController.text);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomeScreen()));
      }).onError((error, stackTrace) {
        setState(() {
          errorState = true;
          errorDescription = error.toString();
        });
      });
    }).onError((error, stackTrace) {
      setState(() {
        errorState = true;
        errorDescription = error.toString();
      });
      //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SomethingWentWrong(description: error.toString(),)));
    });
  }
}
