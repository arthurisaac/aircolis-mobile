import 'package:aircolis/components/button.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';

class PasswordForgetScreen extends StatefulWidget {
  @override
  _PasswordForgetScreenState createState() => _PasswordForgetScreenState();
}

class _PasswordForgetScreenState extends State<PasswordForgetScreen> {
  var emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool emailSent = false;
  bool errorState = false;
  String errorDescription;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(space),
        child: !emailSent
            ? Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context).translate("resetPassword").toUpperCase()}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline6
                          .copyWith(color: Colors.black),
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
                      onChanged: (value) {
                        setState(() {
                          errorState = false;
                          errorDescription = "";
                        });
                      },
                    ),
                    SizedBox(height: space),
                    errorState ? Text("$errorDescription") : Container(),
                    errorState ? SizedBox(height: space) : Container(),
                    loading
                        ? CircularProgressIndicator()
                        : AirButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _reset();
                              }
                            },
                            text: Text(
                                '${AppLocalizations.of(context).translate("continue")}'),
                          )
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: MediaQuery.of(context).size.width * 0.4,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    height: space,
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate("aResetLinkHasBeenSentTo")} ${emailController.text}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: space * 2),
                  loading
                      ? CircularProgressIndicator() : AirButton(
                    onPressed: () {
                      _reset();
                    },
                    text: Text(
                        '${AppLocalizations.of(context).translate("submitANewResetLink")}'),
                    icon: Icons.refresh,
                  ),
                  SizedBox(height: space * 2),
                  Container(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "${AppLocalizations.of(context).translate("back")}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _reset() {
    setState(() {
      loading = true;
      errorState = false;
      errorDescription = "";
    });
    AuthService().resetPassword(emailController.text).then((value) {
      setState(() {
        loading = false;
        emailSent = true;
      });
    }).catchError((error) {
      setState(() {
        loading = false;
        errorState = true;
        errorDescription = error.toString();
      });
    });
  }
}
