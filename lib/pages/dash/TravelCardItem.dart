import 'package:aircolis/pages/posts/myposts/myPostDetails.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TravelCardItem extends StatelessWidget {
  final DocumentSnapshot document;

  const TravelCardItem({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime departureDate = document.get('dateDepart').toDate();
    String departureDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(departureDate);
    DateTime arrivalDate = document.get('dateArrivee').toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(arrivalDate);

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 0))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppLocalizations.of(context)!.translate("youHaveATripInProgress")}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: space,
          ),
          Container(
            child: Row(
              children: [
                Text(
                  '${document.get('departure')['city']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${document.get('arrival')['city']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          SizedBox(
            height: space / 4,
          ),
          Container(
            child: Row(
              children: [
                Text('$departureDateLocale'),
                Text('$arrivalDateLocale'),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          SizedBox(
            height: space,
          ),
          Align(
            child: InkWell(
              onTap: () {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => MyPostDetails(
                    doc: document,
                  ),
                );
              },
              child: Text(
                '${AppLocalizations.of(context)!.translate("seeMore")}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            alignment: Alignment.bottomRight,
          ),
        ],
      ),
    );
  }
}
