import 'package:aircolis/pages/user/traveller.dart';
import 'package:aircolis/services/storageService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CustomDialogBox extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const CustomDialogBox({Key key, @required this.documentSnapshot})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  Stream _stream;
  bool isApproved = false;

  @override
  void initState() {
    _stream = FirebaseFirestore.instance
        .collection('proposals')
        .doc(widget.documentSnapshot.id)
        .snapshots();
    isApproved = widget.documentSnapshot.get('isApproved');
    _seen(widget.documentSnapshot.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(space),
          margin: EdgeInsets.only(top: space),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 10),
                    blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: space * 3),
              FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.documentSnapshot.get('uid'))
                    .get(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return InkWell(
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => TravellerScreen(
                            uid: widget.documentSnapshot.get("uid"),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          StorageService().getPhoto(
                            context,
                            snapshot.data['firstname'][0],
                            snapshot.data['photo'],
                            20,
                            20.0,
                          ),
                          SizedBox(
                            width: space,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data['firstname']}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6
                                    .copyWith(color: Colors.black),
                              ),
                              isApproved
                                  ? Text("${snapshot.data['phone']}")
                                  : Text("Non confirmé") //TODO
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    print(snapshot.error.toString());
                  }
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: space),
              Container(
                //margin: EdgeInsets.only(left: space + 10),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${snapshot.data['description']}'),
                          SizedBox(height: space),
                          Text(
                            '${AppLocalizations.of(context).translate("parcelSize")} ${snapshot.data['length']} x ${snapshot.data['height']}',
                          ),
                          Text(
                            '${AppLocalizations.of(context).translate("parcelWeight")}: ${snapshot.data['weight']}',
                          ),
                          SizedBox(height: space),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Container(
                        margin: EdgeInsets.all(space),
                        child: Text(
                            '${AppLocalizations.of(context).translate("anErrorHasOccurred")}'),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0.0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '${AppLocalizations.of(context).translate("cancel")}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    isApproved
                        ? Container()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.transparent,
                              elevation: 0.0,
                            ),
                            onPressed: () {
                              _approve(widget.documentSnapshot.id);
                            },
                            child: Text(
                                '${AppLocalizations.of(context).translate("approve")}',
                                style: TextStyle(color: Colors.green)),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _approve(String proposal) {
    var snapshot =
        FirebaseFirestore.instance.collection('proposals').doc(proposal);

    Map<String, dynamic> data = {
      "isApproved": true,
    };

    snapshot.update(data).then((value) {
      Utils.showSnack(context, 'La proposition a été acceptée avec succès');
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.documentSnapshot.get('uid'))
          .get()
          .then((value) {
        if (value.get('token') != 'null' &&
            value.get('token').toString().isNotEmpty)
          Utils.sendNotification('Aircolis',
              'Le voyageur a accepté votre proposition', value.get('token'));
      });

      //Navigator.of(context).pop();
      //print('approved');
    }).catchError((onError) {
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
    });
  }

  _seen(String proposal) {
    var snapshot =
        FirebaseFirestore.instance.collection('proposals').doc(proposal);

    Map<String, dynamic> data = {
      "isNew": false,
    };

    snapshot.update(data).then((value) {
      print('seen');
    }).catchError((onError) {
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
    });
  }

/*_revoke(String proposal) {
    var snapshot =
    FirebaseFirestore.instance.collection('proposals').doc(proposal);

    Map<String, dynamic> data = {
      "isApproved": false,
    };

    snapshot.update(data).then((value) {
      // TODO
      print('cancel');
    }).catchError((onError) {
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
    });
  }*/
}
