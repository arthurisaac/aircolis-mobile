import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/user/traveller.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsTask extends StatefulWidget {
  final DocumentSnapshot post;
  final DocumentSnapshot proposal;

  const DetailsTask({Key? key, required this.post, required this.proposal})
      : super(key: key);

  @override
  _DetailsTaskState createState() => _DetailsTaskState();
}

class _DetailsTaskState extends State<DetailsTask> {
  bool isReceived = false;

  @override
  void initState() {
    if (!widget.proposal.exists && !widget.post.exists) {
      Navigator.of(context).pop();
    }
    if (!widget.proposal.get('isReceived')) {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        confirmDialog();
      });
    }
    isReceived = widget.proposal.get('isReceived');
    getLocation();
    super.initState();
  }

  confirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text("Consentement utilisateur"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text("Confirmer si vous avez remis votre colis au voyageur.")
              ],
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  'cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                _updatePick();
              },
              child: Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  "Confirmer",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = space;

    DateTime departureDate = widget.post['dateDepart'].toDate();
    String departureDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(departureDate);

    String departureTimeLocale =
        DateFormat.Hm('${AppLocalizations.of(context)!.locale}')
            .format(departureDate);

    DateTime arrivalDate = widget.post['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(arrivalDate);

    String arrivalTimeLocale =
        DateFormat.Hm('${AppLocalizations.of(context)!.locale}')
            .format(arrivalDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.translate("post")}"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.post.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: height, horizontal: height),
                        child: FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.post.get('uid'))
                              .get(),
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data as DocumentSnapshot;

                              return InkWell(
                                onTap: () {
                                  /* widget.proposal.get("canUse")
                                            ? showCupertinoModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    TravellerScreen(
                                                  uid: widget.post.get("uid"),
                                                ),
                                              )
                                            : Utils.showSnack(context,
                                                "Pour voir son profil, l'expéditeur doit régler son dû.");*/
                                  showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (context) => TravellerScreen(
                                      uid: widget.post.get("uid"),
                                    ),
                                  );
                                },
                                child: !data.exists
                                    ? Text("Author doesnt exist")
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          StorageService().getPhoto(
                                            context,
                                            data['firstname'][0],
                                            data['photo'],
                                            20,
                                            20.0,
                                          ),
                                          SizedBox(
                                            width: space,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${data['firstname']}',
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .headline6
                                                    ?.copyWith(
                                                        color: Colors.black),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  var _url =
                                                      "tel:${data['phone']}";
                                                  // ignore: deprecated_member_use
                                                  await canLaunch(_url)
                                                      // ignore: deprecated_member_use
                                                      ? await launch(_url)
                                                      : throw 'Could not launch $_url';
                                                },
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    var _url =
                                                        "mailto:${data['email']}?subject=Votre%20annonce%20sur%20aircolis";
                                                    // ignore: deprecated_member_use
                                                    await canLaunch(_url)
                                                        // ignore: deprecated_member_use
                                                        ? await launch(_url)
                                                        : throw 'Could not launch $_url';
                                                  },
                                                  child:
                                                      Text("${data['phone']}"),
                                                ),
                                              ),
                                              Text("${data['email']}"),
                                              Container(
                                                alignment: Alignment.center,
                                                child: RatingBar.builder(
                                                  initialRating: 3,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: 30,
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {
                                                    print(rating);
                                                    _updateRating(rating);
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  var _url =
                                                      "tel:${data['phone']}";
                                                  // ignore: deprecated_member_use
                                                  await canLaunch(_url)
                                                      // ignore: deprecated_member_use
                                                      ? await launch(_url)
                                                      : throw 'Could not launch $_url';
                                                },
                                                child: Text("Contacter"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              );
                            }
                            if (snapshot.hasError) {
                              print(snapshot.error.toString());
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(height, 0, height, height),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*widget.post.get("tracking")[3]['validated']
                                ? Container(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "${AppLocalizations.of(context)!.translate("arrivalAtDestination")}",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6
                                    .copyWith(color: Colors.black),
                              ),
                            )
                                : Container(),*/
                            /*Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: FutureBuilder(
                        future: getLocation(),
                        builder:
                            (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return FlutterMap(
                              options: MapOptions(
                                center: snapshot.data,
                                minZoom: 13.0,
                              ),
                              layers: [
                                TileLayerOptions(
                                    urlTemplate:
                                    "https://api.mapbox.com/styles/v1/arthur24/ckm0pyd0s9gfe17mw5z6go656/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYXJ0aHVyMjQiLCJhIjoiY2ttMHBucTBoNDZnaDJvbjFsbTk1eDIxNSJ9.C24PGzhtUIoRV8u_J6CHVw",
                                    additionalOptions: {
                                      'accessToken':
                                      'pk.eyJ1IjoiYXJ0aHVyMjQiLCJhIjoiY2ttMHBucTBoNDZnaDJvbjFsbTk1eDIxNSJ9.C24PGzhtUIoRV8u_J6CHVw',
                                      'id': 'ckm0pyd0s9gfe17mw5z6go656'
                                      //'mapbox.mapbox-streets-v7'
                                    }),
                                MarkerLayerOptions(
                                  markers: [
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: snapshot.data,
                                      builder: (ctx) => Container(
                                        child: Icon(
                                          Icons.location_history_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Center(
                              child: Text(
                                  '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}'),
                            );
                          }

                          return Container(
                            margin: EdgeInsets.all(20.0),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),*/
                            widget.post.get("tracking")[3]['validated']
                                ? Container()
                                : Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                          bottom: height,
                                        ),
                                        child: Text(
                                          "Voyage",
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headline6
                                              ?.copyWith(color: Colors.black),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.topLeft,
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .bodyText1
                                                ?.copyWith(color: Colors.black),
                                            children: [
                                              TextSpan(
                                                text:
                                                    "${AppLocalizations.of(context)!.translate("destination")} : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                      "${widget.post.get('arrival')['name']}"),
                                              TextSpan(text: " - "),
                                              TextSpan(
                                                  text:
                                                      "${widget.post.get('arrival')['city']}"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height / 2,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "${AppLocalizations.of(context)!.translate("departureScheduledOn")}: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              "$departureDateLocale $departureTimeLocale"),
                                        ],
                                      ),
                                      SizedBox(
                                        height: height / 2,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              "${AppLocalizations.of(context)!.translate("expectedArrivalOn")} : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              "$arrivalDateLocale $arrivalTimeLocale"),
                                        ],
                                      ),
                                    ],
                                  ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.symmetric(vertical: height),
                              child: Text(
                                "Historique",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6
                                    ?.copyWith(color: Colors.black),
                              ),
                            ),
                            timeLine(),
                            SizedBox(
                              height: height,
                            ),
                            (widget.proposal["isReceived"] != null &&
                                    !isReceived)
                                ? Container(
                                    margin: EdgeInsets.only(bottom: height),
                                    child: AirButton(
                                      onPressed: () {
                                        updateProposalReceived();
                                      },
                                      text: Text(
                                          '${AppLocalizations.of(context)!.translate("confirmPackagePickup")}'),
                                      icon: Icons.check,
                                      color: Colors.green,
                                      iconColor: Colors.green[300],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}'),
                );
              }

              return Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              );
            }),
      ),
    );
  }

  Future<LatLng> getLocation() async {
    String locationRaw = widget.post.get('departure')['location'];
    String locationEscape1 = locationRaw.replaceAll("(", '');
    String locationEscape = locationEscape1.replaceAll(")", '');
    var location = locationEscape.split(",");
    double latitude = double.parse(location[0]);
    double longitude = double.parse(location[1]);

    return LatLng(latitude, longitude);
  }

  Widget timeLine() {
    List<dynamic> tracking = widget.post['tracking'];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 280,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: tracking.length,
        itemBuilder: (context, index) {
          return Container(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      color: index == 0 ? Colors.white : Colors.black,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: tracking[index]['validated']
                              ? Theme.of(context).primaryColor
                              : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(50)),
                      child: Icon(
                        tracking[index]['validated']
                            ? Icons.check
                            : Icons.more_horiz,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 20,
                      color: index == tracking.length - 1
                          ? Colors.white
                          : Colors.black,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    //height: 100,
                    padding: EdgeInsets.all(space / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tracking[index]['title']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text((tracking[index]['creation'] != null)
                            ? getCreation(tracking[index]['creation'])
                            : 'En attente')
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String getCreation(Timestamp creation) {
    DateTime creationDate = creation.toDate();
    String creationDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context)!.locale}')
            .format(creationDate);
    return creationDateLocale;
  }

  void updateProposalReceived() {
    Utils().showAlertDialog(context, 'Confirmation',
        'Confirmez-vous avoir remis votre colis au voyageur?', () {
      _updatePick();
      Navigator.of(context).pop();
    });
  }

  void _updatePick() {
    var snapshot = FirebaseFirestore.instance
        .collection('proposals')
        .doc(widget.proposal.id);
    Map<String, dynamic> data = {
      "isReceived": true,
    };

    snapshot.update(data).then((value) {
      setState(() {
        isReceived = true;
      });
      Navigator.of(context).pop();
    }).catchError((onError) {
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
    });
  }

  void _updateRating(rate) {
    var snapshot = FirebaseFirestore.instance
        .collection('proposals')
        .doc(widget.proposal.id);
    Map<String, dynamic> data = {
      "rating": rate,
    };

    snapshot.update(data).then((value) {
      Utils.showSnack(context, "Merci pour votre retour");
    }).catchError((onError) {
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
    });
  }
}
