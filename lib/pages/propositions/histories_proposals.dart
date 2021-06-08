import 'package:aircolis/pages/propositions/edit_proposition_screen.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HistoriesProposals extends StatefulWidget {
  @override
  _HistoriesProposalsState createState() => _HistoriesProposalsState();
}

class _HistoriesProposalsState extends State<HistoriesProposals> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  Stream stream;

  @override
  void initState() {
    //_future = FirebaseFirestore.instance.collection('proposals').snapshots();
    stream = FirebaseFirestore.instance.collection('posts').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = space;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: space),
              child: Text(
                'Historique des propositions',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headline6
                    .copyWith(color: Colors.black, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, postsSnapshot) {
                  if (postsSnapshot.hasData) {
                    final List<DocumentSnapshot> postDocuments =
                        postsSnapshot.data.docs;

                    // Listes des annonces
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: postDocuments.length,
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
                                                proposal:
                                                    propositionDocuments[index],
                                              ));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: height / 2,
                                          horizontal: height),
                                      decoration: BoxDecoration(
                                          //color: Colors.white,
                                          gradient: !propositionDocuments[index]
                                                  .get("isApproved")
                                              ? LinearGradient(colors: [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context)
                                                      .primaryColorLight
                                                ])
                                              : LinearGradient(colors: [
                                                  Colors.green,
                                                  Colors.greenAccent
                                                ]),
                                          borderRadius:
                                              BorderRadius.circular(padding)),
                                      padding: EdgeInsets.symmetric(
                                          vertical: height / 2,
                                          horizontal: height),
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
                                                '${postDocuments[index]["arrival"]["city"]} ',
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

                            return Center(child: Text("..."));
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
                }),
          ],
        ),
      ),
    );
  }
}
