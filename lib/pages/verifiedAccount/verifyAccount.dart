import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountName.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class VerifyAccountScreen extends StatefulWidget {
  @override
  _VerifyAccountScreenState createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
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
                        fontSize: MediaQuery.of(context).size.width * 0.04)),
                onPressed: () async {
                  var doc = await AuthService().getUserDoc();
                  if (doc.exists && doc.get("lastname") == "") {
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => VerifyAccountName(),
                    );
                  } else {
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => VerifyAccountStep(),
                    );
                  }

                  /*Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VerifyAccountStep(),
                    ),
                  );*/
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
