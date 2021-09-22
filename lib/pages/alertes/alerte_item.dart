import 'package:aircolis/models/Country.dart';
import 'package:aircolis/services/authService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlerteItem extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  final List<Countries> countries;

  const AlerteItem({Key key, @required this.documentSnapshot, this.countries}) : super(key: key);

  @override
  _AlerteItemState createState() => _AlerteItemState();
}

class _AlerteItemState extends State<AlerteItem> {
  String countryFlag = "";
  String userName = "Inconnu";

  getCountryFlag() {
    widget.countries.forEach((country) {
      if (country.name == widget.documentSnapshot["arrivee"]["country"]) {
        setState(() {
          countryFlag = country.fileUrl;
        });
      }
    });
  }

  getUser() async {
    var userDoc = await AuthService()
        .getSpecificUserDoc(widget.documentSnapshot.get("uid"));
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data();
      setState(() {
        userName = data.containsKey("firstname")
            ? userDoc.get("firstname")
            : "utilisateur inconnu";
      });
    }
  }

  @override
  void initState() {
    getCountryFlag();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(13),
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
                        text: 'Départ: ',
                      ),
                      TextSpan(
                        text:
                            '${widget.documentSnapshot.get('depart')['city']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
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
                            '${widget.documentSnapshot.get('arrivee')['city']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 5, 0),
                child: Text(
                  'Publié par $userName',
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
