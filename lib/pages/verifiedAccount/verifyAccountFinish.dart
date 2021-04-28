import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VerifyAccountFinish extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.all(space),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("images/icons/verifying.svg", width: MediaQuery.of(context).size.height * 0.2,),
            SizedBox(
              height: space * 2,
            ),
            Text(
              '${AppLocalizations.of(context).translate("weWillCheckYourDocumentsShortly")}',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: space * 2,
            ),
            AirButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              text: Text('${AppLocalizations.of(context).translate("back")}'),
              icon: Icons.check,
            )
          ],
        ),
      ),
    );
  }
}
