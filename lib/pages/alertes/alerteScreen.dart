import 'dart:ui';

import 'package:aircolis/components/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AlerteScreen extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const AlerteScreen({Key key, @required this.documentSnapshot})
      : super(key: key);

  @override
  _AlerteScreenState createState() => _AlerteScreenState();
}

class _AlerteScreenState extends State<AlerteScreen> {

  _deleteAlert() async {
    var collection = FirebaseFirestore.instance.collection('alertes').doc(widget.documentSnapshot.id);
    await collection.delete();
    _successDialog();
  }


  void _successDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            //width: MediaQuery.of(context).size.width -100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'L\'alerte a été supprimée.', textAlign: TextAlign.center,),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: InkWell(
                    child: Text('OK'),
                    onTap: () {
                      var count = 0;
                      Navigator.of(context).popUntil((context) {
                        return count++ == 2;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void confirmSuppression() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            //width: MediaQuery.of(context).size.width -100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirmer la suppression de l\'alerte', textAlign: TextAlign.center,),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                        child: Text('Oui', style: TextStyle(color: Colors.red[300]),),
                        onTap: () {
                          _deleteAlert();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                        child: Text('Non'),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var depart = widget.documentSnapshot.get("depart");
    var arrivee = widget.documentSnapshot.get("arrivee");
    var alertUser = widget.documentSnapshot.get("uid");
    var uid = FirebaseAuth.instance.currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Alerte voyage"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flight_takeoff),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Départ",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline6
                          .copyWith(color: Colors.black),
                    ),
                    Text("${depart['city']}"),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(Icons.flight_land),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Arrivée",
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline6
                          .copyWith(color: Colors.black),
                    ),
                    Text("${arrivee['city']}"),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            (alertUser == uid) ? AirButton(text: Text("Supprimer l'alerte"), onPressed: () {confirmSuppression();}, color: Colors.red[300], icon: Icons.delete, iconColor: Colors.red[200],) : Container()
          ],
        ),
      ),
    );
  }
}
