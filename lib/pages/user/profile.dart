import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/auth/loginPopup.dart';
import 'package:aircolis/pages/others/about.dart';
import 'package:aircolis/pages/others/comingsoon.dart';
import 'package:aircolis/pages/user/updateProfile/updateProfile.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBack;

  const ProfileScreen({Key key, this.showBack = true}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  Future future;

  @override
  void initState() {
    future = userCollection.doc(currentUser.uid).get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return (currentUser == null || currentUser.isAnonymous) ? LoginPopupScreen(showBack: false) : Scaffold(
      appBar: widget.showBack
          ? AppBar(
              brightness: Brightness.light,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          : AppBar(
              brightness: Brightness.light,
              elevation: 0,
              toolbarHeight: 0,
              backgroundColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data.data();
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.all(space),
                  child: Row(
                    children: [
                      widget.showBack ? Container() : SizedBox(height: space),
                      Container(
                        child: StorageService().getPhoto(
                            context,
                            data['firstname'][0],
                            data['photo'],
                            size.width * 0.08,
                            size.width * 0.1),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: space),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data['lastname'].toString().toUpperCase()}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline5
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                              ),
                              SizedBox(
                                height: space / 3,
                              ),
                              Text(
                                '${data['firstname'].toString().toUpperCase() ?? ''}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6
                                    .copyWith(color: Colors.black),
                              ),
                              SizedBox(
                                height: space / 3,
                              ),
                              /*Text(
                                '${data['phone']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal
                                ),
                              )*/
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: space,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("rating"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("0"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("trip"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("0"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("parcel"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("0"),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: space,
                ),
                Container(
                  margin: EdgeInsets.all(space),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        color: Theme.of(context).accentColor,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UpdateProfile()));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: space),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate("editPersonalInformation"),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).accentColor,
                      ),
                      InkWell(
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => ComingSoon(),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: space),
                          width: double.infinity,
                          child: Text(
                            "Demander un retrait",
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).accentColor,
                      ),
                      InkWell(
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => About(),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: space),
                          child: Text(
                            "A propos de l'application",
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).accentColor,
                      ),
                      InkWell(
                        onTap: () {
                          final RenderBox box = context.findRenderObject();
                          Share.share('Une superbe application à te faire découvrir: Aircolis qui met en relation voyageurs et expéditeur de colis. A télécharger sur Google Play et App Store',
                              subject: 'Aircolis',
                              sharePositionOrigin:
                                  box.localToGlobal(Offset.zero) & box.size);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: space),
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              "Recommander l'application",
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).accentColor,
                      ),
                      InkWell(
                        onTap: () {
                          FirebaseAuth.instance.signOut().then((value) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: space, horizontal: 5),
                          child: Text(
                            AppLocalizations.of(context).translate("logout"),
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                  '${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
