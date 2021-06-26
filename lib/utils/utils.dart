import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/getLocation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show base64, utf8;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Utils {
  showAlertDialog(
      BuildContext context, String title, String text, Function onPress) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        onPrimary: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      child: Text(
        "${AppLocalizations.of(context).translate("cancel")}",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        elevation: 0.0,
      ),
      child: Text(
        "${AppLocalizations.of(context).translate('continue')}",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: onPress,
    );
    AlertDialog alert = AlertDialog(
      title: Text("$title"),
      content: Text("$text"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void showSnack(context, String title) {
    final snackBar = SnackBar(
      content: Text('$title'),
      action: SnackBarAction(
        label: '${AppLocalizations.of(context).translate("back")}',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String capitalize(String str) {
    return "${str[0].toUpperCase()}${str.substring(1)}";
  }

  static String getCurrencySize(String currency) {
    if (currency == 'EUR' || currency == 'eur') {
      return '€';
    } else if (currency == 'USD' || currency == 'usd') {
      return '\$';
    } else if (currency == 'CFA' || currency == 'XOF') {
      return 'Francs CFA';
    } else {
      return currency;
    }
  }

  getLocation() async {
    GetLocation getLocation = GetLocation();
    await getLocation.getCurrentLocationBest();
    var position = LatLng(getLocation.latitude, getLocation.longitude);
    AuthService().updatePosition(position);
    // return LatLng(getLocation.latitude, getLocation.longitude);
  }

  getToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    print(token);
    AuthService().updateToken(token);
  }

  static String toAuthCredentials(String accountSid, String authToken) =>
      base64.encode(utf8.encode(accountSid + ':' + authToken));

  static void sendWelcomeMail(String email) {
    Map<String, dynamic> body = {
      'email': email,
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/email/welcome');
    var client = http.Client();
    client.post(url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName("utf-8"),
        body: body);
  }

  static void sendRequestMail(String email) {
    Map<String, dynamic> body = {
      'email': email,
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/email/request');
    var client = http.Client();
    client.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName("utf-8"),
      body: body,
    );
  }

  static void sendPaymentMail(String email) {
    Map<String, dynamic> body = {
      'email': email,
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/email/payment');
    var client = http.Client();
    try {
      client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName("utf-8"),
        body: body,
      );
    } finally {
      client.close();
    }
  }

  static void sendNotification(String title, String message, String token) {
    Map<String, dynamic> body = {
      'title': title,
      'message': message,
      "token": token
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/notification');
    var client = http.Client();
    client.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName("utf-8"),
      body: body,
    );
  }

  /*static Future<void> payParcel(double amount, String sourceId) async {
    Map<String, dynamic> body = {
      "amount": amount.toString(),
      "sourceId": sourceId,
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/payments/make');
    var client = http.Client();
    try {
      var response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName("utf-8"),
        body: body,
      );
      print(response);
    } catch (e) {
      print(e);
    } finally {
      client.close();
    }
  }*/

  /*BrainTree
  static Future<http.Response> payParcel(double amount, String paymentMethod,
      String currency, String deviceData) async {
    Map<String, dynamic> body = {
      "amount": amount.toString(),
      "payment_method_nonce": paymentMethod,
      "device_data": deviceData,
      "currency": currency,
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/payments/braintree');
    var client = http.Client();
    try {
      var response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName("utf-8"),
        body: body,
      );
      //print(response.body);
      return response;
    } catch (e) {
      print(e);
      return e;
    } finally {
      client.close();
    }
  }*/

  static Future<http.Response> payParcel(double amount, String paymentMethod,
      String currency) async {
    Map<String, dynamic> body = {
      "amount": amount.toString(),
      "payment_method": paymentMethod,
      "currency": currency,
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/payments/stripe');
    //var url = Uri.parse('http://10.0.2.2:3000/payments/stripe');
    var client = http.Client();
    try {
      var response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        encoding: Encoding.getByName("utf-8"),
        body: body,
      );
      //print(response.body);
      return response;
    } catch (e) {
      print(e);
      return e;
    } finally {
      client.close();
    }
  }
}
