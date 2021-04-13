import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/dash/dashHeader.dart';
import 'package:aircolis/pages/parcel/currentTasks.dart';
import 'package:aircolis/pages/posts/myposts/myPostDetails.dart';
import 'package:aircolis/pages/posts/posts/postScreen.dart';
import 'package:aircolis/pages/propositions/allProposalScreen.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class DashScreen extends StatefulWidget {
  @override
  _DashScreenState createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {
  var showNotification = false;
  var travelTask = 0;
  var proposals = 0;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    if (user == null) {
      AuthService().signOut().then((value) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
      }).catchError((onError) {
        print(onError.toString());
      });
    }
    if (user != null) {
      PostService().getTravelTasks().then((value) {
        if (value.length > 0) {
          setState(() {
            showNotification = true;
            proposals = value.length;
          });
        }
      });
      AuthService()
          .getSpecificUserDoc(FirebaseAuth.instance.currentUser.uid)
          .then((value) {
        if (!value.exists) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      });
    }

    super.initState();
  }

  Widget travelDash() {
    return (user != null)
        ? FutureBuilder<QuerySnapshot>(
            future: PostService().getProposal(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> documents = snapshot.data.docs;
                if (snapshot.data.size == 0) {
                  return Container(
                      child: Text(
                          '${AppLocalizations.of(context).translate("noCurrentTask")}'));
                } else {
                  var post = documents[0].get('post');
                  return FutureBuilder(
                    future: PostService().getOnePost(post),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.exists) {
                          DateTime departureDate =
                              snapshot.data.get('dateDepart').toDate();
                          String departureDateLocale = DateFormat.yMMMd(
                                  '${AppLocalizations.of(context).locale}')
                              .format(departureDate);
                          DateTime arrivalDate =
                              snapshot.data.get('dateArrivee').toDate();
                          String arrivalDateLocale = DateFormat.yMMMd(
                                  '${AppLocalizations.of(context).locale}')
                              .format(arrivalDate);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppLocalizations.of(context).translate("parcelTracking")}',
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
                                      '${snapshot.data.get('departure')['city']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${snapshot.data.get('arrival')['city']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                              ),
                              SizedBox(
                                height: space,
                              ),
                              Container(
                                height: 30,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        snapshot.data.get('tracking').length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        child: Row(
                                          children: [
                                            index == 0
                                                ? Container()
                                                : Container(
                                                    margin: EdgeInsets.all(2),
                                                    height: 2,
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                40) /
                                                            (snapshot.data
                                                                .get('tracking')
                                                                .length),
                                                    color: (snapshot.data.get(
                                                                        'tracking')[
                                                                    index]
                                                                ['validated'] ==
                                                            true)
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .accentColor,
                                                  ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: (snapshot.data.get(
                                                                      'tracking')[
                                                                  index]
                                                              ['validated'] ==
                                                          true)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.blueGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              width: 10,
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                              Align(
                                child: InkWell(
                                  onTap: () {
                                    showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => CurrentTasks(),
                                    );
                                  },
                                  child: Text(
                                    '${AppLocalizations.of(context).translate("seeMore")}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                alignment: Alignment.bottomRight,
                              ),
                            ],
                          );
                        } else {
                          return Text(
                              '${AppLocalizations.of(context).translate("noCurrentTask")}');
                        }
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                            child: Text(
                                '${AppLocalizations.of(context).translate("noCurrentTask")}'));
                      }

                      return CircularProgressIndicator();
                    },
                  );
                }
              }
              if (snapshot.hasError) {
                print(snapshot.error.toString());
                return Container(
                  child: Text(
                      '${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
                );
              }
              return Text(
                  '${AppLocalizations.of(context).translate("refreshing")}');
            },
          )
        : SomethingWentWrong(description: 'User not connected');
  }

  /* Widget travelDash() {
    return FutureBuilder<List<QuerySnapshot>>(
      future: PostService().getTravelTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<QuerySnapshot> documents = snapshot.data;
          if (snapshot.data.length == 0) {
            return Container(
              child: Text(
                  '${AppLocalizations.of(context).translate("noCurrentTask")}'),
            );
          } else {
            QueryDocumentSnapshot document = documents[0].docs[0];
            return FutureBuilder(
              future: PostService().getOnePost(document.get('post')),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  DateTime departureDate =
                      snapshot.data.get('dateDepart').toDate();
                  String departureDateLocale =
                      DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
                          .format(departureDate);
                  DateTime arrivalDate =
                      snapshot.data.get('dateArrivee').toDate();
                  String arrivalDateLocale =
                      DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
                          .format(arrivalDate);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate("proposal")}',
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
                              '${snapshot.data.get('departure')['city']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${snapshot.data.get('arrival')['city']}',
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
                              builder: (context) => CurrentTasks(),
                            );
                          },
                          child: Text(
                            '${AppLocalizations.of(context).translate("seeMore")}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        alignment: Alignment.bottomRight,
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text(
                      '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
                }

                return CircularProgressIndicator();
              },
            );
          }
        }
        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Container(
            child: Text(
                '${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
          );
        }
        return Text('${AppLocalizations.of(context).translate("refreshing")}');
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double headerSize = 0.25;
    double radius = 50.0;

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: (user != null) ? Container(
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              height: size.height * headerSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/bg.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: space / 2,
                  ),
                  Container(
                    child: DashHeader(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: size.height * (headerSize / 1.5),
              width: size.width,
              child: Column(
                children: [
                  Stack(children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      //height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              blurRadius: 20,
                              offset: Offset(0, 0))
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: PostService().streamCurrentPost(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<DocumentSnapshot> documents =
                                    snapshot.data.docs;
                                if (snapshot.data.size == 0) {
                                  return Container(
                                    /*child: Text(
                                          '${AppLocalizations.of(context).translate("noCurrentTask")}'),*/
                                    child: travelDash(),
                                  );
                                } else {
                                  DateTime departureDate =
                                      documents[0].get('dateDepart').toDate();
                                  String departureDateLocale = DateFormat.yMMMd(
                                          '${AppLocalizations.of(context).locale}')
                                      .format(departureDate);
                                  DateTime arrivalDate =
                                      documents[0].get('dateArrivee').toDate();
                                  String arrivalDateLocale = DateFormat.yMMMd(
                                          '${AppLocalizations.of(context).locale}')
                                      .format(arrivalDate);
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context).translate("youHaveATripInProgress")}',
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
                                              '${documents[0].get('departure')['city']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                '${documents[0].get('arrival')['city']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                              builder: (context) =>
                                                  MyPostDetails(
                                                doc: documents[0],
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '${AppLocalizations.of(context).translate("seeMore")}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        alignment: Alignment.bottomRight,
                                      ),
                                    ],
                                  );
                                }
                              }
                              if (snapshot.hasError) {
                                print(snapshot.error.toString());
                                return Container(
                                  child: Text(
                                      '${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
                                );
                              }
                              return Text(
                                  '${AppLocalizations.of(context).translate("refreshing")}');
                            },
                          ),
                        ],
                      ),
                    ),
                    showNotification
                        ? Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                margin: EdgeInsets.all(space / 2),
                                child: Lottie.asset(
                                  'assets/bell-notification.json',
                                  fit: BoxFit.cover,
                                  repeat: false,
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ]),
                  travelTask > 0
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: space),
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 20,
                                  offset: Offset(0, 0))
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('Vous avez $travelTask voyages en cours')
                            ],
                          ),
                        )
                      : Container(),
                  proposals > 0
                      ? InkWell(
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => AllProposalScreen(),
                            );
                            //Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllProposalScreen()));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: space),
                            padding: EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 20,
                                    offset: Offset(0, 0))
                              ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                    'Vous avez $proposals propositions en cours')
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  (travelTask > 0 || proposals > 0)
                      ? SizedBox(
                          height: space,
                        )
                      : Container(),
                  Container(
                    height: size.height * 0.45,
                    child: PostScreen(),
                  ),
                ],
              ),
            )
          ],
        ),
      ) : SomethingWentWrong(description: "Vous n'avez pas accès"),
    );
  }
}
