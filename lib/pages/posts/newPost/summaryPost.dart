import 'dart:ui';

import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/models/Post.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryPost extends StatefulWidget {
  final String departureDate;
  final String departureTime;
  final String arrivingDate;
  final String arrivingTime;
  final Airport departure;
  final Airport arrival;
  final String notice;
  final String parcelHeight;
  final String parcelLength;
  final String parcelWeight;
  final String price;
  final String currency;
  final String paymentMethod;

  const SummaryPost({
    Key key,
    @required this.departureDate,
    @required this.departureTime,
    @required this.arrivingDate,
    @required this.arrivingTime,
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
  _SummaryPostState createState() => _SummaryPostState();
}

class _SummaryPostState extends State<SummaryPost> {
  bool isLoading = false;
  List<dynamic> tracking;

  @override
  void initState() {
    //getTrackingList();
    super.initState();
  }

  /*getTrackingList() async {
    var trackingDecode =  await json.decode(trackingStepRaw);
    setState(() {
      tracking = trackingDecode;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text(AppLocalizations.of(context).translate("parcel")),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(space),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: EdgeInsets.all(space),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(space),
                      color: Colors.white.withOpacity(0.8),
                      //boxShadow: shadowWhiteList,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate("summary"),
                          style: TextStyle(fontSize: space * 1.1),
                        ),
                        SizedBox(
                          height: space,
                        ),
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.flight_takeoff),
                                  SizedBox(width: space / 3),
                                  Text('${widget.departure.city}',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(widget.departureDate),
                                  SizedBox(width: space / 3),
                                  Text(widget.departureTime),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.flight_land),
                                  SizedBox(width: space / 3),
                                  Text(
                                    '${widget.arrival.city}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(width: space / 3),
                                  Text(widget.arrivingDate),
                                  SizedBox(
                                    width: space / 2,
                                  ),
                                  Text(widget.arrivingTime),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        Row(
                          children: [
                            Icon(Icons.payment_sharp),
                            SizedBox(width: space / 3),
                            Text('${widget.paymentMethod}'),
                          ],
                        ),
                        SizedBox(height: space / 2),
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${widget.parcelWeight}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(' Kg'),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(widget.parcelHeight),
                                  Text('x'),
                                  Text(widget.parcelLength),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: space / 2),
                        Text('${widget.notice}'),
                        Divider(
                          color: Colors.grey,
                        ),
                        Text(
                          '${widget.price} ${Utils.getCurrencySize(widget.currency)}',
                          style: TextStyle(
                            fontSize: space * 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            highlightColor: Theme.of(context).primaryColor,
            onTap: () {
              save();
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(space),
              margin: EdgeInsets.symmetric(horizontal: space),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(space),
                color: Colors.white.withOpacity(0.8),
              ),
              child: buttonState(),
            ),
          )
        ],
      ),
    );
  }

  Widget buttonState() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black,
        ),
      );
    } else {
      return Text(
        '${AppLocalizations.of(context).translate("publish")?.toUpperCase()}',
        style: TextStyle(
            //color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold),
      );
    }
  }

  save() async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('posts');
    DateFormat dateDepartFormat = DateFormat("yyyy-MM-dd");

    Post posts = Post(
      uid: uid,
      departure: widget.departure,
      arrival: widget.arrival,
      dateDepart: dateDepartFormat.parse(widget.departureDate),
      dateArrivee: dateDepartFormat.parse(widget.arrivingDate),
      heureDepart: widget.departureTime,
      heureArrivee: widget.arrivingTime,
      price: double.parse(widget.price),
      paymentMethod: widget.paymentMethod,
      parcelHeight: double.parse(widget.parcelHeight),
      parcelLength: double.parse(widget.parcelHeight),
      parcelWeight: double.parse(widget.parcelWeight),
      currency: widget.currency,
      createdAt: DateTime.now(),
      deletedAt: null,
      visible: true,
      isReceived: false,
      tracking: trackingStepRaw,
    );
    var data = posts.toJson();
    await userCollection.add(data).then((value) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }
}
