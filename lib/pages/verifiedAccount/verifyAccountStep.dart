import 'package:aircolis/pages/verifiedAccount/verifyAccountStepTwo.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';

class VerifyAccountStep extends StatefulWidget {
  @override
  _VerifyAccountStepState createState() => _VerifyAccountStepState();
}

class _VerifyAccountStepState extends State<VerifyAccountStep> {
  double height = space;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context).translate("verifyID")}'),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: height, right: height * 2),
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: height * 2),
            Container(
              width: double.infinity,
              child: Text(
                '${AppLocalizations.of(context).translate("selectTheTypeOfDocumentYouWish")}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.05,
                ),
              ),
            ),
            SizedBox(
              height: height / 2,
            ),
            Container(
              child: Text(
                  '${AppLocalizations.of(context).translate("weNeedToDetermineIfDocument")}'),
            ),
            SizedBox(
              height: height * 3,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VerifyAccountStepTwo(
                      documentType: "passport",
                    ),
                  ),
                );
              },
              child: Container(
                width: size.width,
                padding: EdgeInsets.all(height),
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  "${AppLocalizations.of(context).translate("passport")}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 2,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VerifyAccountStepTwo(
                      documentType: "idCard",
                    ),
                  ),
                );
              },
              child: Container(
                width: size.width,
                padding: EdgeInsets.all(height),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "${AppLocalizations.of(context).translate("idCard")}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
