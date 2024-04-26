import 'dart:ui';

import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/dash/TravelCardItem.dart';
import 'package:aircolis/pages/dash/dashHeader.dart';
import 'package:aircolis/pages/findPost/findPostScreen.dart';
import 'package:aircolis/pages/parcel/currentTasks.dart';
import 'package:aircolis/pages/parcel/detailsTask.dart';
import 'package:aircolis/pages/posts/newPost/newPost.dart';
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
import 'package:flutter/services.dart';
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
  var currentPage = 0;

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
                List<DocumentSnapshot> documents = snapshot.data!.docs;
                if (snapshot.data?.size == 0) {
                  return Container(
                    child: Column(
                      children: [
                        Text(
                            '${AppLocalizations.of(context)!.translate("noCurrentTask")}'),
                        SizedBox(height: space * 2),
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
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(padding)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        '${AppLocalizations.of(context)!.translate("postAnAd")}'),
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
                                        '${AppLocalizations.of(context)!.locale}')
                                    .format(departureDate);
                                DateTime arrivalDate =
                                    snapshot.data.get('dateArrivee').toDate();
                                String arrivalDateLocale = DateFormat.yMMMd(
                                        '${AppLocalizations.of(context)!.locale}')
                                    .format(arrivalDate);
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${AppLocalizations.of(context)!.translate("parcelTracking")}',
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
                                                                .colorScheme
                                                                .secondary,
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
                                                  ));
                                        },
                                        child: Text(
                                          '${AppLocalizations.of(context)!.translate("seeMore")}',
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
                                        '${AppLocalizations.of(context)!.translate("noCurrentTask")}'),
                                  ),
                                );
                              }
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Container(
                                  height: 100,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.translate("noCurrentTask")}'),
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
                                  await updateProposalReceived(documents[0]);
                                },
                                child: Text(
                                    '${AppLocalizations.of(context)!.translate("payNow")}'),
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
                      '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}'),
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

  Future<dynamic> updateProposalReceived(post) {
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
  }

  Widget backgroundWidget() {
    var size = MediaQuery.of(context).size;
    double headerSize = 0.25;
    double radius = 50.0;
    return Container(
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
    );
  }

  Widget anonymousHeader() {
    return Container(
      margin: EdgeInsets.all(space),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              "?",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget travelTaskWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: space),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 0))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [Text('Vous avez des voyages')],
      ),
    );
  }

  Widget proposalWidget() {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => AllProposalScreen(),
        );
        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllProposalScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: space,
          vertical: space / 2,
        ),
        padding: EdgeInsets.all(space),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red[600],
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(padding),
        ),
        child: Column(
          children: [
            Text(
              'Vous avez des propositions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget acceptedProposalWidget() {
    return InkWell(
      onTap: () {
        showCupertinoModalBottomSheet(
            context: context, builder: (context) => CurrentTasks());
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: space, vertical: 5),
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[600],
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(padding),
        ),
        child: Column(
          children: [
            Text(
              'Vous avez des propositions acceptées',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget headerTitle(String title) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: space),
      child: Text(
        '$title',
        style: Theme.of(context)
            .primaryTextTheme
            .headline6
            ?.copyWith(color: Colors.black),
      ),
    );
  }

  Widget boxWidget() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: PostService().streamCurrentPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> documents = snapshot.data!.docs;

                if (documents.length <= 0) {
                  return emptyTask();
                } else {
                  if (documents.length == 1) {
                    return TravelCardItem(
                      document: documents[0],
                    );
                  } else {
                    return Container(
                      height: 200,
                     color: Colors.black12,
                     /* child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return TravelCardItem(
                            document: documents[index],
                          );
                        },
                        itemCount: documents.length,
                        itemWidth: MediaQuery.of(context).size.width * 0.94,
                        itemHeight: 200,
                        layout: SwiperLayout.STACK,
                      ),*/
                    );
                  }
                }
              }
              if (snapshot.hasError) {
                print(snapshot.error.toString());
                return Container(
                  child: Text(
                      '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}'),
                );
              }
              return loadingBox();
            },
          ),
        ],
      ),
    );
  }

  Widget emptyTask() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 0))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${AppLocalizations.of(context)!.translate("areYouOnATrip")}"),
          SizedBox(height: space * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  showCupertinoModalBottomSheet(
                      context: context, builder: (context) => NewPost());
                  /*Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => NewPost()));*/
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(padding)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          '${AppLocalizations.of(context)!.translate("postAnAd")}'),
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
          ),
        ],
      ),
    );
  }

  Widget loadingBox() {
    return Container(
      margin: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 0))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: 100),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget searchBox() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => FindPostScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: space),
        padding: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text("Rechercher un voyage"), Icon(Icons.search)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: (user != null)
          ? SingleChildScrollView(
              child: Stack(
                children: [
                  backgroundWidget(),
                  Column(
                    children: [
                      user!.isAnonymous ? anonymousHeader() : DashHeader(),
                      searchBox(),
                      boxWidget(),
                      travelTask > 0 ? travelTaskWidget() : Container(),
                      proposals > 0 ? proposalWidget() : Container(),
                      acceptedProposal > 0
                          ? acceptedProposalWidget()
                          : Container(),
                      SizedBox(
                        height: space,
                      ),
                      headerTitle('Tous les voyages'),
                      SizedBox(
                        height: space,
                      ),
                      PostScreen(),
                    ],
                  ),
                ],
              ),
            )
          : SomethingWentWrong(description: "Vous n'avez pas accès"),
    );
  }
}

/*
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
                  ),
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: PostService().streamCurrentPost(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DocumentSnapshot> documents =
                                  snapshot.data.docs;

                              if (documents.length <= 0) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      top: 130,
                                      left: 20,
                                      right: 20,
                                      bottom: 20),
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  constraints: BoxConstraints(minHeight: 150),
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          "${AppLocalizations.of(context)!.translate("areYouOnATrip")}"),
                                      SizedBox(height: space * 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NewPost()));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .accentColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          padding)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      '${AppLocalizations.of(context)!.translate("postAnAd")}'),
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
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                if (documents.length == 1) {
                                  return TravelCardItem(
                                    document: documents[0],
                                  );
                                } else {
                                  return Container(
                                    child: Swiper(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return TravelCardItem(
                                          document: documents[index],
                                        );
                                      },
                                      itemCount: documents.length,
                                      itemWidth:
                                      MediaQuery.of(context).size.width * 0.94,
                                      itemHeight: 320,
                                      layout: SwiperLayout.STACK,
                                    ),
                                  );
                                }

                              }
                            }
                            if (snapshot.hasError) {
                              print(snapshot.error.toString());
                              return Container(
                                child: Text(
                                    '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}'),
                              );
                            }
                            return Container(
                              constraints: BoxConstraints(minHeight: 100),
                              child: Text(
                                  '${AppLocalizations.of(context)!.translate("refreshing")}'),
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
                                      horizontal: space,
                                      vertical: space / 2,
                                    ),
                                    padding: EdgeInsets.all(space),
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
                                            fontWeight: FontWeight.bold,
                                          ),
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
                  Column(
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
                ],
              ),
            )
          : SomethingWentWrong(description: "Vous n'avez pas accès"),
 */