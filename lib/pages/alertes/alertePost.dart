import 'dart:ui';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/Airport.dart';
import 'package:aircolis/utils/airportDataReader.dart';
import 'package:aircolis/utils/airportLookup.dart';
import 'package:aircolis/utils/airport_search_delegate.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/firstDisabledFocusNode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AlertePost extends StatefulWidget {
  const AlertePost({Key key}) : super(key: key);

  @override
  _AlertePostState createState() => _AlertePostState();
}

class _AlertePostState extends State<AlertePost> {
  final _formKey = GlobalKey<FormState>();
  var departureCountryController = TextEditingController();
  var countryOfArrivalController = TextEditingController();
  Airport departure;
  Airport arrival;
  bool loading = false;

  AirportLookup airportLookup;
  FocusScopeNode currentFocus;

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
    countryOfArrivalController.text = arrivalAirport.city;
    arrival = arrivalAirport;
  }

  Future<Airport> _showSearch(BuildContext context) async {
    return await showSearch<Airport>(
      context: context,
      delegate: AirportSearchDelegate(
        airportLookup: airportLookup,
      ),
    );
  }

  @override
  void initState() {
    lookup();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentFocus = FocusScope.of(context);
    });
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: departureCountryController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: "Ville de départ",
                      hintText:
                          AppLocalizations.of(context).translate('departure'),
                      errorText: null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(padding),
                      ),
                      prefixIcon: Icon(Icons.flight_takeoff)),
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
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
                      hintText:
                          AppLocalizations.of(context).translate('arrival'),
                      errorText: null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(padding),
                      ),
                      prefixIcon: Icon(Icons.flight_land)),
                  focusNode: FirstDisabledFocusNode(),
                  showCursor: false,
                  readOnly: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return '${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}';
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
                !loading ? AirButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _saveAlerte();
                    }
                  },
                  text: Text(
                    'Créer',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                  icon: Icons.alarm_add,
                ) : SizedBox(width: 25, height: 25, child: CircularProgressIndicator())
              ],
            ),
          ),
        ),
      ),
    );
  }

  _saveAlerte() async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    CollectionReference alertCollection = FirebaseFirestore.instance.collection('alertes');
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["depart"] = departure.toJson();
    data["arrivee"] = arrival.toJson();
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
                      'Vous serez alerté lorsqu\'une annonce correspondra à votre alerte', textAlign: TextAlign.center,),
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
