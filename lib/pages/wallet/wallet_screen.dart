import 'dart:ui';

import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  var currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  Stream stream;

  @override
  void initState() {
    stream = userCollection.doc(currentUser.uid).snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${AppLocalizations.of(context).translate("wallet")}",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var wallet = new Map<String, dynamic>.from(snapshot.data.data());
              if (snapshot.data.get("wallet") != null) {
                return Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        alignment: Alignment.bottomRight,
                        padding: EdgeInsets.all(space / 2),
                        decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: AssetImage("images/bg_wallet.jpg"), fit: BoxFit.cover)
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Votre revenu", style: Theme.of(context).primaryTextTheme.bodyText2,),
                            SizedBox(height: space / 2,),
                            Text(
                              "${snapshot.data.get("wallet")}\$ USD",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headline4
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: space,
                      ),
                      (wallet.containsKey("request"))
                          ? Text("Demande de retrait en cours...")
                          : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(padding),
                              ),
                              primary:
                              Theme.of(context).primaryColor),
                              onPressed: () {
                                request();
                              },
                              child: Text(
                                  "${AppLocalizations.of(context).translate("requestAWithdrawal")}"))
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    "Aucun portefeuille configuré",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.black),
                  ),
                );
              }
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  request() {
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection('requests');
    DocumentReference documentReferencer = userCollection.doc(currentUser.uid);

    final Map<String, dynamic> data = {
      'uid': currentUser.uid,
      'read': false,
      'method': ""
    };
    documentReferencer.set(data);
    Utils.alertAdminWithMail(currentUser.uid);
    updateRequestStatus();
  }

  updateRequestStatus() {
    var snapshot =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    Map<String, dynamic> data = {"request": true};
    snapshot.update(data).then((value) {
      _successDialog();
    }).catchError((onError) {
      Utils.showSnack(context,
          AppLocalizations.of(context).translate("anErrorHasOccurred"));
    });
  }

  void _successDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),
            ),
            content: Container(
              //width: MediaQuery.of(context).size.width -100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/success-burst.json',
                    repeat: false,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: space,
                  ),
                  Text('Votre requête a bien été envoyée.'),
                  SizedBox(
                    height: space,
                  ),
                  Container(
                    margin: EdgeInsets.all(space),
                    child: InkWell(
                      child: Text('OK'),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
