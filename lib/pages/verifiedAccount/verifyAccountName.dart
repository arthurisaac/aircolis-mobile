import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStepTwo.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class VerifyAccountName extends StatefulWidget {
  @override
  _VerifyAccountNameState createState() => _VerifyAccountNameState();
}

class _VerifyAccountNameState extends State<VerifyAccountName> {
  double height = space;
  var firstnameController = TextEditingController();
  var lastnameController = TextEditingController();
  var phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool errorState = false;
  String errorDescription;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
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
      body: Container(
        margin: EdgeInsets.only(left: height, right: height * 2),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 2),
              Container(
                width: double.infinity,
                child: Text(
                  'Complèter les informations de votre profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.05,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: space * 2,
                    ),
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
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)
                            .translate('phoneNumber'),
                        labelText: AppLocalizations.of(context)
                            .translate('phoneNumber'),
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
                    errorState
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$errorDescription',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red[300]),
                            ),
                          )
                        : Container(),
                    SizedBox(height: space * 2),
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
            ],
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
        .saveNewUser(firstnameController.text, lastnameController.text,
            phoneController.text)
        .then((value) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => VerifyAccountStep()));
    }).onError((error, stackTrace) {
      setState(() {
        errorState = true;
        errorDescription = error.toString();
      });
    });
  }
}
