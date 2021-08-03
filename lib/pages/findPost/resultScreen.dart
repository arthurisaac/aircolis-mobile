import 'dart:convert';

import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/models/Country.dart';
import 'package:aircolis/pages/posts/posts/detailsPostScreen.dart';
import 'package:aircolis/pages/posts/posts/postItem.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SearchResultScreen extends StatefulWidget {
  final Airport departure;
  final Airport arrival;
  final String departureDate;

  const SearchResultScreen(
      {Key key,
      @required this.departure,
      @required this.arrival,
      @required this.departureDate})
      : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  Future _future;
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
    print(widget.departure.city);
    print(widget.arrival.city);
    if (widget.departureDate != null && widget.departureDate.isNotEmpty) {
      DateTime departureDate =
          DateFormat('yyyy-M-d hh:mm').parse(widget.departureDate + " 00:00");
      //Timestamp timestamp = Timestamp.fromDate(departureDate);
      _future = FirebaseFirestore.instance
          .collection('posts')
          .where('arrival.city', isEqualTo: widget.arrival.city)
          .where('departure.city', isEqualTo: widget.departure.city)
          .where('dateDepart', isGreaterThan: departureDate)
          .where('visible', isEqualTo: true)
          //.where('dateDepart', isGreaterThan: DateTime.now())
          .get();
    } else {
      _future = FirebaseFirestore.instance
          .collection('posts')
          .where('arrival.city', isEqualTo: widget.arrival.city)
          .where('departure.city', isEqualTo: widget.departure.city)
          .where('dateDepart', isGreaterThan: DateTime.now())
          .where('visible', isEqualTo: true)
          .get();
    }

    getJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context).translate("results")}'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: space),
        child: FutureBuilder<QuerySnapshot>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List<DocumentSnapshot> documents = snapshot.data.docs;
              if (documents.isEmpty) {
                return Container(
                  child: Center(
                    child: Text(
                      '${AppLocalizations.of(context).translate("noResult")}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline5
                          .copyWith(color: Colors.black),
                    ),
                  ),
                );
              } else {
                return ListView(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: documents
                      .map(
                        (doc) => InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailsPostScreen(
                                  doc: doc,
                                ),
                              ),
                            );
                          },
                          child: PostItem(
                            documentSnapshot: doc,
                            countries: listCountries,
                          ),
                        ),
                      )
                      .toList(),
                );
              }
            }
            if (snapshot.hasError) {
              return Container(
                child: Center(
                  child: Text(
                    '${AppLocalizations.of(context).translate("anErrorHasOccurred")}',
                  ),
                ),
              );
            }

            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
