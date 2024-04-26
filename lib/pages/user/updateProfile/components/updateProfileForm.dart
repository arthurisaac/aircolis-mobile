import 'package:aircolis/components/button.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateProfileForm extends StatefulWidget {
  final Map<String, dynamic> data;

  const UpdateProfileForm({Key? key, required this.data}) : super(key: key);

  @override
  _UpdateProfileFormState createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  late BuildContext scaffoldContext;

  final TextEditingController lastname = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _dialogFormKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    lastname.text =
        widget.data.containsKey("lastname") ? widget.data['lastname'] : "";
    firstname.text =
        widget.data.containsKey("firstname") ? widget.data['firstname'] : "";
    emailAddress.text = FirebaseAuth.instance.currentUser!.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
    scaffoldContext = context;

    double height = space;
    scaffoldContext = context;
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: lastname,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('lastname'),
                hintText: AppLocalizations.of(context)!.translate('lastname'),
                errorText: null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                }
                return null;
              },
            ),
            SizedBox(
              height: space,
            ),
            TextFormField(
              controller: firstname,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('firstname'),
                hintText: AppLocalizations.of(context)!.translate('firstname'),
                errorText: null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                }
                return null;
              },
            ),
            SizedBox(
              height: height,
            ),
            TextFormField(
              controller: emailAddress,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)!.translate('emailAddress'),
                hintText:
                    AppLocalizations.of(context)!.translate('emailAddress'),
                errorText: null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              validator: (value) {
                /*bool emailValid =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);*/
                if (value!.isEmpty) {
                  return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                }
                /*if (!emailValid) {
                  return "Email non valide";
                }*/
                return null;
              },
            ),
            SizedBox(
              height: height,
            ),
            !isLoading
                ? AirButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile();
                      }
                    },
                    text: Text(
                        '${AppLocalizations.of(context)!.translate("save").toString()}'),
                  )
                : CircularProgressIndicator(),
            SizedBox(
              height: height,
            ),
          ],
        ),
      ),
    );
  }

  _updateProfile() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = FirebaseFirestore.instance.collection('users').doc(uid);
    Map<String, dynamic> data = {
      "email": emailAddress.text,
      "firstname": firstname.text,
      "lastname": lastname.text
    };

    if (emailAddress.text != widget.data['email']) {
      _displayPasswordDialog(context).then((value) {
        _saveUserWithEmail(data, snapshot);
      });
      //
    } else {
      _saveUserWithoutEmail(data, snapshot);
    }
  }

  _saveUserWithEmail(data, snapshot) {
    setState(() {
      isLoading = true;
    });

    AuthCredential credential = EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser!.email.toString(),
        password: password.text);

    FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential)
        .then((value) {
      FirebaseAuth.instance.currentUser!
          .updateEmail(emailAddress.text)
          .then((value) {
        FirebaseAuth.instance.currentUser!.sendEmailVerification();
        _saveUserWithoutEmail(data, snapshot);
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
        Utils.showSnack(
          context,
          AppLocalizations.of(context)!
              .translate("anErrorHasOccurred")
              .toString(),
        );
        print(onError.toString());
      });
    }).catchError((onError) {
      print(onError.toString());
      setState(() {
        isLoading = false;
      });
      Utils.showSnack(
        context,
        onError.toString(),
      );
    });
  }

  _saveUserWithoutEmail(data, snapshot) {
    setState(() {
      isLoading = true;
    });
    snapshot.update(data).then((value) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnack(
        context,
        AppLocalizations.of(context)!.translate("profileUpdated").toString(),
      );
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnack(
        context,
        AppLocalizations.of(context)!
            .translate("anErrorHasOccurred")
            .toString(),
      );
    });
  }

  Future<void> _displayPasswordDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Attention'),
          content: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pour continuer, veuillez confirmer votre mot de passe'),
                SizedBox(height: space),
                TextFormField(
                  obscureText: true,
                  enableSuggestions: false,
                  controller: password,
                  decoration: InputDecoration(
                      hintText:
                          "${AppLocalizations.of(context)!.translate('password')}"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                onPrimary: Colors.transparent,
                elevation: 0.0,
                shadowColor: Colors.transparent,
              ),
              child:
                  Text('${AppLocalizations.of(context)!.translate('cancel')}',
                      style: TextStyle(
                        color: Colors.black,
                      )),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                onPrimary: Colors.transparent,
                elevation: 0.0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: () {
                if (_dialogFormKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
