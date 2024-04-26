import 'dart:convert';

import 'package:aircolis/models/Country.dart';
import 'package:aircolis/pages/posts/posts/detailsPostScreen.dart';
import 'package:aircolis/pages/posts/posts/postItem.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime today = DateTime.now();
  DateFormat dateDepartFormat = DateFormat("yyyy-MM-dd hh:mm");
  late Stream _stream;
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
    _stream = FirebaseFirestore.instance
        .collection('posts')
        .where('dateDepart', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .snapshots();

    getJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          //final List<DocumentSnapshot> documents = snapshot.data?.docs;
          //final documents = snapshot.data as List<DocumentSnapshot>;

          final documents = snapshot.data?.docs as List<DocumentSnapshot>;
          print(documents);
          if (documents.isEmpty) {
            return Container(
              child: Center(
                  child: Text(
                      '${AppLocalizations.of(context)!.translate("noListingsAvailable")}')),
            );
          }
          return ListView.builder(
              //physics: ClampingScrollPhysics(),
              //physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsPostScreen(
                          doc: documents[index],
                        ),
                      ),
                    );
                  },
                  child: PostItem(
                    documentSnapshot: documents[index],
                    countries: listCountries,
                  ),
                );
              });
        }

        if (snapshot.hasError) {
          Text(
              '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}');
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
