import 'package:aircolis/models/Country.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class MyPostItem extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final List<Countries> countries;

  const MyPostItem({Key key, @required this.documentSnapshot, this.countries})
      : super(key: key);

  @override
  _MyPostItemState createState() => _MyPostItemState();
}

class _MyPostItemState extends State<MyPostItem> {
  String countryFlag = "";

  getCountryFlag() {
    print("getting flag for ${widget.documentSnapshot["arrival"]["country"]}");
    print(widget.countries.length);

    widget.countries.forEach((country) {
      if (country.name == widget.documentSnapshot["arrival"]["country"]) {
        setState(() {
          countryFlag = country.fileUrl;
        });
        print(country.fileUrl);
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
    //Country arrivalCountry = Country.fromJson(documentSnapshot['arrival']);
    var today = DateTime.now();
    DateTime departureDate = widget.documentSnapshot['dateDepart'].toDate();

    DateTime arrivalDate = widget.documentSnapshot['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(arrivalDate);

    DateTime publishedDate = widget.documentSnapshot['created_at'].toDate();
    String publishedDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(publishedDate);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        //color: departureDate.isAfter(today) ? Colors.green : Colors.red[200]
        //border: Border.all(color: Colors.black),
        color: Colors.white,
        boxShadow: shadowListBlack,
        borderRadius: BorderRadius.circular(padding),
      ),
      child: Row(
        children: [
          (countryFlag.isNotEmpty)
              ? ClipOval(
                  clipper: MyClip(),
                  child: SvgPicture.network(
                    "https:$countryFlag",
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  radius: 45,
                  backgroundColor: Theme.of(context).accentColor,
                ),
          Column(
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
                        text:
                            '${widget.documentSnapshot.get('arrival')['city']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
              SizedBox(
                height: 6,
              ),
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
                          text: 'Date d\'arrivée: ',
                        ),
                        TextSpan(
                          text: '$arrivalDateLocale',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              departureDate.isAfter(today) ? Container(
                color: Colors.green,
                child: Text("En cours", style: TextStyle(color: Colors.white),),
              ) : Container(
                color: Colors.red[300],
                child: Text("Date dépassée", style: TextStyle(color: Colors.white),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 5, 0),
                child: Text(
                  'Publié le $publishedDateLocale',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyClip extends CustomClipper<Rect> {
  Rect getClip(Size size) {
    return Rect.fromLTWH(10, 0, 45, 45);
  }

  bool shouldReclip(oldClipper) {
    return false;
  }
}
