import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/posts/myposts/components/proposalItem.dart';
import 'package:aircolis/services/postService.dart';
import 'package:aircolis/services/trackingService.dart';
import 'package:aircolis/pages/propositions/CustomDialogBox.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPostDetails extends StatefulWidget {
  final DocumentSnapshot doc;

  const MyPostDetails({Key key, this.doc}) : super(key: key);

  @override
  _MyPostDetailsState createState() => _MyPostDetailsState();
}

class _MyPostDetailsState extends State<MyPostDetails> {
  DocumentSnapshot doc;
  bool isApproved = false;

  _isApproved() {
    FirebaseFirestore.instance
        .collection('proposals')
        .where('post', isEqualTo: doc.id)
        .where('isApproved', isEqualTo: true)
        .get()
        .then((value) {
      if (value.size > 0) {
        setState(() {
          isApproved = true;
        });
      }
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  }

  @override
  void initState() {
    doc = widget.doc;
    _isApproved();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime departureDate = doc['dateDepart'].toDate();
    String departureDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(departureDate);

    String departureTimeLocale =
        DateFormat.Hm('${AppLocalizations.of(context).locale}')
            .format(departureDate);

    DateTime arrivalDate = doc['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(arrivalDate);

    String arrivalTimeLocale =
        DateFormat.Hm('${AppLocalizations.of(context).locale}')
            .format(arrivalDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).translate("tripDetails")}',
          style: TextStyle(color: Colors.black),
        ),
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop('back');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(space),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doc.get('departure')['city']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(departureDateLocale),
                          Text(" "),
                          Text(departureTimeLocale),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${doc.get('arrival')['city']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          Text(
                            arrivalDateLocale,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            arrivalTimeLocale,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              SizedBox(
                height: space,
              ),
              Row(
                children: [
                  Text("${AppLocalizations.of(context).translate("price")} : "),
                  Text(
                    '${doc['price']} ${Utils.getCurrencySize(doc['currency'])}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline6
                        .copyWith(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: space),
              FutureBuilder(
                future: nextStep(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> nextStep) {
                  if (nextStep.hasData) {
                    return ElevatedButton(
                      onPressed: () {
                        updateStep(nextStep.data);
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(padding),
                          ),
                          primary: Theme.of(context).primaryColor
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Confirmer ${nextStep.data}'),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(space)),
                                color: Theme.of(context).primaryColorLight,
                              ),
                              child: Icon(Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                    /*return AirButton(
                      text: Text('Confirmer ${nextStep.data}'),
                      onPressed: () {
                        updateStep(nextStep.data);
                      },
                    );*/
                  }

                  if (nextStep.hasError) {
                    print(nextStep.error);
                    return Text(
                        '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
                  }

                  return Container();
                },
              ),
              SizedBox(height: space),
              Divider(
                height: 2,
                color: Colors.black,
              ),
              SizedBox(height: space),

              Text(
                '${AppLocalizations.of(context).translate("proposal")}',
                style: Theme.of(context).primaryTextTheme.headline6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: space,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('proposals')
                    .where('post', isEqualTo: doc.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.size == 0) {
                      return Center(
                        child: Text('Aucune proposition'),
                      );
                    } else {
                      final List<DocumentSnapshot> documents =
                          snapshot.data.docs;
                      return ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: documents
                            .map(
                              (doc) => InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => CustomDialogBox(
                                    documentSnapshot: doc),
                              );
                            },
                            child: ProposalItem(doc: doc),
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

                  return Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                        child: Text("...")
                    ),
                  );
                },
              ),
              SizedBox(height: space * 2),
              Text(
                '${AppLocalizations.of(context).translate("parcelTracking")}',
                style: Theme.of(context).primaryTextTheme.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              timeLine(),
              SizedBox(
                height: space,
              ),
              AirButton(
                text: Text(
                    '${AppLocalizations.of(context).translate("deleteAd")}'),
                onPressed: () {
                    CollectionReference posts =
                    FirebaseFirestore.instance.collection('posts');
                  posts.doc(doc.id).delete().then((response) {
                    Navigator.pop(context, 'refresh');
                  });
                  /*Map<String, dynamic> data = {"isDeleted": true, "visible": false};
                  posts.doc(doc.id).update(data).then((response) {
                    Navigator.pop(context, 'refresh');
                  });*/
                },
                color: Colors.red,
                iconColor: Colors.red[300],
                icon: Icons.delete,
              ),
              /*isApproved
                  ? Container()
                  : AirButton(
                      text: Text(
                          '${AppLocalizations.of(context).translate("deleteAd")}'),
                      onPressed: () {
                        CollectionReference posts =
                            FirebaseFirestore.instance.collection('posts');
                        posts.doc(doc.id).delete().then((response) {
                          Navigator.pop(context, 'refresh');
                        });
                      },
                      color: Colors.red,
                      iconColor: Colors.red[300],
                      icon: Icons.delete,
                    ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget timeLine() {
    List<dynamic> tracking = doc['tracking'];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 280,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: tracking.length,
        itemBuilder: (context, index) {
          return Container(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      color: index == 0 ? Colors.white : Colors.black,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: tracking[index]['validated']
                              ? Theme.of(context).primaryColor
                              : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(50)),
                      child: Icon(
                        tracking[index]['validated']
                            ? Icons.check
                            : Icons.more_horiz,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 20,
                      color: index == tracking.length - 1
                          ? Colors.white
                          : Colors.black,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    //height: 100,
                    padding: EdgeInsets.all(space / 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tracking[index]['title']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text((tracking[index]['creation'] != null)
                            ? getCreation(tracking[index]['creation'])
                            : 'En attente')
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String getCreation(Timestamp creation) {
    DateTime creationDate = creation.toDate();
    String creationDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(creationDate);
    return creationDateLocale;
  }

  /* Widget timeLine() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 2,
                            height: 20,
                            color: index == 0 ? Colors.white : Colors.black,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 4, right: 4),
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: snapshot.data[index]['validated']
                                    ? Theme.of(context).primaryColor
                                    : Colors.blueGrey,
                                borderRadius: BorderRadius.circular(50)),
                            child: Icon(
                              snapshot.data[index]['validated']
                                  ? Icons.check
                                  : Icons.more_horiz,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 20,
                            color: index == snapshot.data.length - 1
                                ? Colors.white
                                : Colors.black,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          //height: 100,
                          padding: EdgeInsets.all(space / 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data[index]['title']}',
                                style:
                                TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('description')
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }

          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Text('something wrong');
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }*/

  Future<String> nextStep() async {
    String title;
    List<dynamic> data = doc['tracking'];
    await Future.wait(data.reversed.map((e) async {
      if (!e['validated']) {
        title = e['title'];
      }
    }));
    return title;
  }

  Future<void> updateStep(String title) async {
    TrackingService.updateTracking(title, doc).then((value) {
      Utils.showSnack(context, 'Vous avez marqué avoir terminé $title');
      PostService().getOnePost(widget.doc.id).then((value) {
        setState(() {
          doc = value;
        });
      }).onError((error, stackTrace) {
        Utils.showSnack(context, '${error.toString()}');
      });
    }).onError((error, stackTrace) {
      print(error.toString());
    });
  }
}
