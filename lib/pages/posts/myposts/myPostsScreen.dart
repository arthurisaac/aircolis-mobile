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
              SizedBox(height: space),
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
                              '${AppLocalizations.of(context).translate("myPosts")}',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              '${AppLocalizations.of(context).translate("listOfYourPublishedPost")}',
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
              SizedBox(height: space,),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: PostService().userPosts(),
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
                                (doc) => InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MyPostDetails(
                                          doc: doc,
                                        ),
                                      ),
                                    );
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
                          '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
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
                        PostService().userPosts().listen((event) {

                          if (event.size == 0) {
                            // TODO; Must pay, check subscription
                          }
                          showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => NewPost()
                          );

                        }).onError((handleError) {
                          Utils.showSnack(context, handleError.toString());
                        });

                        /*Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewPost(),
                          ),
                        );*/
                      },
                      label: Text(
                          '${AppLocalizations.of(context).translate("postAnAd").toUpperCase()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      icon: Icon(Icons.add_circle_rounded, color: Colors.white,),
                      backgroundColor: Theme.of(context).primaryColor,
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
          top: space * 2,
          //alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Lottie.asset('assets/sad-empty-box.json',
                fit: BoxFit.cover,
                repeat: true,
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: space * 5),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context).translate("youHaventPostedAnythingYet"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
    );
  }
}
