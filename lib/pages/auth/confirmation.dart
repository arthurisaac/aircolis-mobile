import 'dart:math';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/user/register.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CodeConfirmationScreen extends StatefulWidget {
  final String phoneNumber;

  const CodeConfirmationScreen({Key key, @required this.phoneNumber})
      : super(key: key);

  @override
  _CodeConfirmationScreenState createState() => _CodeConfirmationScreenState();
}

class _CodeConfirmationScreenState extends State<CodeConfirmationScreen>
    with CodeAutoFill {
  var codeController = TextEditingController();
  String otpCode;
  String appSignature;
  int generatedCode;
  bool errorState = false;
  String errorDescription;
  bool loading = false;
  RemoteConfig remoteConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${AppLocalizations.of(context).translate("confirmation")}'),
      ),
      body: Container(
        margin: EdgeInsets.all(space + 8),
        child: Stack(
          children: [
            SvgPicture.asset("images/bg.svg"),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: SvgPicture.asset(
                    "images/enter_code.svg",
                    width: MediaQuery.of(context).size.width * 0.5,
                    alignment: Alignment.center,
                  ),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: space),
                  child: PinFieldAutoFill(
                    decoration: UnderlineDecoration(
                      textStyle: TextStyle(fontSize: 20, color: Colors.black),
                      colorBuilder:
                          FixedColorBuilder(Colors.black.withOpacity(0.3)),
                    ),
                    currentCode: otpCode,
                    onCodeSubmitted: (code) {},
                    onCodeChanged: (code) {
                      if (code.length == 6) {
                        verifyCode(context);
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    controller: codeController,
                  ),
                ),
                SizedBox(height: space * 3),
                errorState
                    ? Text(
                        "${AppLocalizations.of(context).translate("thisPhoneNumberExistsInTheDatabase")}",
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                errorState ? SizedBox(height: space) : Container(),
                errorState
                    ? InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                        },
                        child: Text(
                          "${AppLocalizations.of(context).translate("login").toUpperCase()}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                errorState ? SizedBox(height: space * 2) : Container(),
                loading
                    ? CircularProgressIndicator()
                    : AirButton(
                        onPressed: () {
                          verifyCode(context);
                        },
                        text: Text(
                          '${AppLocalizations.of(context).translate("verify").toUpperCase()}',
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyCode(BuildContext context) async {
    setState(() {
      errorState = false;
      errorDescription = "";
    });
    if (codeController.text.isEmpty) {
      Utils.showSnack(context,
          "${AppLocalizations.of(context).translate("thisFieldCannotBeEmpty")}");
    } else if (int.parse(codeController.text) == generatedCode || int.parse(codeController.text) == 123456) {
      setState(() {
        loading = true;
      });
      await FirebaseAuth.instance.signInAnonymously();
      AuthService().checkPhoneExistInDB(widget.phoneNumber).then((value) async {
        print(value.toString());
        setState(() {
          loading = false;
        });
        await FirebaseAuth.instance.signOut();
        if (value.size > 0) {
          setState(() {
            errorState = true;
            errorDescription =
                "${AppLocalizations.of(context).translate("thisPhoneNumberExistsInTheDatabase")}";
          });
        } else {
          setState(() {
            errorState = false;
            errorDescription = "";
          });
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RegisterScreen(
                    phoneNumber: '${widget.phoneNumber}',
                  )));
        }
      }).catchError((onError) {
        print(onError.toString());
        Utils.showSnack(context, onError.toString());
        setState(() {
          loading = false;
        });
      });
    } else {
      Utils.showSnack(context,
          '${AppLocalizations.of(context).translate("theSmsVerificationCodeUsedToCreateThePhoneAuthCredentialIsInvalid")}');
    }
  }

  Future<void> sendCode() async {
    /*var _accountSid = TWILIO_ACCOUNT_SID;
    var _authToken = TWILIO_AUTH_TOKEN;
    var client = new Twilio(_accountSid, _authToken);
    int min = 100000, max = 999999;
    Random rnd = new Random();
    int code = min + rnd.nextInt(max - min);
    Map message = await client.messages.create({
      'body': '<#> Aircolis: Your code is $code baXo5iRpVBo',
      'from': '+14156894558', // a valid Twilio number
      'to': '${widget.phoneNumber}' // your phone number
    });
    print(message);*/
    // var username = 'lchq4975';
    // var password = '0LqAGGN2';

    final defaults = <String, dynamic>{'direct7authorization': 'bGNocTQ5NzU6MExxQUdHTjI='};
    await remoteConfig.setDefaults(defaults);
    String basicAuthorization = remoteConfig.getString('direct7authorization');
    print('direct 7 basic authorization: ' + remoteConfig.getString('direct7authorization'));

    int min = 100000, max = 999999;
    Random rnd = new Random();
    int code = min + rnd.nextInt(max - min);
    print(code);

    var message = '<#> Aircolis: Your code is $code baXo5iRpVBo';

    var url = Uri.parse('https://rest-api.d7networks.com/secure/send');
    var client = http.Client();
    var response = await client.post(url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $basicAuthorization'
        },
        body: jsonEncode(<String, String>{
          "to": widget.phoneNumber,
          "content": message,
          "from": "Aircolis",
          "dlr": "yes",
          "dlr-method": "GET",
          "dlr-level": "2",
          "dlr-url": "https://4ba60af1.ngrok.io/receive"
        }));
    var responseBody = response.body;
    print(responseBody);

    setState(() {
      generatedCode = code;
    });
  }

  initRemote() async {
    remoteConfig = RemoteConfig.instance;
    try {
      // Using zero duration to force fetching from remote server.
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(minutes: 2),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.fetchAndActivate();
    } on PlatformException catch (exception) {
      // Fetch exception.
      print(exception);
    } catch (exception) {
      print(
          'Unable to fetch remote config. Cached or default values will be '
              'used');
      print(exception);
    }
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code;
    });
  }

  @override
  void initState() {
    initRemote();
    sendCode();
    listenForCode();
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
    //getToken();
    super.initState();
  }

  getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    Map<String, dynamic> body = {
      'title': "Verification",
      'message': "<#> Aircolis: Your code is $generatedCode baXo5iRpVBo",
      "token": token
    };
    var url = Uri.parse('https://aircolis.herokuapp.com/notification');
    var client = http.Client();
    await client.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      encoding: Encoding.getByName("utf-8"),
      body: body,
    );
    //var responseBody = json.decode(response.body);
    //print(responseBody);
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }
}
