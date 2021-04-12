import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Header extends StatelessWidget {
  final String title;
  final String subTitle;
  final String icon;

  const Header(
      {Key key, @required this.title, this.subTitle, @required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              //padding: EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    subTitle ?? '',
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 150,
            child: Lottie.asset(icon ?? 'assets/sad-empty-box.json',
                fit: BoxFit.cover, repeat: false, width: 150),
          )
        ],
      ),
    );
  }
}
