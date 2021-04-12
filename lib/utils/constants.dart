import 'package:aircolis/models/travelTracking.dart';
import 'package:flutter/material.dart';

const defaultColor = Color(0xFF38ADA9);
const double space = 20;
const padding = 14.0;
const List<String> languages = ['fr', 'en'];
const List<BoxShadow> shadowList = [
  BoxShadow(color: defaultColor, blurRadius: 30, offset: Offset(0, 10))
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