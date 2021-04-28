import 'package:aircolis/utils/app_localizations.dart';
import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text('${AppLocalizations.of(context).translate("comingSoon")}', style: Theme.of(context).primaryTextTheme.headline3.copyWith(color: Colors.black),),
      ),
    );
  }
}
