import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConfirmPackagePickupDialog extends StatefulWidget {
  final DocumentSnapshot proposal;
  const ConfirmPackagePickupDialog({Key? key, required this.proposal})
      : super(key: key);

  @override
  _ConfirmPackagePickupDialogState createState() =>
      _ConfirmPackagePickupDialogState();
}

class _ConfirmPackagePickupDialogState
    extends State<ConfirmPackagePickupDialog> {
  bool errorState = false;
  String errorDescription = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.proposal.get('post'))
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (snapshot.hasData) {
              return Container(
                width: MediaQuery.of(context).size.width - 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Le cout du voyage:"),
                    Text(
                        "${snapshot.data!.get('price') * widget.proposal.get("weight")} ${Utils.getCurrencySize(snapshot.data!.get('currency'))}"),
                    SizedBox(
                      height: 20,
                    ),
                    errorState
                        ? Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Text(
                              "$errorDescription",
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        : Container(),
                    ElevatedButton(
                      onPressed: () {
                        _pay();
                      },
                      child: Text(
                          '${AppLocalizations.of(context)!.translate("payNow")}'),
                    )
                  ],
                ),
              );
            }

            return Center(
                child: SizedBox(
              child: CircularProgressIndicator(),
              width: 20,
              height: 20,
            ));
          }),
    );
  }

  _pay() {
    setState(() {
      errorState = false;
      errorDescription = "";
    });
    _updateIsReceived();
  }

  _updateIsReceived() {
    print(widget.proposal.get('post'));
    var snapshot = FirebaseFirestore.instance
        .collection('proposals')
        .doc(widget.proposal.id);
    Map<String, dynamic> data = {
      "isReceived": true,
    };

    snapshot.update(data).then((value) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    }).catchError((onError) {
      print('Une erreur lors de l\'approbation: ${onError.toString()}');
      setState(() {
        errorState = true;
        errorDescription = onError.toString();
      });
    });
  }
}
