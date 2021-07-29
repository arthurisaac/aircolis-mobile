import 'dart:async';
import 'dart:convert';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/ProviderModel.dart';
import 'package:aircolis/pages/auth/loginPopup.dart';
import 'package:aircolis/pages/posts/newPost/postFormScreen.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  bool paymentSuccessfully = false;
  bool loading = false;

  Future<void> payer() async {
    StripePayment.setStripeAccount(null);
    StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod method) {
      startDirectCharger(method);
      return method;
    }).catchError((e) {
      print(e);
    });
  }

  startDirectCharger(PaymentMethod paymentMethod) {
    print("Payment charge started");

    showLoadingIndicator();

    Utils.payParcel(SOUSCRIPTION_VOYAGEUR, paymentMethod.id, "EUR")
        .then((value) async {
      final paymentIntent = jsonDecode(value.body);
      final status = paymentIntent["paymentIntent"]["status"];
      final account = paymentIntent["stripeAccount"];

      if (status == "succeeded") {
        print("payment done");
        AuthService().updateSubscriptionVoyageur(1);
        setState(() {
          paymentSuccessfully = true;
        });
      } else {
        StripePayment.setStripeAccount(account);
        await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              paymentMethod: paymentIntent["paymentIntent"]["payment_method"],
              clientSecret: paymentIntent["paymentIntent"]["client_secret"]),
        ).then((PaymentIntentResult paymentIntentResult) async {
          final paymentStatus = paymentIntentResult.status;
          if (paymentStatus == "succeeded") {
            print("payment done");
            AuthService().updateSubscriptionVoyageur(1);
            setState(() {
              paymentSuccessfully = true;
            });
          } else {
            Utils().showAlertDialog(context, "Paiement non effectué.",
                "Une erreur s'est produite lors de votre paiement. Veuillez reéssayer plu tard svp ",
                () {
              Navigator.of(context).pop();
            });
            print("payment not done");
          }
        });
      }
      Navigator.of(context).pop();
    }).catchError((onError) {
      print(onError.toString());
      Utils.showSnack(
          context, "Impossible d'effectuer l'abonnement. Reessayer plus tard!");
      Navigator.of(context).pop();
    });
  }

  void showLoadingIndicator() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            backgroundColor: Colors.black87,
            content: Utils.loadingIndicator(),
          );
        });
  }

  @override
  void initState() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: STRIPE_LIVE_KEY,
        merchantId: STRIPE_MERCHAND_ID,
        androidPayMode: 'production',
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance?.currentUser;

    return (user == null || user.isAnonymous)
        ? LoginPopupScreen()
        : StreamBuilder(
            stream: AuthService().getUserDocumentStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = new Map<String, dynamic>.of(snapshot.data.data());

                if (data.containsKey("subscriptionVoyageur") &&
                    snapshot.data['subscriptionVoyageur'] == 1) {
                  return PostFormScreen();
                }

                if (data.containsKey("isVerified") &&
                    snapshot.data['isVerified']) {
                  return Scaffold(
                    body: SafeArea(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(space),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.1, 0.4, 0.7, 0.9],
                            colors: [
                              Color(0xB444CFCA),
                              Color(0xFF44CFCA),
                              Color(0xFF5CC4C0),
                              Color(0xFF38ADA9),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  /*Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                        BorderRadius.circular(
                                            padding)),
                                    child: Text(
                                      "Abonnement à vie".toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .headline5
                                          .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),*/
                                  Lottie.asset(
                                      "assets/travelers-find-location.json",
                                      width: MediaQuery.of(context).size.width *
                                          .7),
                                  RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .bodyText2
                                              .copyWith(color: Colors.white),
                                          children: [
                                            TextSpan(
                                              text:
                                                  "Payer une seule fois et publier vos annonces à volonté à seulement ",
                                            ),
                                            TextSpan(
                                                text:
                                                    "$SOUSCRIPTION_VOYAGEUR €",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])),
                                  SizedBox(
                                    height: space * 2,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      payer();
                                    },
                                    child: Text("S'abonner maintenant"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return unverifiedWidget();
                }
              }
              if (snapshot.hasError) {
                return SomethingWentWrong(
                  description: snapshot.error.toString(),
                );
              }

              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
  }

  Widget unverifiedWidget() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
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
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.all(space),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "images/icons/unverified.svg",
                width: MediaQuery.of(context).size.height * 0.2,
              ),
              SizedBox(
                height: space * 2,
              ),
              Text(
                "${AppLocalizations.of(context).translate("yourAccountHasNotBeenVerified")}",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: space * 2,
              ),
              AirButton(
                text: Text(
                  '${AppLocalizations.of(context).translate("confirmAccount")}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VerifyAccountStep(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: space,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
