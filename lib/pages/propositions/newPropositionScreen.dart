import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/Proposal.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewProposalScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  const NewProposalScreen({Key key, @required this.doc}) : super(key: key);

  @override
  _NewProposalScreenState createState() => _NewProposalScreenState();
}

class _NewProposalScreenState extends State<NewProposalScreen> {
  double _value = 0;
  final _formKey = GlobalKey<FormState>();
  final parcelHeight = TextEditingController();
  final parcelLength = TextEditingController();
  final parcelWeight = TextEditingController();
  final parcelDescription = TextEditingController();
  bool loading = false;
  bool errorState = false;
  String errorDescription;

  @override
  Widget build(BuildContext context) {
    double height = space;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            '${AppLocalizations.of(context).translate("packageProposal")}',
            style: Theme.of(context)
                .primaryTextTheme
                .headline5
                .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.close_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(height),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    '${AppLocalizations.of(context).translate("defineYourPackageInformation")}',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: height),
                Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: parcelHeight,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('parcelHeight'),
                                  hintText: AppLocalizations.of(context)
                                      .translate('parcelHeight'),
                                  errorText: null,
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '${AppLocalizations.of(context).translate("theHeightOfThePackageMustNotBeEmpty")}';
                                  }

                                  if ((int.tryParse(value) ?? 0) >
                                      widget.doc['parcelLength'].toInt()) {
                                    return 'La valeur ne doit pas dépasser ${widget.doc['parcelHeight'].toInt()}';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Container(
                              //width: 300,
                              margin: EdgeInsets.only(left: space),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${widget.doc['parcelHeight'].toInt()}',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headline6
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'cm',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2
                                            .copyWith(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Text(
                                    'Max. ${AppLocalizations.of(context).translate("height")}',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1
                                        .copyWith(color: Colors.white),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: height),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: parcelLength,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('parcelLength'),
                                  hintText: AppLocalizations.of(context)
                                      .translate('parcelLength'),
                                  errorText: null,
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '${AppLocalizations.of(context).translate("theLengthOfThePackageMustNotBeEmpty")}';
                                  }
                                  if (int.parse(value) >
                                      widget.doc['parcelLength'].toInt()) {
                                    return 'La valeur ne doit pas dépasser ${widget.doc['parcelLength'].toInt()}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: space),
                              padding: EdgeInsets.all(space / 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${widget.doc['parcelLength'].toInt()}',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headline6
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'cm',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2
                                            .copyWith(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Text(
                                    'Max. ${AppLocalizations.of(context).translate("length")}',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: height),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: parcelWeight,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('parcelWeight'),
                                  hintText: AppLocalizations.of(context)
                                      .translate('parcelWeight'),
                                  errorText: null,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  if (value != null || value.isNotEmpty) {
                                    setState(() {
                                      _value = double.tryParse(value) ?? 0;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return '${AppLocalizations.of(context).translate("theLengthOfThePackageMustNotBeEmpty")}';
                                  }
                                  if ((int.tryParse(value) ?? 0) >
                                      widget.doc['parcelWeight'].toInt()) {
                                    return 'La valeur ne doit pas dépasser ${widget.doc['parcelWeight'].toInt()}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              //width: 300,
                              margin: EdgeInsets.only(left: space),
                              padding: EdgeInsets.all(space / 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor),
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${widget.doc['parcelWeight'].toInt()}',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headline6
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'Kg',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2
                                            .copyWith(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Text(
                                    'Max. ${AppLocalizations.of(context).translate("length")}',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText1
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: height),
                        TextFormField(
                          controller: parcelDescription,
                          keyboardType: TextInputType.multiline,
                          minLines: 2,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                                .translate('parcelDescription'),
                            hintText: AppLocalizations.of(context)
                                .translate('parcelDescription'),
                            errorText: null,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: height * 2),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: space),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  .copyWith(color: Colors.black),
                              children: [
                                TextSpan(
                                    text:
                                        'En continuant, si votre proposition est acceptée, vous acceptez de payer la somme de '),
                                TextSpan(
                                    text:
                                        '${(widget.doc['price'] * _value).toInt()} ${Utils.getCurrencySize(widget.doc['currency'])}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor))
                              ],
                            ),
                          ),
                        ),
                        AirButton(
                          onPressed: !loading
                              ? () {
                                  if (_formKey.currentState.validate()) {
                                    _save();
                                  }
                                }
                              : null,
                          text: Text(!loading
                              ? '${AppLocalizations.of(context).translate("save").toUpperCase()}'
                              : '${AppLocalizations.of(context).translate("loading").toUpperCase()}'),
                          icon: Icons.check,
                          color: Colors.blueGrey,
                          iconColor: Colors.blueGrey[300],
                        ),
                        errorState
                            ? Container(
                                margin: EdgeInsets.only(top: space),
                                child: Text('$errorDescription'),
                              )
                            : Container(),
                        /*Container(
                          margin: EdgeInsets.symmetric(horizontal: height),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              */
                        /*Text(
                                '${AppLocalizations.of(context).translate("parcelWeight")}',
                                textAlign: TextAlign.start,
                              ),*/
                        /*
                              SizedBox(
                                height: height / 2,
                              ),
                              Text(
                                '${AppLocalizations.of(context).translate("maximumDefinedWeight")}: ${widget.doc['parcelWeight'].toInt()} Kg',
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _save() async {
    setState(() {
      loading = true;
      errorState = false;
      errorDescription = "";
    });

    String uid = FirebaseAuth.instance.currentUser.uid;
    CollectionReference proposalCollection =
        FirebaseFirestore.instance.collection('proposals');

    Proposal proposal = Proposal(
      uid: uid,
      post: widget.doc.id,
      length: double.parse(parcelLength.text),
      height: double.parse(parcelHeight.text),
      weight: _value,
      description: parcelDescription.text,
      isApproved: false,
      isNew: true,
      creation: DateTime.now(),
      isReceived: false,
    );
    var data = proposal.toJson();
    await proposalCollection.add(data).then((value) async {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doc.get("uid"))
          .get();
      setState(() {
        loading = false;
      });
      if (snapshot != null) {
        print(widget.doc.get("uid"));
        var _token = snapshot.get("token");
        if (_token != null) {
          // TODO: send email and notification
          Utils.sendNotification(
              "Aircolis", "Vous avez une nouvelle proposition", _token);
        }
      }
      Navigator.pop(context);
    }).catchError((e) {
      setState(() {
        loading = false;
        errorState = true;
        errorDescription = e.toString();
      });
      print(e.toString());
    });
  }
}
