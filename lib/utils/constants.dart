import 'package:aircolis/models/travelTracking.dart';
import 'package:flutter/material.dart';

const defaultColor = Color(0xFF38ADA9);
const double space = 20;
const padding = 14.0;
const List<String> languages = ['fr', 'en'];
const List<BoxShadow> shadowList = [
  BoxShadow(color: defaultColor, blurRadius: 30, offset: Offset(0, 10))
];
const List<BoxShadow> shadowListBlack = [
  BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 5))
];
//const String trackingStepRaw = '[{ "title": "Récupération du colis", "validated": false }, { "title": "Embarquement", "validated": false}, { "title": "Voyage en cours", "validated": false}, { "title": "Destination", "validated": false}]';
//const List<Map<String, dynamic>> trackingStepRaw = [{ "title": "Récupération du colis", "validated": false }, { "title": "Embarquement", "validated": false}, { "title": "Voyage en cours", "validated": false}, { "title": "Destination", "validated": false}];

List<dynamic> trackingStepRaw = [
  Tracking(title: "Récupération du colis", validated: false).toJson(),
  Tracking(title: "Embarquement", validated: false).toJson(),
  Tracking(title: "Voyage en cours", validated: false).toJson(),
  Tracking(title: "Destination", validated: false).toJson(),
];

const String TWILIO_SMS_API_BASE_URL = "https://api.twilio.com/2010-04-01";
const String TWILIO_ACCOUNT_SID = "AC8a9692f76350352f65d8486433640a35";
const String TWILIO_AUTH_TOKEN = "95e87e1a42015b1efe618f1b70891909";
const String CGU_LINK =
    "https://firebasestorage.googleapis.com/v0/b/aircolis-4913d.appspot.com/o/cgu_aircolis.pdf?alt=media&token=58e8d762-66ab-4501-9a9b-4456f43a88ca";

const double SOUSCRIPTION_VOYAGEUR = 6.99;
const double SOUSCRIPTION_EXPEDITEUR = 6.99;

const String STRIPE_TEST_KEY =
    "pk_test_51J5X6BFq74Le5hMXdn8bao6GNSMgGXsytxx94ZcCZbV21bLYtonSHCsORXFyBDyB5irfzbxpNqPxngShQbdKI7DY00qe0K6AWS";
const String STRIPE_LIVE_KEY =
    "pk_live_51J5XvyDF00kloega3QnTnJimY8EMnzTPRRdrVSDqfQojFyItLaUtakOyooxks3uczatPPZM6u02ylPz1gpeeFV5o00Lh5Il0KU";
const String STRIPE_MERCHAND_ID = "01742403243344548528";
