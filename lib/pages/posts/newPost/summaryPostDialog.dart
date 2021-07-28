import 'dart:ui';

import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/models/Post.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class SummaryPostDialog extends StatefulWidget {
  final String departureDate;
  //final String departureTime;
  final String arrivingDate;
  //final String arrivingTime;
  final Airport departure;
  final Airport arrival;
  final String notice;
  final String parcelHeight;
  final String parcelLength;
  final String parcelWeight;
  final String price;
  final String currency;
  final String paymentMethod;

  const SummaryPostDialog({
    Key key,
    @required this.departureDate,
    //@required this.departureTime,
    @required this.arrivingDate,
    //@required this.arrivingTime,
    @required this.departure,
    @required this.arrival,
    @required this.notice,
    @required this.parcelHeight,
    @required this.parcelLength,
    @required this.parcelWeight,
    @required this.price,
    @required this.currency,
    @required this.paymentMethod,
  }) : super(key: key);

  @override
  _SummaryPostDialogState createState() => _SummaryPostDialogState();
}

class _SummaryPostDialogState extends State<SummaryPostDialog> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate("summary"),
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline5
                        .copyWith(
                            color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: space,
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, size: 30),
                      SizedBox(width: space),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${widget.departure.city}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            height: space / 2,
                          ),
                          Text(widget.departureDate),
                        ],
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.flight_land,
                        size: 30,
                      ),
                      SizedBox(width: space),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${widget.arrival.city}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: space / 2,
                          ),
                          Text(widget.arrivingDate),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: space / 2,
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: space / 2,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: RichText(
                        text: TextSpan(
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyText2
                                .copyWith(color: Colors.black),
                            children: [
                          TextSpan(
                            text:
                                '${AppLocalizations.of(context).translate("methodOfPayment")} : ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '${widget.paymentMethod}'),
                        ])),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate('parcelWeight')} Maximum : ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyText2
                            .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.parcelWeight} Kg',
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text('${AppLocalizations.of(context).translate("Dimensions")}: ', style: TextStyle(fontWeight: FontWeight.bold),),
                        Text('${widget.parcelHeight} cm'),
                        Text(' x '),
                        Text('${widget.parcelLength} cm'),
                      ],
                    ),
                  ),
                  SizedBox(height: space / 2),
                  Divider(
                    color: Colors.grey,
                  ),
                  Text('Prix du kilo: '),
                  Text(
                    '${widget.price} ${Utils.getCurrencySize(widget.currency)}',
                    style: TextStyle(
                      fontSize: space * 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  //SizedBox(height: space),
                  !loading
                      ? GestureDetector(
                          onTap: () async {
                            //Navigator.of(context).pop();
                            setState(() {
                              loading = true;
                            });
                            if (loading) {
                              String uid =
                                  FirebaseAuth.instance.currentUser.uid;
                              CollectionReference postCollection =
                                  FirebaseFirestore.instance
                                      .collection('posts');
                              DateFormat dateFormat =
                                  DateFormat("yyyy-MM-dd hh:mm");
                              Post posts = Post(
                                uid: uid,
                                departure: widget.departure,
                                arrival: widget.arrival,
                                dateDepart: dateFormat
                                    .parse(widget.departureDate),
                                dateArrivee:
                                    dateFormat.parse(widget.arrivingDate),
                                price: double.parse(widget.price),
                                paymentMethod: widget.paymentMethod,
                                parcelHeight: double.parse(widget.parcelHeight),
                                parcelLength: double.parse(widget.parcelLength),
                                parcelWeight: double.parse(widget.parcelWeight),
                                currency: widget.currency,
                                createdAt: DateTime.now(),
                                deletedAt: null,
                                visible: true,
                                tracking: trackingStepRaw,
                                isFinished: false,
                                isDeleted: false,
                              );
                              var data = posts.toJson();
                              try {
                                await postCollection.add(data);
                                setState(() {
                                  loading = false;
                                });
                                _successDialog();
                              } catch (e) {
                                print(e);
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                            //_save();
                          },
                          child: Container(
                            margin: EdgeInsets.all(space),
                            child: Text(
                              "Enregistrer",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              loading = false;
                            });
                            int count = 0;
                            Navigator.of(context).popUntil((context) {
                              return count++ == 2;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(space),
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _successDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),
            ),
            content: Container(
              //width: MediaQuery.of(context).size.width -100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/success-burst.json',
                    repeat: false,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: space,),
                  Text('${AppLocalizations.of(context).translate("yourPublicationIsNowOnline")}'),
                  SizedBox(height: space,),
                  Container(
                    margin: EdgeInsets.all(space),
                    child: InkWell(
                      child: Text('OK'),
                      onTap: () {
                        var count = 0;
                        Navigator.of(context).popUntil((context) {
                          return count++ == 3;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
