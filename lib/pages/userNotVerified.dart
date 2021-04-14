import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';

class UserNotVerified extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(space),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Veuillez vérifier votre compte email avant de continuer',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline6
                  .copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: space * 3),
            Container(
              alignment: Alignment.center,
              child: GestureDetector(
                child: Container(
                  margin:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text("${AppLocalizations.of(context).translate('logout')}",
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                ),
                onTap: () {
                  AuthService().signOut().then((value) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginScreen()));
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
