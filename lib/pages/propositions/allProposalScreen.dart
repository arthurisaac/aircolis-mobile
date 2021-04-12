import 'package:aircolis/pages/propositions/CustomDialogBox.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllProposalScreen extends StatefulWidget {
  @override
  _AllProposalScreenState createState() => _AllProposalScreenState();
}

class _AllProposalScreenState extends State<AllProposalScreen> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  Stream _future;

  @override
  void initState() {
    _future = FirebaseFirestore.instance.collection('proposals').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = space;

    return Scaffold(
      appBar: AppBar(
        title: Text("Propositions", style: TextStyle(color: Colors.black)),
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
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: _future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> documents = snapshot.data.docs;

                return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          /*showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => ProposalItemScreen(documentSnapshot: documents[index],),
                      );*/
                          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProposalItemScreen(documentSnapshot: documents[index],)));
                          showDialog(
                            context: context,
                            builder: (context) => CustomDialogBox(
                              documentSnapshot: documents[index],
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(height / 2),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    offset: Offset(0, 0))
                              ],
                              //color: Colors.white,
                              gradient: LinearGradient(colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColorLight
                              ]),
                              borderRadius: BorderRadius.circular(padding)),
                          padding: EdgeInsets.all(height),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${documents[index].get('weight')} Kg',
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headline4
                                      .copyWith(color: Colors.black)),
                              SizedBox(height: 4),
                              Text(
                                  '${documents[index].get('length')} x ${documents[index].get('height')}'),
                              SizedBox(height: 4),
                              Text('${documents[index].get('description')}'),
                              SizedBox(
                                height: height,
                              ),
                              /*Container(
                            alignment: Alignment.topRight,
                            child: Text(
                              '${AppLocalizations.of(context).translate("seeMore")}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),*/
                            ],
                          ),
                        ),
                      );
                    });
              }
              if (snapshot.hasError) {
                return Container(
                  margin: EdgeInsets.all(height / 2),
                  child: Center(
                    child: Text(
                        '${AppLocalizations.of(context).translate("anErrorHasOccurred")}', style: Theme.of(context).primaryTextTheme.headline5.copyWith(color: Colors.black),),
                  ),
                );
              }
              return Center(
                child: Text(
                    '${AppLocalizations.of(context).translate("refreshing")}', style: Theme.of(context).primaryTextTheme.headline5.copyWith(color: Colors.black),),
              );
            }),
      ),
    );
  }
}
