import 'package:aircolis/pages/parcel/detailsTask.dart';
import 'package:aircolis/pages/parcel/paymentParcelScreen.dart';
import 'package:aircolis/pages/propositions/histories_proposals.dart';
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
  var today = DateTime.now();
  Stream _stream;

  @override
  void initState() {
    _stream = FirebaseFirestore.instance
        .collection('proposals')
        .where('uid', isEqualTo: uid)
        .where('isApproved', isEqualTo: true)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
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
            ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(space / 2),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HistoriesProposals()));
              },
              style: ElevatedButton.styleFrom(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(padding),
                ),
              ),
              child: Container(
                //width: double.infinity,
                padding: EdgeInsets.all(space / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Historiques des propositions"),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: space,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _stream,
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
                              /*String departureDateLocale = DateFormat.yMMMd(
                                      '${AppLocalizations.of(context).locale}')
                                  .format(departureDate);
                              String arrivalDateLocale = DateFormat.yMMMd(
                                      '${AppLocalizations.of(context).locale}')
                                  .format(arrivalDate);*/
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
                                                      return Text('Time over');
                                                    }
                                                    return Text(
                                                      '${time.days ?? 0} ${AppLocalizations.of(context).translate("days")} ${time.hours} : ${time.min}',
                                                      style: TextStyle(
                                                          color: Colors.white),
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
          ),
        ],
      ),
    );
  }
}
