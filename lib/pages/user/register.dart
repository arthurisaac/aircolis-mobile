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
        title: Text('${AppLocalizations.of(context).translate("signup")}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(space),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  //width: MediaQuery.of(context).size.width * 0.70,
                  margin: EdgeInsets.all(space),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate('signup')}',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                          '${AppLocalizations.of(context).translate('tellUusWhoYouAreToGetStarted')}',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                SizedBox(height: space * 2),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      Icons.alternate_email,
                    ),
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
                    suffixIcon: Icon(
                      Icons.lock_outline,
                    ),
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
                    suffixIcon: Icon(
                      Icons.person_outline,
                    ),
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
                    suffixIcon: Icon(
                      Icons.person,
                    ),
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
                  text:
                      Text('${AppLocalizations.of(context).translate("save")}'),
                )
              ],
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
