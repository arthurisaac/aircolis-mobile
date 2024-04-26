import 'dart:convert';

import 'package:aircolis/models/Country.dart';
import 'package:aircolis/pages/alertes/alertePost.dart';
import 'package:aircolis/pages/alertes/alerteScreen.dart';
import 'package:aircolis/pages/alertes/alerte_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlertesScreen extends StatefulWidget {
  const AlertesScreen({Key? key}) : super(key: key);

  @override
  _AlertesScreenState createState() => _AlertesScreenState();
}

class _AlertesScreenState extends State<AlertesScreen> {
  late Stream _future;
  List<Countries> listCountries = <Countries>[];

  getJson() async {
    var countriesRaw = await rootBundle.loadString('assets/countries.json');
    List<dynamic> decodedJson = json.decode(countriesRaw);
    decodedJson.forEach((country) {
      Countries countries = Countries.fromJson(country);
      listCountries.add(countries);
    });
  }

  @override
  void initState() {
    _future = FirebaseFirestore.instance.collection('alertes').snapshots();
    getJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Alertes",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
          child: StreamBuilder(
        stream: _future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> documents = snapshot.data.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AlerteScreen(
                              documentSnapshot: documents[index])));
                    },
                    child: AlerteItem(
                      documentSnapshot: documents[index],
                      countries: listCountries,
                    ),
                  ),
                );
              },
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Une erreur s'est produite. Ressayer plustard"),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AlertePost()));
        },
      ),
    );
  }
}
