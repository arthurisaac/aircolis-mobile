// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccount.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/airportDataReader.dart';
import 'package:aircolis/utils/airportLookup.dart';
import 'package:aircolis/utils/airport_search_delegate.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/firstDisabledFocusNode.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AlertePost extends StatefulWidget {
  const AlertePost({Key? key}) : super(key: key);

  @override
  _AlertePostState createState() => _AlertePostState();
}

class _AlertePostState extends State<AlertePost> {
  final _formKey = GlobalKey<FormState>();
  var departureCountryController = TextEditingController();
  var countryOfArrivalController = TextEditingController();
  Airport? departure;
  Airport? arrival;
  bool loading = false;
  bool paymentSuccessfully = false;
  BuildContext? dialogContext;

  static RemoteConfig _remoteConfig = RemoteConfig.instance;
  double _souscription = SOUSCRIPTION;

  late AirportLookup airportLookup;
  late FocusScopeNode currentFocus;

  lookup() async {
    List<Airport> airports =
        await AirportDataReader.load('assets/airports.dat');
    airportLookup = AirportLookup(airports: airports);
  }

  _selectDeparture(BuildContext context) async {
    final departureAirport = await _showSearch(context);
    if (departureAirport != null) {
      departureCountryController.text = departureAirport.city;
      departure = departureAirport;
    }
  }

  _selectArrival(BuildContext context) async {
    final arrivalAirport = await _showSearch(context);
    if (arrivalAirport != null) {
      countryOfArrivalController.text = arrivalAirport.city;
      arrival = arrivalAirport;
    }
  }

  Future<Airport?> _showSearch(BuildContext context) async {
    return await showSearch<Airport>(
      context: context,
      delegate: AirportSearchDelegate(
        airportLookup: airportLookup,
      ),
    );
  }

  /*
  Paiement
   */

  /* startDirectCharger(PaymentMethod paymentMethod) {
    print("Payment charge started");

    showLoadingIndicator();

    Utils.payParcel(_souscription, paymentMethod.id, "EUR").then((value) async {
      final paymentIntent = jsonDecode(value.body);
      final status = paymentIntent["paymentIntent"]["status"];
      final account = paymentIntent["stripeAccount"];

      if (status == "succeeded") {
        await AuthService().updateSubscriptionVoyageur(1);
        _successDialog();
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
            await AuthService().updateSubscriptionVoyageur(1);
            _successDialog();
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
      //Navigator.of(context).pop();
    }).catchError((onError) {
      print(onError.toString());
      Utils.showSnack(
          context, "Impossible d'effectuer l'abonnement. Reessayer plus tard!");
      Navigator.of(context).pop();
    });
  } */

  void showLoadingIndicator() {
    showDialog(
        context: context,
        //barrierDismissible: true,
        builder: (context) {
          dialogContext = context;
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            backgroundColor: Colors.black87,
            content: Utils.loadingIndicator(),
          );
        });
  }

  setupRemoteConfig() async {
    final Map<String, dynamic> defaults = <String, dynamic>{
      'trial': false,
      'souscription': _souscription
    };
    await _remoteConfig.setDefaults(defaults);

    _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 10),
      ),
    );

    await _fetchRemoteConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _souscription = _remoteConfig.getDouble("souscription");
      setState(() {});
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  /* Future<void> payer() async {
    StripePayment.setStripeAccount(null);
    StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod method) {
      startDirectCharger(method);
      return method;
    }).catchError((e) {
      print(e);
    });
  } */

  @override
  void initState() {
    lookup();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      currentFocus = FocusScope.of(context);
    });
    /* StripePayment.setOptions(
      StripeOptions(
        publishableKey: STRIPE_LIVE_KEY,
        merchantId: STRIPE_MERCHAND_ID,
        androidPayMode: 'production',
      ),
    ); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Nouvelle alerte"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
              stream: AuthService().getUserDocumentStream(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  var data = new Map<String, dynamic>.of(snapshot.data.data());

                  if (data.containsKey("subscription") &&
                      data['subscription'] == 1) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: departureCountryController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "Ville de départ",
                                hintText: AppLocalizations.of(context)!
                                    .translate('departure'),
                                errorText: null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(padding),
                                ),
                                prefixIcon: Icon(Icons.flight_takeoff)),
                            focusNode: FirstDisabledFocusNode(),
                            showCursor: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                              }
                              return null;
                            },
                            onTap: () async {
                              _selectDeparture(context);
                            },
                          ),
                          SizedBox(
                            height: space,
                          ),
                          TextFormField(
                            controller: countryOfArrivalController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "Ville d'arrivée",
                                hintText: AppLocalizations.of(context)!
                                    .translate('arrival'),
                                errorText: null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(padding),
                                ),
                                prefixIcon: Icon(Icons.flight_land)),
                            focusNode: FirstDisabledFocusNode(),
                            showCursor: false,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                              }
                              return null;
                            },
                            onTap: () async {
                              _selectArrival(context);
                            },
                          ),
                          SizedBox(
                            height: space,
                          ),
                          !loading
                              ? AirButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _saveAlerte();
                                    }
                                  },
                                  text: Text(
                                    'Créer',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04),
                                  ),
                                  icon: Icons.alarm_add,
                                )
                              : SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator())
                        ],
                      ),
                    );
                  }

                  if (data.containsKey("isVerified") && data['isVerified']) {
                    return Scaffold(
                      extendBodyBehindAppBar: true,
                      extendBody: true,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
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
                                              ?.copyWith(color: Colors.white),
                                          children: [
                                            TextSpan(
                                              text:
                                                  "Payer une seule fois et publier vos annonces à volonté à seulement ",
                                            ),
                                            TextSpan(
                                                text: "$_souscription €",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])),
                                  SizedBox(
                                    height: space * 2,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      //payer();
                                    },
                                    child: Text("S'abonner maintenant"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return VerifyAccountScreen();
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
              }),
        ),
      ),
    );
  }

  _saveAlerte() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference alertCollection =
        FirebaseFirestore.instance.collection('alertes');
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["depart"] = departure?.toJson();
    data["arrivee"] = arrival?.toJson();
    data["uid"] = uid;
    try {
      await alertCollection.add(data);
      setState(() {
        loading = false;
      });
      _successDialog();
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  void _successDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(padding),
            ),
            content: Container(
              //width: MediaQuery.of(context).size.width -100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/success-burst.json',
                    repeat: false,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(
                    height: space,
                  ),
                  Text(
                    'Vous serez alerté lorsqu\'une annonce correspondra à votre alerte',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: space,
                  ),
                  Container(
                    margin: EdgeInsets.all(space),
                    child: InkWell(
                      child: Text('OK'),
                      onTap: () {
                        var count = 0;
                        Navigator.of(context).popUntil((context) {
                          return count++ == 1;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
