import 'package:aircolis/pages/propositions/CustomDialogBox.dart';
import 'package:aircolis/pages/user/traveller.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AllProposalScreen extends StatefulWidget {
  @override
  _AllProposalScreenState createState() => _AllProposalScreenState();
}

class _AllProposalScreenState extends State<AllProposalScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<QuerySnapshot<Object?>>>? _future;

  @override
  void initState() {
    //_future = FirebaseFirestore.instance.collection('proposals').snapshots();
    _future = PostService().getTravelTasks();
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
                style: Theme.of(context).primaryTextTheme.headline6?.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w500),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<QuerySnapshot>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final List<DocumentSnapshot> documents =
                              snapshot.data![index].docs;

                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: documents.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CustomDialogBox(
                                      documentSnapshot: documents[index],
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: height / 2, horizontal: height),
                                  decoration: BoxDecoration(
                                      //color: Colors.white,
                                      gradient: !documents[index]
                                              .get("isApproved")
                                          ? LinearGradient(colors: [
                                              Theme.of(context).primaryColor,
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
                                      vertical: height / 2, horizontal: height),
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
                                                  '${documents[index].get('weight').toInt()}',
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .headline2!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            TextSpan(text: ' Kg')
                                          ])),
                                      SizedBox(width: space),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          /*Text(
                                            '${AppLocalizations.of(context)!.translate("proposal")[0].toUpperCase()}${AppLocalizations.of(context)!.translate("proposal").substring(1)} ',
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .headline6
                                                .copyWith(color: Colors.black),
                                          ),*/
                                          Container(
                                            child: FutureBuilder(
                                              future: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(documents[index]
                                                      .get('uid'))
                                                  .get(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<dynamic>
                                                      userSnapshot) {
                                                if (userSnapshot.hasData) {
                                                  return InkWell(
                                                    onTap: () {
                                                      showCupertinoModalBottomSheet(
                                                        context: context,
                                                        builder: (context) =>
                                                            TravellerScreen(
                                                          uid: documents[index]
                                                              .get('uid'),
                                                        ),
                                                      );
                                                    },
                                                    child: RichText(
                                                      text: TextSpan(
                                                          style: Theme.of(
                                                                  context)
                                                              .primaryTextTheme
                                                              .headline6!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black),
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    '${userSnapshot.data['lastname']} '),
                                                            TextSpan(
                                                                text:
                                                                    '${userSnapshot.data['firstname']}'),
                                                          ]),
                                                    ),
                                                  );
                                                }
                                                if (userSnapshot.hasError) {
                                                  print(userSnapshot.error
                                                      .toString());
                                                }
                                                return CircularProgressIndicator();
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                              '${documents[index].get('length').toInt()} x ${documents[index].get('height').toInt()}'),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: Text(
                                              '${documents[index].get('description')}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                        });
                  }
                  if (snapshot.hasError) {
                    return Container(
                      margin: EdgeInsets.all(height / 2),
                      child: Center(
                        child: Text(
                          '${AppLocalizations.of(context)!.translate("anErrorHasOccurred")}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline5!
                              .copyWith(color: Colors.black),
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      '${AppLocalizations.of(context)!.translate("refreshing")}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline5!
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
