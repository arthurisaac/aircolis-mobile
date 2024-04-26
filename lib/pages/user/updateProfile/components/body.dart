import 'package:aircolis/pages/user/updateProfile/components/photoProfile.dart';
import 'package:aircolis/pages/user/updateProfile/components/updateProfileForm.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateBodyProfile extends StatelessWidget {
  // final User _user = FirebaseAuth.instance.currentUser;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: userCollection.doc(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data?.data() as Map<String, dynamic>;

            return Container(
              margin: EdgeInsets.all(space),
              child: Column(
                children: [
                  PhotoProfile(
                    avatar: (data.containsKey("firstname") &&
                            data['firstname'] != null)
                        ? data['firstname'][0]
                        : "!",
                    photo: data['photo'].toString(),
                  ),
                  SizedBox(
                    height: space,
                  ),
                  UpdateProfileForm(
                    data: data,
                  ),
                ],
              ),
            );
          }

          return Text(
            AppLocalizations.of(context)!.translate("loading").toString(),
            style: TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }
}
