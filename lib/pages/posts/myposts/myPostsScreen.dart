import 'dart:convert';

import 'package:aircolis/models/Country.dart';
import 'package:aircolis/pages/posts/myposts/myPostDetails.dart';
import 'package:aircolis/pages/posts/newPost/newPost.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'components/myPostItem.dart';

class MyPostsScreen extends StatefulWidget {
  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isVisible = true;
  late Future<QuerySnapshot<Object?>>? _future;
  List<Countries> listCountries = <Countries>[];
  ScrollController _scrollController = new ScrollController();

  scrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });
  }

  getJson() async {
    var countriesRaw = await rootBundle.loadString('assets/countries.json');
    List<dynamic> decodedJson = json.decode(countriesRaw);
    decodedJson.forEach((country) {
      Countries countries = Countries.fromJson(country);
      listCountries.add(countries);
    });
  }

  @override
  void initState() {
    _future = PostService().userPosts();
    getJson();
    scrollListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '${AppLocalizations.of(context)!.translate("myPosts")}',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(
                        child: SizedBox(
                          child: CircularProgressIndicator(),
                          width: 20,
                          height: 20,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      Text(
                          '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}');
                    }

                    if (snapshot.data!.size == 0) {
                      return getList();
                    } else {
                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;
                      return ListView(
                        shrinkWrap: true,
                        controller: _scrollController,
                        children: documents
                            .map(
                              (doc) => InkWell(
                                onTap: () async {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MyPostDetails(
                                        doc: doc,
                                      ),
                                    ),
                                  );
                                  if (result != null && result == 'refresh') {
                                    print("refreshing request");
                                    setState(() {
                                      _future = PostService().userPosts();
                                    });
                                  }
                                },
                                child: MyPostItem(
                                  documentSnapshot: doc,
                                  countries: listCountries,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _isVisible
                ? Visibility(
                    visible: _isVisible,
                    child: Container(
                      margin: EdgeInsets.only(bottom: space),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          PostService().userPosts().then((event) {
                            showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => NewPost());
                            //Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPost()));
                          }).catchError((handleError) {
                            Utils.showSnack(context, handleError.toString());
                          });
                        },
                        label: Text(
                            '${AppLocalizations.of(context)!.translate("postAnAd")}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        icon: Icon(
                          Icons.add_circle_rounded,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            )),
                      ),
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
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context)!
              .translate("youHaventPostedAnythingYet")
              .toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
/*getList() {
    return Center(
      child: Stack(children: [
        Positioned(
          top: (MediaQuery.of(context).size.height < 680.0) ? 0 : space * 2,
          //alignment: Alignment.center,
          child: (MediaQuery.of(context).size.height < 680.0)
              ? Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width - 20,
                  child: Icon(
                    Icons.campaign_outlined
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  child: Icon(
                      Icons.campaign_outlined
                  ),
                ),
        ),
        Container(
          margin: (MediaQuery.of(context).size.height < 680.0)
              ? EdgeInsets.all(0)
              : EdgeInsets.only(top: space * 6),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context)
                !.translate("youHaventPostedAnythingYet"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
    );
  }*/
}
