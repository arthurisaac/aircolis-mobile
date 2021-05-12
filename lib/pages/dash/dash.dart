import 'dart:ui';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/dash/dashHeader.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/pages/parcel/currentTasks.dart';
import 'package:aircolis/pages/parcel/detailsTask.dart';
import 'package:aircolis/pages/posts/myposts/myPostDetails.dart';
import 'package:aircolis/pages/posts/newPost/newPost.dart';
import 'package:aircolis/pages/posts/posts/postScreen.dart';
import 'package:aircolis/pages/propositions/allAcceptedProposalScreen.dart';
import 'package:aircolis/pages/propositions/allProposalScreen.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'confirmPackagePickupDialog.dart';

class DashScreen extends StatefulWidget {
  @override
  _DashScreenState createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {
  var showNotification = false;
  var travelTask = 0;
  var proposals = 0;
  var acceptedProposal = 0;
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    if (user == null) {
      AuthService().signOut().then((value) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginScreen()));
      }).catchError((onError) {
        print(onError.toString());
      });
    }
    if (user != null) {
      PostService().getAcceptedTravelTasks().then((value) {
        if (value.length > 0) {
          setState(() {
            acceptedProposal = value.length;
          });
        } else {
          PostService().getTravelTasks().then((value) {
            if (value.length > 0) {
              setState(() {
                showNotification = true;
                proposals = value.length;
              });
            }
          });
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
                    child: Column(
                      children: [
                        Text(
                            '${AppLocalizations.of(context).translate("noCurrentTask")}'),
                        SizedBox(height: space),
                        SvgPicture.asset(
                          "images/icons/box.svg",
                          height: 40,
                        ),
                        SizedBox(height: space),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => NewPost()));
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(padding)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        '${AppLocalizations.of(context).translate("postAnAd")}'),
                                    SizedBox(width: 7),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                } else {
                  var post = documents[0].get('post');
                  return (documents[0].get('isReceived'))
                      ? FutureBuilder(
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
                                      height: 15,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data
                                            .get('tracking')
                                            .length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            child: Row(
                                              children: [
                                                index == 0
                                                    ? Container()
                                                    : Container(
                                                        margin:
                                                            EdgeInsets.all(2),
                                                        height: 2,
                                                        width: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                40) /
                                                            (snapshot.data
                                                                .get('tracking')
                                                                .length),
                                                        color: (snapshot.data.get(
                                                                            'tracking')[
                                                                        index][
                                                                    'validated'] ==
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
                                                            10),
                                                  ),
                                                  width: 10,
                                                  height: 10,
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Align(
                                      child: InkWell(
                                        onTap: () {
                                          showCupertinoModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                //CurrentTasks(),
                                            DetailsTask(
                                              post: snapshot.data,
                                              proposal: documents[0],
                                            )
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
                              } else {
                                return Container(
                                  height: 100,
                                  child: Center(
                                    child: Text(
                                        '${AppLocalizations.of(context).translate("noCurrentTask")}'),
                                  ),
                                );
                              }
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Container(
                                  height: 100,
                                  child: Text(
                                      '${AppLocalizations.of(context).translate("noCurrentTask")}'),
                                ),
                              );
                            }

                            return CircularProgressIndicator();
                          },
                        )
                      : Container(
                          constraints: BoxConstraints(minHeight: 70),
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => CurrentTasks());
                                },
                                child: Text("Consulter vos propositions"),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  var result = await updateProposalReceived(
                                      documents[0]);
                                },
                                child: Text(
                                    '${AppLocalizations.of(context).translate("payNow")}'),
                              )
                            ],
                          ),
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
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          )
        : SomethingWentWrong(description: 'User not connected');
  }

  Future<AlertDialog> updateProposalReceived(post) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),
            ),
            content: ConfirmPackagePickupDialog(proposal: post),
          ),
        );
      },
    );
    /*Utils().showAlertDialog(context, 'Confirmation', 'Confirmez-vous avoir remis votre colis au voyageur?', () {
      var snapshot = FirebaseFirestore.instance.collection('posts').doc(id);
      Map<String, dynamic> data = {
        "isReceived": true,
      };

      snapshot.update(data).then((value) {
        Navigator.of(context).pop();
      }).catchError((onError) {
        print('Une erreur lors de l\'approbation: ${onError.toString()}');
      });
      Navigator.of(context).pop();
    });*/
  }

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
      body: (user != null)
          ? Container(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: space / 2,
                        ),
                        user.isAnonymous
                            ? Container(
                                margin: EdgeInsets.all(space),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CircleAvatar(
                                      radius: 30.0,
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                      child: Text(
                                        "?",
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : DashHeader(),
                      ],
                    ),
                  ),
                  Container(
                    //margin: EdgeInsets.all(20),
                    margin: EdgeInsets.only(
                        top: 130, left: 20, right: 20, bottom: 20),
                    padding: EdgeInsets.all(20),
                    //height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 0))
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: PostService().streamCurrentPost(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DocumentSnapshot> documents =
                                  snapshot.data.docs;
                              if (snapshot.data.size == 0) {
                                return Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Align(
                                      child: InkWell(
                                        onTap: () {
                                          showCupertinoModalBottomSheet(
                                            context: context,
                                            builder: (context) => MyPostDetails(
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
                            return Container(
                              constraints: BoxConstraints(minHeight: 100),
                              child: Text(
                                  '${AppLocalizations.of(context).translate("refreshing")}'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 300),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          travelTask > 0
                              ? Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: space),
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
                                    children: [Text('Vous avez des voyages')],
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
                                    margin: EdgeInsets.symmetric(
                                        horizontal: space, vertical: 5),
                                    padding: EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red[600],
                                      border: Border.all(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.circular(padding),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Vous avez des propositions',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          acceptedProposal > 0
                              ? InkWell(
                                  onTap: () {
                                    showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => CurrentTasks());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: space, vertical: 5),
                                    padding: EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.green[600],
                                      border: Border.all(color: Colors.green),
                                      borderRadius:
                                          BorderRadius.circular(padding),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Vous avez des propositions acceptées',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: space,
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: space),
                            child: Text(
                              'Tous les voyages',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6
                                  .copyWith(color: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: space,
                          ),
                          PostScreen(),
                        ],
                      ),
                    ),
                  ),

                  /*Positioned(
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
                                          child: travelDash(),
                                        );
                                      } else {
                                        DateTime departureDate = documents[0]
                                            .get('dateDepart')
                                            .toDate();
                                        String departureDateLocale =
                                            DateFormat.yMMMd(
                                                    '${AppLocalizations.of(context).locale}')
                                                .format(departureDate);
                                        DateTime arrivalDate = documents[0]
                                            .get('dateArrivee')
                                            .toDate();
                                        String arrivalDateLocale = DateFormat.yMMMd(
                                                '${AppLocalizations.of(context).locale}')
                                            .format(arrivalDate);
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                      '${documents[0].get('arrival')['city']}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                      fontWeight:
                                                          FontWeight.bold),
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
                              Text(
                                  'Vous avez des voyages')
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
                            margin:
                            EdgeInsets.symmetric(horizontal: space),
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
                              borderRadius: BorderRadius.circular(padding),
                            ),
                            child: Column(
                              children: [
                                Text(
                                    'Vous avez des propositions')
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
                        PostScreen()
                      ],
                    ),
                  )*/
                ],
              ),
            )
          : SomethingWentWrong(description: "Vous n'avez pas accès"),
    );
  }
}
