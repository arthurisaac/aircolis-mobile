import 'package:aircolis/pages/parcel/detailsTask.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CurrentTasks extends StatefulWidget {
  @override
  _CurrentTasksState createState() => _CurrentTasksState();
}

class _CurrentTasksState extends State<CurrentTasks> {
  String uid = FirebaseAuth.instance.currentUser.uid;
  Future _future;

  @override
  void initState() {
    //_future = getActiveParcels();
    _future = FirebaseFirestore.instance
        .collection('proposals')
        .where('uid', isEqualTo: uid)
        .where('isApproved', isEqualTo: true)
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('${AppLocalizations.of(context).translate("parcelTracking")}', style: Theme.of(context).primaryTextTheme.headline6.copyWith(color: Colors.black),),
        brightness: Brightness.dark,
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
        child:
        FutureBuilder<QuerySnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<DocumentSnapshot> documents = snapshot.data.docs;
              if (snapshot.data.size == 0) {
                return Container(
                  child: Text(
                    '${AppLocalizations.of(context).translate("noData")}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                );
              } else {
                return ListView(
                  shrinkWrap: true,
                  children: documents
                      .map(
                        (document) => Container(
                          margin: EdgeInsets.all(space / 2),
                          child: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(document['post'])
                                .get(),
                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot2) {
                              if (snapshot2.hasData) {

                                DateTime arrivalDate = snapshot2.data['dateArrivee'].toDate();
                                String arrivalDateLocale = DateFormat.yMMMd(
                                    '${AppLocalizations.of(context).locale}')
                                    .format(arrivalDate);
                                return InkWell(
                                  onTap: () {
                                    showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => DetailsTask(
                                          post: snapshot2.data,
                                          proposal: document,
                                        ));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(space),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(padding),
                                      gradient: LinearGradient(colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context).primaryColorLight,
                                      ]),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${snapshot2.data['arrival']['country']}, ${snapshot2.data['arrival']['city']}', style: Theme.of(context).primaryTextTheme.headline5.copyWith(color: Colors.black),),
                                        SizedBox(height: space / 2),
                                        Text('$arrivalDateLocale')
                                      ],
                                    ),
                                  ),
                                );
                              }
                              if (snapshot2.hasError) {
                                return Text(
                                    '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
                              }

                              return Container(
                                  width: size.width,
                                  alignment: Alignment.center,
                                  child: Text(
                                      '${AppLocalizations.of(context).translate("loading")}'));
                            },
                          ),
                        ),
                      )
                      .toList(),
                );
              }
            }
            if (snapshot.hasError) {
              return Text(
                  '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
            }
            return Container(
                width: size.width,
                alignment: Alignment.center,
                child: Text(
                    '${AppLocalizations.of(context).translate("loading")}'));
          },
        ),
        /*FutureBuilder<List<DocumentSnapshot>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //final List<DocumentSnapshot> documents = snapshot.data;
              if (snapshot.data.length == 0) {
                return Container(
                  child: Text(
                    '${AppLocalizations.of(context).translate("noData")}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => DetailsTask(
                                  doc: snapshot.data[index],
                                ));
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(
                              '${AppLocalizations.of(context).translate("departureDate")}'),
                          subtitle: Text(snapshot.data[index]['dateDepart']),
                        ),
                      ),
                    );
                  },
                );
              }
            }
            if (snapshot.hasError) {
              return Text(
                  '${AppLocalizations.of(context).translate("anErrorHasOccurred")}');
            }
            return Container(
                width: size.width,
                alignment: Alignment.center,
                child: Text(
                    '${AppLocalizations.of(context).translate("loading")}'));
          },
        ),*/
      ),
    );
  }
}
