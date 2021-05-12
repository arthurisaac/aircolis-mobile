import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPostItem extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  const MyPostItem({Key key, this.documentSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Country arrivalCountry = Country.fromJson(documentSnapshot['arrival']);
    var today = DateTime.now();
    DateTime departureDate = documentSnapshot['dateDepart'].toDate();

    DateTime arrivalDate = documentSnapshot['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(arrivalDate);

    DateTime publishedDate = documentSnapshot['created_at'].toDate();
    String publishedDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(publishedDate);

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: space, vertical: space / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        //color: Colors.white,
        color: departureDate.isAfter(today) ? Colors.green : Colors.red,
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 1, offset: Offset(0, 0))
        ],
      ),
      //padding: EdgeInsets.all(defaultMargin),
      child: Container(
        margin: EdgeInsets.only(left: space / 2),
        padding: EdgeInsets.all(space),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${documentSnapshot.get('arrival')['city']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$arrivalDateLocale',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$publishedDateLocale',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
