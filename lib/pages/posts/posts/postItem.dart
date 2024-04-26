import 'package:aircolis/models/Country.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class PostItem extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final List<Countries> countries;

  const PostItem(
      {Key? key, required this.documentSnapshot, required this.countries})
      : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  String countryDepartFlag = "";
  String countryArriveFlag = "";

  getCountryFlag() {
    widget.countries.forEach((country) {
      if (country.name == widget.documentSnapshot["arrival"]["country"]) {
        setState(() {
          countryArriveFlag = country.fileUrl!;
        });
      }
      if (country.name == widget.documentSnapshot["departure"]["country"]) {
        setState(() {
          countryDepartFlag = country.fileUrl!;
        });
      }
    });
  }

  @override
  void initState() {
    getCountryFlag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime departureDate = widget.documentSnapshot['dateDepart'].toDate();
    String departureDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(departureDate);
    DateTime arrivalDate = widget.documentSnapshot['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(arrivalDate);
    DateTime today = DateTime.now();
    double height = space;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: height, vertical: height / 2),
      decoration: BoxDecoration(
        color: Color(0xFF1E2F47),
        borderRadius: BorderRadius.circular(padding),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(height),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg-post.png'),
                alignment: Alignment.topRight)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (departureDate.isBefore(today))
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Annonce dépassée',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container(),
                Row(
                  children: [
                    (countryDepartFlag.isNotEmpty)
                        ? ClipOval(
                            clipper: MyClip(7, 30, 30),
                            child: SizedBox(
                              width: 50,
                              child: SvgPicture.network(
                                "https:$countryDepartFlag",
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 45,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.documentSnapshot.get('departure')['city']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text('$departureDateLocale',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 2,
                ),
                Row(
                  children: [
                    (countryArriveFlag.isNotEmpty)
                        ? ClipOval(
                            clipper: MyClip(10, 30, 30),
                            child: SizedBox(
                              width: 50,
                              child: SvgPicture.network(
                                "https:$countryArriveFlag",
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                    SizedBox(
                      width: height / 2,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.documentSnapshot.get('arrival')['city']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text('$arrivalDateLocale',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.documentSnapshot['price']} ${Utils.getCurrencySize(widget.documentSnapshot['currency'])} ',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline6
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child:
                  /*(departureDate
                    .difference(today)
                    .inDays <= 0) ? Text(
                  '${AppLocalizations.of(context)!.translate("today")}',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold),) : Text('${departureDate
                    .difference(today)
                    .inDays} ${AppLocalizations.of(context)!.translate("days")}',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold),),*/
                  CountdownTimer(
                textStyle: TextStyle(color: Colors.white),
                endTime: departureDate.millisecondsSinceEpoch,
                widgetBuilder: (_, CurrentRemainingTime? time) {
                  if (time == null) {
                    return Text(
                      'Date dépassée',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  return Text(
                    '${time.days ?? 0} ${AppLocalizations.of(context)!.translate("days")} ${time.hours} : ${time.min}',
                    style: TextStyle(color: Colors.white),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyClip extends CustomClipper<Rect> {
  final double left;
  final double width;
  final double height;

  MyClip(this.left, this.width, this.height);

  Rect getClip(Size size) {
    return Rect.fromLTWH(left, 0, width, height);
  }

  bool shouldReclip(oldClipper) {
    return false;
  }
}
