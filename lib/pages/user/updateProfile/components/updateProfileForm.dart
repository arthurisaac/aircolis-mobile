import 'package:aircolis/components/button.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateProfileForm extends StatefulWidget {
  final Map<String, dynamic> data;
  const UpdateProfileForm({Key key, this.data}) : super(key: key);

  @override
  _UpdateProfileFormState createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  BuildContext scaffoldContext;

  final TextEditingController lastname = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController emailAddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;
    double height = space;

    scaffoldContext = context;
    lastname.text = widget.data['lastname'];
    firstname.text = widget.data['firstname'];
    emailAddress.text = widget.data['email'];
    return Container(
      child: Column(
        children: [
          TextFormField(
              controller: lastname,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('lastname'),
                hintText: AppLocalizations.of(context).translate('lastname'),
                errorText: null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              )),
          SizedBox(
            height: space,
          ),
          TextFormField(
              controller: firstname,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate('firstname'),
                hintText: AppLocalizations.of(context).translate('firstname'),
                errorText: null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              )),
          SizedBox(
            height: height,
          ),
          TextFormField(
              controller: emailAddress,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate('emailAddress'),
                hintText:
                    AppLocalizations.of(context).translate('emailAddress'),
                errorText: null,
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              )),
          SizedBox(
            height: height,
          ),
          AirButton(
            onPressed: () {
              _updateProfile();
            },
            text: Text('${AppLocalizations.of(context).translate("save").toUpperCase()}'),
          ),
          SizedBox(
            height: height,
          ),
          /*AirButtonOutline(onPress: () {
          }, text: AppLocalizations.of(context).translate("changePassword"),),*/
        ],
      ),
    );
  }

  _updateProfile() {
    final String uid = FirebaseAuth.instance.currentUser.uid;
    var snapshot = FirebaseFirestore.instance.collection('users').doc(uid);

    Map<String, dynamic> data = {
      "email": emailAddress.text,
      "firstname": firstname.text,
      "lastname": lastname.text
    };

    snapshot.update(data).then((value) {
      Utils.showSnack(context, AppLocalizations.of(context).translate("profileUpdated"),);
    }).catchError((onError) {
      Utils.showSnack(context,
          AppLocalizations.of(context).translate("anErrorHasOccurred"),);
    });
  }
}
