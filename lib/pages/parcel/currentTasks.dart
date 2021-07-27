import 'package:aircolis/pages/parcel/detailsTask.dart';
import 'package:aircolis/pages/parcel/paymentParcelScreen.dart';
import 'package:aircolis/pages/propositions/edit_proposition_screen.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CurrentTasks extends StatefulWidget {
  final bool showBack;

  const CurrentTasks({Key key, this.showBack = true}) : super(key: key);

  @override
  _CurrentTasksState createState() => _CurrentTasksState();
}

class _CurrentTasksState extends State<CurrentTasks> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  DateTime today = DateTime.now();
  List<Map<String, DocumentSnapshot>> currentsParcels = [];
  List<Map<String, DocumentSnapshot>> oldParcels = [];
  Stream stream;


  @override
  void initState() {
    stream = FirebaseFirestore.instance.collection('posts').snapshots();
    FirebaseFirestore.instance
        .collection('proposals')
        .where('uid', isEqualTo: uid)
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((event) async {
      final List<DocumentSnapshot> documents = event.docs;
      await Future.wait(documents.map((e) async {
        Map<String,DocumentSnapshot> entry = new Map<String,DocumentSnapshot>();
        var post = await FirebaseFirestore.instance.collection("posts").doc(e.get("post")).get();
        entry["post"] = post;
        entry["proposal"] = e;
        DateTime arrivalDate = post['dateArrivee'].toDate();
        if (today.isAfter(arrivalDate)) oldParcels.add(entry);
        if (today.isBefore(arrivalDate)) currentsParcels.add(entry);
      }));
      setState(() {});

    }).toList();

    /*_stream = FirebaseFirestore.instance
        .collection('proposals')
        .where('uid', isEqualTo: uid)
        .where('isApproved', isEqualTo: true)
        .snapshots();*/

    super.initState();
  }

  Widget allParcels() {
    const height = space;
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, postsSnapshot) {
          if (postsSnapshot.hasData) {
            final List<DocumentSnapshot> postDocuments =
                postsSnapshot.data.docs;

            // Listes des annonces
            return ListView.builder(
              shrinkWrap: true,
              itemCount: postDocuments.length,
              //physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int indexPost) {
                // Liste des propositions
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('proposals')
                      .where('uid', isEqualTo: uid)
                      .where("post",
                      isEqualTo: postDocuments[indexPost].id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var propositionDocuments = snapshot.data.docs;
                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: propositionDocuments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    EditProposalScreen(
                                      post: postDocuments[indexPost],
                                      proposal: propositionDocuments[index],
                                    ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                vertical: height / 2,
                                horizontal: height,
                              ),
                              decoration: BoxDecoration(
                                //color: Colors.white,
                                  gradient: propositionDocuments[index]
                                      .get("isApproved")
                                      ? LinearGradient(colors: [
                                    Colors.green,
                                    Colors.greenAccent
                                  ])
                                      : LinearGradient(colors: [
                                    Theme.of(context)
                                        .primaryColor,
                                    Theme.of(context)
                                        .primaryColorLight
                                  ]),
                                  borderRadius:
                                  BorderRadius.circular(padding)),
                              padding: EdgeInsets.symmetric(
                                vertical: height / 2,
                                horizontal: height,
                              ),
                              child: Row(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyText1,
                                      children: [
                                        TextSpan(
                                          text:
                                          '${propositionDocuments[index].get('weight').toStringAsFixed(0)}',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headline2
                                              .copyWith(
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(text: ' Kg')
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: space),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${postDocuments[indexPost]["arrival"]["city"]} ',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headline6
                                            .copyWith(
                                            color: Colors.black),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                          '${propositionDocuments[index].get('length').toInt()} cm x ${propositionDocuments[index].get('height').toInt()} cm'),
                                      Container(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.5,
                                        child: Text(
                                          '${propositionDocuments[index].get('description')}',
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Container();
                  },
                );
              },
            );
          }
          if (postsSnapshot.hasError) {
            return Container(
              margin: EdgeInsets.all(height / 2),
              child: Center(
                child: Text(
                  '${AppLocalizations.of(context).translate("anErrorHasOccurred")}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headline5
                      .copyWith(color: Colors.black),
                ),
              ),
            );
          }
          return Center(
            child: Text(
              '${AppLocalizations.of(context).translate("refreshing")}',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline5
                  .copyWith(color: Colors.black),
            ),
          );
        });
  }

  Widget current() {
    return currentsParcels.isNotEmpty ? ListView.builder(
      itemCount: currentsParcels.length,
      itemBuilder: (BuildContext context, int index) {
        var parcel = currentsParcels[index];
        DateTime arrivalDate = parcel["post"]['dateArrivee'].toDate();
        DateTime departureDate = parcel["post"]['dateDepart'].toDate();
        return Container(
          margin: EdgeInsets.all(space / 2),
          child: InkWell(
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => DetailsTask(
                  post: parcel["post"],
                  proposal: parcel["proposal"],
                ),
              );
             /* if (oldParcels[index]["proposal"]["canUse"]) {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => DetailsTask(
                    post: parcel["post"],
                    proposal: parcel["proposal"],
                  ),
                );
              } else {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return PaymentParcelScreen(
                      post: parcel["post"],
                      proposal: parcel["proposal"],
                    );
                  },
                );
              }*/
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: space, vertical: 14),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(padding),
                gradient: LinearGradient(
                  colors: [
                    Colors.green[300],
                    Colors.green[200]
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).translate("yourParcelLeavingFor")}',
                  ),
                  SizedBox(height: 5,),
                  Text(
                    '${parcel['post']['arrival']['city']}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.black),
                  ),
                  SizedBox(height: 5,),
                  (today.isAfter(arrivalDate))
                      ? Text("Délai expiré")
                      : Row(
                    children: [
                      Text(
                          "${AppLocalizations.of(context).translate("in")} "),
                      CountdownTimer(
                        textStyle: TextStyle(
                            color: Colors.white),
                        endTime: departureDate
                            .millisecondsSinceEpoch,
                        widgetBuilder: (_,
                            CurrentRemainingTime
                            time) {
                          if (time == null) {
                            return Text(
                                'Date arrivée dépassée');
                          }
                          return Text(
                            '${time.days ?? 0} ${AppLocalizations.of(context).translate("days")} ${time.hours} : ${time.min}',
                            style: TextStyle(
                                color:
                                Colors.black, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },

    ) : Center(child: Text("Aucun colis en cours"));
  }

  Widget old() {
    return oldParcels.isNotEmpty ? ListView.builder(
      itemCount: oldParcels.length,
      itemBuilder: (BuildContext context, int index) {
        var parcel = oldParcels[index];
        DateTime arrivalDate = parcel["post"]['dateArrivee'].toDate();
        DateTime departureDate = parcel["post"]['dateDepart'].toDate();
        return Container(
          margin: EdgeInsets.all(space / 2),
          child: InkWell(
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => DetailsTask(
                  post: parcel["post"],
                  proposal: parcel["proposal"],
                ),
              );
             /* if (parcel["proposal"]["canUse"]) {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => DetailsTask(
                    post: parcel["post"],
                    proposal: parcel["proposal"],
                  ),
                );
              } else {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return PaymentParcelScreen(
                      post: parcel["post"],
                      proposal: parcel["proposal"],
                    );
                  },
                );
              }*/
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: space, vertical: 14),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(padding),
                gradient: LinearGradient(colors: [
                  Colors.red[300],
                  Colors.red[300],
                ]),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).translate("yourParcelLeavingFor")}',
                  ),
                  Text(
                    '${parcel['post']['arrival']['city']}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.black),
                  ),
                  (today.isAfter(arrivalDate))
                      ? Text("Délai expiré")
                      : Row(
                    children: [
                      Text(
                          "${AppLocalizations.of(context).translate("in")} "),
                      CountdownTimer(
                        textStyle: TextStyle(
                            color: Colors.white),
                        endTime: departureDate
                            .millisecondsSinceEpoch,
                        widgetBuilder: (_,
                            CurrentRemainingTime
                            time) {
                          if (time == null) {
                            return Text(
                                'Time over');
                          }
                          return Text(
                            '${time.days ?? 0} ${AppLocalizations.of(context).translate("days")} ${time.hours} : ${time.min}',
                            style: TextStyle(
                                color:
                                Colors.white),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },

    ) : Center(child: Text("Aucun colis en cours"));
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.showBack
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                centerTitle: true,
                title: Text(
                  '${AppLocalizations.of(context).translate("parcelTracking")}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headline6
                      .copyWith(color: Colors.black),
                ),
                brightness: Brightness.dark,
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
          bottom: TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.airplanemode_active_sharp,
                  color: Colors.black,
                ),
                text: "En cours",
              ),
              Tab(
                icon: Icon(
                  Icons.airplanemode_off_sharp,
                  color: Colors.black,
                ),
                text: "Anciens",
              ),
              Tab(
                icon: Icon(
                  Icons.directions_walk,
                  color: Colors.black,
                ),
                text: "Tous",
              ),
            ],
          ),
        )
            : AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                centerTitle: true,
                title: Text(
                  '${AppLocalizations.of(context).translate("parcelTracking")}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headline6
                      .copyWith(color: Colors.black),
                ),
                brightness: Brightness.dark,
                bottom: TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.airplanemode_active_sharp,
                        color: Colors.black,
                      ),
                      text: "En cours",
                    ),
                    Tab(
                      icon: Icon(
                        Icons.airplanemode_off_sharp,
                        color: Colors.black,
                      ),
                      text: "Anciens",
                    ),
                    Tab(
                      icon: Icon(
                        Icons.directions_walk,
                        color: Colors.black,
                      ),
                      text: "Tous",
                    ),
                  ],
                ),
              ),
        body: TabBarView(
          children: [
            /*StreamBuilder<QuerySnapshot>(
              stream: _streamEnCours,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data.docs;
                  if (snapshot.data.size == 0) {
                    return Center(
                      child: Text(
                        "Vous n'avez pas de colis en cours",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.all(space / 2),
                          child: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(documents[index]['post'])
                                .get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot2) {
                              if (snapshot2.hasData) {
                                DateTime departureDate =
                                    snapshot2.data['dateDepart'].toDate();
                                DateTime arrivalDate =
                                    snapshot2.data['dateArrivee'].toDate();

                                return InkWell(
                                  onTap: () {
                                    if (documents[index]["canUse"]) {
                                      showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => DetailsTask(
                                          post: snapshot2.data,
                                          proposal: documents[index],
                                        ),
                                      );
                                    } else {
                                      showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return PaymentParcelScreen(
                                            post: snapshot2.data,
                                            proposal: documents[index],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(space),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(padding),
                                      gradient: today.isAfter(arrivalDate)
                                          ? LinearGradient(colors: [
                                              Colors.red[600],
                                              Colors.redAccent
                                            ])
                                          : LinearGradient(
                                              colors: [
                                                Colors.green,
                                                Colors.greenAccent
                                              ],
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${AppLocalizations.of(context).translate("yourParcelLeavingFor")}',
                                        ),
                                        Text(
                                          '${snapshot2.data['arrival']['city']}',
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .headline6
                                              .copyWith(color: Colors.black),
                                        ),
                                        (today.isAfter(arrivalDate))
                                            ? Text("Délai expiré")
                                            : Row(
                                                children: [
                                                  Text(
                                                      "${AppLocalizations.of(context).translate("in")} "),
                                                  CountdownTimer(
                                                    textStyle: TextStyle(
                                                        color: Colors.white),
                                                    endTime: departureDate
                                                        .millisecondsSinceEpoch,
                                                    widgetBuilder: (_,
                                                        CurrentRemainingTime
                                                            time) {
                                                      if (time == null) {
                                                        return Text(
                                                            'Time over');
                                                      }
                                                      return Text(
                                                        '${time.days ?? 0} ${AppLocalizations.of(context).translate("days")} ${time.hours} : ${time.min}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              if (snapshot2.hasError) {
                                return Text(snapshot2.error);
                              }

                              return Container(
                                width: size.width,
                                height: space * 3,
                                padding: EdgeInsets.all(space * 2),
                                alignment: Alignment.center,
                                child: Center(
                                  child: Text(
                                    '${AppLocalizations.of(context).translate("loading")}',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                }
                if (snapshot.hasError) {
                  return Text(
                      '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
                }
                return Container(
                  width: size.width,
                  alignment: Alignment.center,
                  child: Text(
                      '${AppLocalizations.of(context).translate("loading")}'),
                );
              },
            ),*/
            current(),
            old(),
            allParcels()
          ],
        ),
      ),
    );
  }
}
