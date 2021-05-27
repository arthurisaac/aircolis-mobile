import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';

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

  @override
  void initState() {
    totalToPay = widget.proposal.get('total').toDouble();
    super.initState();
  }

  void pay() {
    /*setState(() {
      loading = true;
    });*/
    InAppPayments.setSquareApplicationId(
        "sandbox-sq0idb-OCnsCYezA77tncMlhUb-rA");
    InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: onCardNonceRequestSuccess,
        onCardEntryCancel: onCardEntryCancel);
  }

  void onCardNonceRequestSuccess(CardDetails result) {

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
  }

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
                              style: Theme.of(context).primaryTextTheme.headline6.copyWith(
                                  color: Colors.black,),
                            ),
                            SizedBox(height: 40),
                            Divider(
                              height: 1,
                              color: Colors.black,
                              indent: 50,
                              endIndent: 50,
                            ),
                            SizedBox(height: 40),
                            Text("${widget.proposal.get('total')} \$ USD", style: Theme.of(context).primaryTextTheme.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
                            SizedBox(
                              height: space * 2,
                            ),
                            !loading
                                ? ElevatedButton(
                                    onPressed: () {
                                      pay();
                                    },
                                    child: Text(
                                        "${AppLocalizations.of(context).translate('payNow')}"),)
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
        if (value.get('token') != 'null' &&
            value.get('token').toString().isNotEmpty)
          // Ajouter au portefeuille du client

          Utils.sendNotification(
              'Aircolis',
              'Vous avez reçu ' + widget.proposal.get('total').toString() + ' \$ USD ',
              value.get('token'));
      });
    }).catchError((onError) {
      print('Erreur: ${onError.toString()}');
    });
  }
}
