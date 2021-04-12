import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostItem extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  const PostItem({Key key, this.documentSnapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime departureDate = documentSnapshot['dateDepart'].toDate();
    String departureDateLocale = DateFormat.yMMMd(
        '${AppLocalizations.of(context).locale}')
        .format(departureDate);
    DateTime arrivalDate = documentSnapshot['dateArrivee'].toDate();
    String arrivalDateLocale = DateFormat.yMMMd(
        '${AppLocalizations.of(context).locale}')
        .format(arrivalDate);
    DateTime today = DateTime.now();
    double height = space;

    return Container(
      //margin: EdgeInsets.symmetric(vertical: height),
      margin: EdgeInsets.symmetric(horizontal: height, vertical: height / 2),
      decoration: BoxDecoration(
        color: Color(0xFF1E2F47),
        borderRadius: BorderRadius.circular(padding),
        boxShadow: [
          BoxShadow(
              color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(height),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg-post.png'),
                alignment: Alignment.topRight
            )
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (departureDate.isBefore(today))
                    ? Text(
                  'Annonce dépassée', style: TextStyle(color: Colors.white),)
                    : Container(),
                Text(
                  '${documentSnapshot.get('departure')['city']}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text('$departureDateLocale',
                    style: TextStyle(color: Colors.white)),
                SizedBox(
                  height: height / 2,
                ),
                Text(
                  '${documentSnapshot.get('arrival')['city']}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text('$arrivalDateLocale',
                    style: TextStyle(color: Colors.white)),
                SizedBox(
                  height: height / 2,
                ),
                Divider(
                  height: 2,
                  color: Colors.white70,
                ),
                SizedBox(
                  height: height / 2,
                ),
                Text(
                  '${documentSnapshot['price']} ${Utils.getCurrencySize(documentSnapshot['currency'])} ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            Align(
                alignment: Alignment.topRight,
                child: (departureDate
                    .difference(today)
                    .inDays <= 0) ? Text(
                  '${AppLocalizations.of(context).translate("today")}',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold),) : Text('${departureDate
                    .difference(today)
                    .inDays} ${AppLocalizations.of(context).translate("days")}',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold),),
            )
          ],
        ),
      ),
    );
  }
}
