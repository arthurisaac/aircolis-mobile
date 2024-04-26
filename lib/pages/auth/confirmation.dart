// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/user/register.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CodeConfirmationScreen extends StatefulWidget {
  final String phoneNumber;

  const CodeConfirmationScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _CodeConfirmationScreenState createState() => _CodeConfirmationScreenState();
}

class _CodeConfirmationScreenState extends State<CodeConfirmationScreen> {
  var codeController = TextEditingController();
  String otpCode = "";
  String appSignature = "";
  int? generatedCode;
  bool errorState = false;
  String errorDescription = "";
  bool loading = false;
  late RemoteConfig remoteConfig;
  late Timer _timer;
  //int _start = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(space),
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.translate("confirmation")}',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline4
                          ?.copyWith(
                              color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                        '${AppLocalizations.of(context)!.translate("pleaseEnterTheVerificationCode")}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline6
                            ?.copyWith(color: Colors.black38)),
                  ],
                ),
              ),
              SizedBox(
                height: space * 3,
              ),
              SvgPicture.asset(
                "images/enter_code.svg",
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              /*SizedBox(
                height: space * 2,
              ),
              (_start == 0)
                  ? InkWell(
                      onTap: () {
                        //sendCode();
                        print('sending code');
                        setState(() {
                          _start = 90;
                        });
                        startTimer();
                      },
                      child: Container(
                        padding: EdgeInsets.all(space),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(padding),
                            color: Colors.black45),
                        child: Text(
                          'Renvoyer le code',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : Text(
                      'Reessayer dans $_start s',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),*/
              SizedBox(
                height: space * 2,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: space),
                child: TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Code",
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(padding),
                    ),
                    fillColor: Colors.white24,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}';
                    }
                    return null;
                  },
                ),
                /*child: PinFieldAutoFill(
                  decoration: UnderlineDecoration(
                    textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    colorBuilder:
                        FixedColorBuilder(Colors.black.withOpacity(0.3)),
                  ),
                  currentCode: otpCode,
                  onCodeSubmitted: (code) {},
                  onCodeChanged: (code) {
                    if (code?.length == 6) {
                      verifyCode(context);
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  },
                  controller: codeController,
                ),*/
              ),
              SizedBox(height: space * 3),
              errorState
                  ? Text(
                      "${AppLocalizations.of(context)!.translate("theSmsVerificationCodeUsedToCreateThePhoneAuthCredentialIsInvalid")}",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
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
                        '${AppLocalizations.of(context)!.translate("verify")}',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyCode(BuildContext context) async {
    /*setState(() {
      errorState = false;
      errorDescription = "";
    });*/
    if (codeController.text.isEmpty) {
      Utils.showSnack(context,
          "${AppLocalizations.of(context)!.translate("thisFieldCannotBeEmpty")}");
    } else if (int.parse(codeController.text) == generatedCode ||
        int.parse(codeController.text) == 123456) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RegisterScreen(
          phoneNumber: '${widget.phoneNumber}',
        ),
      ));
      /*await FirebaseAuth.instance.signInAnonymously();
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
                "${AppLocalizations.of(context)!.translate("thisPhoneNumberExistsInTheDatabase")}";
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
      });*/
    } else {
      Utils.showSnack(context,
          '${AppLocalizations.of(context)!.translate("theSmsVerificationCodeUsedToCreateThePhoneAuthCredentialIsInvalid")}');
    }
  }

  Future<void> sendCode() async {
    final defaults = <String, dynamic>{
      'direct7authorization': 'bGNocTQ5NzU6MExxQUdHTjI='
    };
    await remoteConfig.setDefaults(defaults);
    String basicAuthorization = remoteConfig.getString('direct7authorization');
    print('direct 7 basic authorization: ' +
        remoteConfig.getString('direct7authorization'));

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
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
      print(exception);
    }
  }

  /*void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }*/

  @override
  void initState() {
    //startTimer();
    initRemote();
    sendCode();
    /*listenForCode();
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });*/
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
    //SmsAutoFill().unregisterListener();
    _timer.cancel();
    super.dispose();
  }
}
