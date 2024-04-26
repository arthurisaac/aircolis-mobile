import 'package:aircolis/pages/user/profile.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashHeader extends StatelessWidget {
  const DashHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');
    final User? _user = FirebaseAuth.instance.currentUser;
    return Container(
      margin: EdgeInsets.all(space),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (_user != null)
              ? FutureBuilder(
                  future: userCollection.doc(_user.uid).get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      DocumentSnapshot<Object?> data = snapshot.data!;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen()));
                        },
                        child: StorageService().getPhoto(
                            context,
                            //data['firstname'][0] + '' + data['lastname'][0],
                            "${(data['firstname'] == null) ? '!' : data['firstname'][0]}${(data['lastname'] == null || data['lastname'] == '') ? '' : data['lastname'][0]}",
                            '${data['photo']}',
                            18.0,
                            30.0),
                      );
                    }
                    // return Text(AppLocalizations.of(context).translate("loading"));
                    return CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.grey[300],
                    );
                  },
                )
              : InkWell(
                  onTap: () {
                    AuthService().signOut();
                  },
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.red,
                  ),
                )
        ],
      ),
    );
  }
}
