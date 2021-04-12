import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TravellerScreen extends StatefulWidget {
  final String uid;

  const TravellerScreen({Key key, this.uid}) : super(key: key);

  @override
  _TravellerScreenState createState() => _TravellerScreenState();
}

class _TravellerScreenState extends State<TravellerScreen> {
  var usersCollection = FirebaseFirestore.instance.collection('users');
  double height = space;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).translate("profile")}',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(height),
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              height: height,
            ),
            FutureBuilder(
              future: usersCollection.doc(widget.uid).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text(
                      "${AppLocalizations.of(context).translate("anErrorHasOccurred")}");
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data = snapshot.data.data();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StorageService().getPhoto(
                          context,
                          "${data['firstname'][0]}",
                          data['photo'],
                          size.width * 0.16,
                          size.width * 0.19),
                      SizedBox(height: height),
                      data['isVerified']
                          ? Text(
                              '${AppLocalizations.of(context).translate("verifiedAccount")}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            )
                          : Text(
                              '${AppLocalizations.of(context).translate("unVerifiedAccount")}'),
                      SizedBox(height: height * 2),
                      RichText(
                          text: TextSpan(
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headline4
                                  .copyWith(color: Colors.black),
                              children: [
                            TextSpan(
                                text:
                                    '${data['firstname'].toString().toUpperCase()} '),
                            TextSpan(
                                text:
                                    '${data['lastname'].toString().toUpperCase()}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ])),
                      SizedBox(
                        height: height / 2,
                      ),
                      Text('${data['email']}'),
                      SizedBox(height: 5),
                      InkWell(
                        child: Text('${data['phone']}'),
                        onTap: () {
                          _launchURL('tel:${data['phone']}');
                        },
                      ),
                      SizedBox(
                        height: height / 2,
                      ),
                    ],
                  );
                }
                return Text(
                  AppLocalizations.of(context).translate("loading"),
                  style: TextStyle(color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(_url) async =>
      await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
}
