import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String description;
  const Loading({Key key, this.description}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
