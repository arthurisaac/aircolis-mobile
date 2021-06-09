import 'dart:convert';

import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:lottie/lottie.dart';

class PaymentParcelScreen extends StatefulWidget {
  final DocumentSnapshot proposal;
  final DocumentSnapshot post;

  const PaymentParcelScreen(
      {Key key, @required this.proposal, @required this.post})
      : super(key: key);

  @override
  _PaymentParcelScreenState createState() => _PaymentParcelScreenState();
}

class _PaymentParcelScreenState extends State<PaymentParcelScreen> {
  bool loading = false;
  bool paymentSuccessfully = false;
  double totalToPay = 1.0;
  bool errorState = false;
  String errorMessage;

  @override
  void initState() {
    totalToPay = widget.proposal.get('total').toDouble();
    super.initState();
  }

  Future<void> pay() async {
    /*setState(() {
      loading = true;
    });*/
    /*InAppPayments.setSquareApplicationId(
        "sandbox-sq0idb-OCnsCYezA77tncMlhUb-rA");
    InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: onCardNonceRequestSuccess,
        onCardEntryCancel: onCardEntryCancel);*/
    setState(() {
      loading = true;
      errorState = false;
      errorMessage = "";
    });
    var request = BraintreeDropInRequest(
      tokenizationKey: "sandbox_24k8pxxg_bn2n77yc5n3p8zr4",
      collectDeviceData: true,
      paypalRequest: BraintreePayPalRequest(
        amount: totalToPay.toString(),
        displayName: "Aircolis",
        currencyCode: widget.post.get("currency"),
      ),
      cardEnabled: true,
    );
    BraintreeDropInResult result = await BraintreeDropIn.start(request);
    if (request != null) {
      print(result.paymentMethodNonce.description);
      print(result.paymentMethodNonce.nonce);
      Utils.payParcel(totalToPay, result.paymentMethodNonce.nonce,
              widget.post.get("currency"), "${result.deviceData}")
          .then((value) {
        var response = jsonDecode(value.body);
        print(response);
        setState(() {
          loading = false;
        });
        if (!response["result"]["success"]) {
          setState(() {
            errorState = true;
            errorMessage = response["result"]['message'];
          });
        } else {
          _approve();
          setState(() {
            paymentSuccessfully = true;
          });
        }
      }).catchError((onError) {
        setState(() {
          loading = false;
        });
        Utils.showSnack(context, "${onError.toString()}");
      });
    } else {
      print("result is null");
      setState(() {
        loading = false;
      });
    }
  }

  /*void onCardNonceRequestSuccess(CardDetails result) {
    Utils.payParcel(totalToPay, result.nonce).then((value) {
      setState(() {
        loading = false;
        paymentSuccessfully = true;
      });
      _approve();
    }).catchError((onError) {
      InAppPayments.showCardNonceProcessingError("Paiement non effectué");
    });
    InAppPayments.completeCardEntry(
      onCardEntryComplete: onCardEntryComplete(result.nonce),
    );
  }

  void onCardEntryCancel() {
    print("paiement annulé");
  }

  onCardEntryComplete(String nonce) {
    print('paiement effectué avec succès');
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10),
            child: Icon(Icons.drag_handle),
          ),
          !paymentSuccessfully
              ? Align(
                  child: (widget.proposal.get("total") != null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Réglez le destinataire maintenant",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                            SizedBox(height: 40),
                            Divider(
                              height: 1,
                              color: Colors.black,
                              indent: 50,
                              endIndent: 50,
                            ),
                            SizedBox(height: 40),
                            Text(
                              "${widget.proposal.get('total')} ${widget.post.get("currency")}",
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headline4
                                  .copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: space * 2,
                            ),
                            errorState
                                ? Container(
                                    padding: EdgeInsets.all(space),
                                    child: Text(
                                      "Erreur : $errorMessage",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                : Container(),
                            !loading
                                ? ElevatedButton(
                                    onPressed: () {
                                      pay();
                                    },
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('payNow')}"),
                                  )
                                : SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                          ],
                        )
                      : Text(
                          '${AppLocalizations.of(context).translate('anErrorHasOccurred')}'),
                )
              : Align(
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/success-burst.json',
                          repeat: false,
                          width: 200,
                          height: 200,
                        ),
                        Text(
                          'Paiement effectué avec succès',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: space * 2,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                              '${AppLocalizations.of(context).translate("back")}'),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  _approve() {
    var snapshot = FirebaseFirestore.instance
        .collection('proposals')
        .doc(widget.proposal.id);

    Map<String, dynamic> data = {
      "canUse": true,
    };

    snapshot.update(data).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.get('uid'))
          .get()
          .then((value) {
        addToWallet(value.get('wallet').toString(), value.get("email"));

        //Send notification
        if (value.get('token') != 'null' &&
            value.get('token').toString().isNotEmpty)
          // Ajouter au portefeuille du client

          Utils.sendNotification(
            'Aircolis',
            'Vous avez reçu ' +
                widget.proposal.get('total').toString() +
                ' ${widget.post.get("currency")} ',
            value.get('token'),
          );
      });
    }).catchError((onError) {
      print('Erreur: ${onError.toString()}');
    });
  }

  addToWallet(String totalAmount, String email) {
    print(email);
    var snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.post.get('uid'));

    Map<String, dynamic> data = {
      "wallet": double.tryParse(totalAmount ?? 0) + totalToPay,
    };
    snapshot.update(data).then((value) {
      Utils.sendPaymentMail(email);
    });
  }
}
