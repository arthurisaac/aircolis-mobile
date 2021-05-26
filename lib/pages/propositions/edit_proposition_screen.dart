import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/parcel/paymentParcelScreen.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProposalScreen extends StatefulWidget {
  final DocumentSnapshot post;
  final DocumentSnapshot proposal;

  const EditProposalScreen(
      {Key key, @required this.post, @required this.proposal})
      : super(key: key);

  @override
  _EditProposalScreenState createState() => _EditProposalScreenState();
}

class _EditProposalScreenState extends State<EditProposalScreen> {
  double _value = 0;
  final _formKey = GlobalKey<FormState>();
  final parcelHeight = TextEditingController();
  final parcelLength = TextEditingController();
  final parcelWeight = TextEditingController();
  final parcelDescription = TextEditingController();
  bool loading = false;
  bool errorState = false;
  bool enableEdit = false;
  String errorDescription;

  @override
  void initState() {
    parcelHeight.text = widget.proposal.get("height").toString();
    parcelLength.text = widget.proposal.get("length").toString();
    parcelWeight.text = widget.proposal.get("weight").toString();
    parcelDescription.text = widget.proposal.get("description").toString();
    _value = widget.proposal.get("weight");

    if (widget.proposal.get("isApproved")) {
      setState(() {
        enableEdit = true;
      });
    }
    super.initState();
  }

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
                                enabled: !enableEdit,
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

                                  if ((double.tryParse(value) ?? 0) >
                                      widget.post['parcelLength']) {
                                    return 'La valeur ne doit pas dépasser ${widget.post['parcelHeight']}';
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
                                        '${widget.post['parcelHeight']}',
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headline6
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                enabled: !enableEdit,
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
                                  if ((double.tryParse(value) ?? 0) >
                                      widget.post['parcelLength']) {
                                    return 'La valeur ne doit pas dépasser ${widget.post['parcelLength']}';
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
                                        '${widget.post['parcelLength']}',
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
                                        .copyWith(
                                          color: Colors.white,
                                        ),
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
                                enabled: !enableEdit,
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
                                  if ((double.tryParse(value) ?? 0) >
                                      widget.post['parcelWeight']) {
                                    return 'La valeur ne doit pas dépasser ${widget.post['parcelWeight']}';
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
                                        '${widget.post['parcelWeight']}',
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
                                    'Max. ${AppLocalizations.of(context).translate("parcelWeight").toLowerCase()}',
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
                          enabled: !enableEdit,
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
                        !enableEdit
                            ? Container(
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
                                              '${(widget.post['price'] * _value)} ${Utils.getCurrencySize(widget.post['currency'])}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor))
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText2
                                        .copyWith(color: Colors.black),
                                    children: [
                                      TextSpan(text: "Total à payer : "),
                                      TextSpan(
                                        text:
                                            "${widget.proposal.get("total")}\$ USD",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .headline6
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        !widget.proposal.get("isApproved")
                            ? AirButton(
                                onPressed: !loading
                                    ? () {
                                        if (_formKey.currentState.validate()) {
                                          _updateProposal();
                                        }
                                      }
                                    : null,
                                text: Text(!loading
                                    ? '${AppLocalizations.of(context).translate("save")}'
                                    : '${AppLocalizations.of(context).translate("loading")}'),
                                icon: Icons.check,
                              )
                            : Container(),
                        (widget.proposal.get("isApproved") && !widget.proposal.get("canUse"))
                            ? Container(
                          margin: EdgeInsets.only(top: space),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(padding),
                              ),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return PaymentParcelScreen(
                                    post: widget.post,
                                    proposal: widget.proposal,
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(space),
                              child: Text(
                                  "${AppLocalizations.of(context).translate("payNow")}"),
                            ),
                          ),
                        )
                            : Container(),
                        errorState
                            ? Container(
                                margin: EdgeInsets.only(top: space),
                                child: Text('$errorDescription'),
                              )
                            : Container(),
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

  _updateProposal() async {
    setState(() {
      loading = true;
      errorState = false;
      errorDescription = "";
    });

    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentReference proposalReference = FirebaseFirestore.instance
        .collection('proposals')
        .doc(widget.proposal.id);

    Map<String, dynamic> data = {
      "length": double.tryParse(parcelLength.text) ?? parcelLength,
      "height": double.parse(parcelHeight.text) ?? parcelHeight,
      "weight": double.parse(parcelWeight.text) ?? parcelWeight,
      "description": parcelDescription.text,
      "total": widget.post['price'] * _value,
    };
    print(data);
    await proposalReference.update(data).then((value) async {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.get("uid"))
          .get();
      setState(() {
        loading = false;
      });
      if (snapshot != null) {
        var _token = snapshot.get("token");
        if (_token != null) {
          Utils.sendNotification(
            "Aircolis",
            "L'expéditeur a modifié sa proposition",
            _token,
          );
        }
        Utils.sendRequestMail(snapshot.get("email"));
      }
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
