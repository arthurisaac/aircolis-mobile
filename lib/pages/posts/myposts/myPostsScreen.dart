import 'package:aircolis/pages/posts/myposts/myPostDetails.dart';
import 'package:aircolis/pages/posts/newPost/newPost.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'components/myPostItem.dart';

class MyPostsScreen extends StatefulWidget {
  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  var fabVisibility = true;
  Future _future;

  @override
  void initState() {
    _future = PostService().userPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: space * 2),
              Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: space),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).translate(
                                  "myPosts")}',
                              style: Theme
                                  .of(context)
                                  .primaryTextTheme
                                  .headline4
                                  .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              '${AppLocalizations.of(context).translate(
                                  "listOfYourPublishedPost")}',
                              style: Theme
                                  .of(context)
                                  .primaryTextTheme
                                  .headline6
                                  .copyWith(color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 110,
                      child: Image.asset(
                        "images/circle_group.png",
                        width: 110,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: space,
              ),
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.size == 0) {
                        return getList();
                      } else {
                        final List<DocumentSnapshot> documents =
                            snapshot.data.docs;
                        return ListView(
                          shrinkWrap: true,
                          children: documents
                              .map(
                                (doc) =>
                                InkWell(
                                  onTap: () async {
                                    final result = await Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MyPostDetails(
                                              doc: doc,
                                            ),
                                      ),
                                    );
                                    if (result != null && result == 'refresh') {
                                      print('refreshing posts...');
                                      setState(() {
                                        _future = PostService().userPosts();
                                      });
                                    }
                                  },
                                  child: MyPostItem(
                                    documentSnapshot: doc,
                                  ),
                                ),
                          )
                              .toList(),
                        );
                      }
                    }

                    if (snapshot.hasError) {
                      Text(
                          '${AppLocalizations.of(context).translate(
                              "anErrorHasOccurred")}');
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: fabVisibility
                ? Container(
              margin: EdgeInsets.only(bottom: space * 2),
              child: FloatingActionButton.extended(
                onPressed: () {
                  PostService().userPosts().then((event) {
                    if (event.size == 0) {
                      // TODO; Must pay, check subscription
                    }
                    /*AuthService().getUserDoc().then((value) {
                            if (value.exists && value.get('isVerified')) {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => PostFormScreen()));
                            } else {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => VerifyAccountScreen()));
                            }
                          });*/

                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => NewPost());
                    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPost()));
                  }).catchError((handleError) {
                    Utils.showSnack(context, handleError.toString());
                  });
                },
                label: Text(
                    '${AppLocalizations.of(context)
                        .translate("postAnAd")
                        .toUpperCase()}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                icon: Icon(
                  Icons.add_circle_rounded,
                  color: Colors.black,
                ),
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
              ),
            )
                : Container(),
          ),
        ],
      ),
    );
  }

  getList() {
    return Center(
      child: Stack(children: [
        Positioned(
          top: (MediaQuery
              .of(context)
              .size
              .height < 680.0) ? 0 : space * 2,
          //alignment: Alignment.center,
          child: (MediaQuery
              .of(context)
              .size
              .height < 680.0) ? Container(
            alignment: Alignment.center,
            width: MediaQuery
                .of(context)
                .size
                .width - 20,
            child: Lottie.asset('assets/sad-empty-box.json',
              fit: BoxFit.cover,
              repeat: false,
              width: 200,
              height: 200,
            ),
          ) : Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Lottie.asset('assets/sad-empty-box.json',
              fit: BoxFit.cover,
              repeat: false,
              width: 200,
              height: 200,
            ),
          ),
        ),
        Container(
          margin: (MediaQuery
              .of(context)
              .size
              .height < 680.0) ? EdgeInsets.all(0) : EdgeInsets.only(
              top: space * 6),
          width: MediaQuery
              .of(context)
              .size
              .width,
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context)
                .translate("youHaventPostedAnythingYet"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
    );
  }
}
