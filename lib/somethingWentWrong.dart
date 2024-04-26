import 'package:flutter/material.dart';

class SomethingWentWrong extends StatelessWidget {
  final String? description;
  const SomethingWentWrong({Key? key, this.description = ""}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text(
            '$description',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}
