import 'package:aircolis/components/button.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';

class DetailsTask extends StatefulWidget {
  final DocumentSnapshot post;
  final DocumentSnapshot proposal;

  const DetailsTask({Key key, @required this.post, @required this.proposal})
      : super(key: key);

  @override
  _DetailsTaskState createState() => _DetailsTaskState();
}

class _DetailsTaskState extends State<DetailsTask> {
  bool isReceived = false;

  @override
  void initState() {
    isReceived = widget.proposal.get('isReceived');
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = space;

    DateTime departureDate = widget.post['dateDepart'].toDate();
    String departureDateLocale = DateFormat.yMMMd(
        '${AppLocalizations.of(context).locale}')
        .format(departureDate);

    String departureTimeLocale = DateFormat.Hm(
        '${AppLocalizations.of(context).locale}')
        .format(departureDate);

    DateTime arrivalDate = widget.post['dateArrivee'].toDate();
    String arrivalDateLocale = DateFormat.yMMMd(
        '${AppLocalizations.of(context).locale}')
        .format(arrivalDate);

    String arrivalTimeLocale = DateFormat.Hm(
        '${AppLocalizations.of(context).locale}')
        .format(arrivalDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context).translate("post")}"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.post.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: Column(
                  children: [
                    widget.post.get("tracking")[3]['validated'] ? Container(
                      padding: EdgeInsets.all(20),
                      child: Text("${AppLocalizations.of(context).translate("arrivalAtDestination")}", style: Theme.of(context).primaryTextTheme.headline6.copyWith(color: Colors.black),),
                    ) : Container(
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
                                  '${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
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
                    ),
                    Container(
                      margin: EdgeInsets.all(height),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(color: Colors.black),
                              children: [
                                TextSpan(text:
                                "${AppLocalizations.of(context).translate("destination")} : ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: "${widget.post.get('arrival')['name']}"),
                                TextSpan(text: " - "),
                                TextSpan(text: "${widget.post.get('arrival')['city']}"),
                              ],
                            ),

                          ),
                          SizedBox(
                            height: height / 2,
                          ),
                          Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context).translate("departureScheduledOn")}: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("$departureDateLocale $departureTimeLocale"),
                            ],
                          ),
                          SizedBox(
                            height: height / 2,
                          ),
                          Row(
                            children: [
                              Text(
                                  "${AppLocalizations.of(context).translate("expectedArrivalOn")} : ",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("$arrivalDateLocale $arrivalTimeLocale"),
                            ],
                          ),
                          SizedBox(
                            height: height,
                          ),
                          (widget.proposal["isReceived"] != null && !isReceived) ? Container(
                            margin: EdgeInsets.only(bottom: height),
                            child: AirButton(
                              onPressed: () {
                                updateProposalReceived();
                              },
                              text: Text('${AppLocalizations.of(context).translate("confirmPackagePickup")}'),
                              icon: Icons.check,
                              color: Colors.green,
                              iconColor: Colors.green[300],
                            ),
                          ) : Container(),
                          timeLine(),
                          SizedBox(
                            height: height / 2,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
              );
            }

            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
        ),
      ),
    );
  }

  /*Future<LatLng> getLocation() async {
    GetLocation getLocation = GetLocation();
    await getLocation.getCurrentLocationBest();
    //return LatLng(getLocation.latitude, getLocation.longitude);
    return LatLng(getLocation.latitude, getLocation.longitude);
  }*/

  Future<LatLng> getLocation() async {
    //DocumentSnapshot _user = await AuthService().getSpecificUserDoc(widget.proposal.get('uid'));
    // TODO
    /*if (_user.get('position') != null || _user.get('position') == 'null') {
      return LatLng(_user['position']['latitude'], _user['position']['longitude']);
    }*/

    String locationRaw = widget.post.get('departure')['location'];
    String locationEscape1 = locationRaw.replaceAll("(",'');
    String locationEscape = locationEscape1.replaceAll(")",'');
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
    DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
        .format(creationDate);
    return creationDateLocale;
  }

  void updateProposalReceived() {
    Utils().showAlertDialog(context, 'Confirmation', 'Confirmez-vous avoir remis votre colis au voyageur?', () {
      var snapshot = FirebaseFirestore.instance.collection('proposals').doc(widget.proposal.id);
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
      Navigator.of(context).pop();
    });

  }
}
