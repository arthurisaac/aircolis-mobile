import 'package:aircolis/utils/app_localizations.dart';
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
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        //color: Colors.white,
        color: departureDate.isAfter(today) ? Colors.green : Colors.red,
        //border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                style: Theme.of(context)
                    .primaryTextTheme
                    .bodyText2
                    .copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Destination: ',
                  ),
                  TextSpan(
                    text: '${documentSnapshot.get('arrival')['city']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
          ),
          SizedBox(height: 6,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Arrivée: ',
                    ),
                    TextSpan(
                      text: '$arrivalDateLocale',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(
                '$publishedDateLocale',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
