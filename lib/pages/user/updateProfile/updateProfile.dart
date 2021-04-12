import 'package:flutter/material.dart';

import 'components/body.dart';

class UpdateProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(AppLocalizations.of(context).translate("profile") ?? '', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(child: UpdateBodyProfile()),
    );
  }
}
