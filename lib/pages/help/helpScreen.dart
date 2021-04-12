import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(height: space),
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: space),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).translate("help")}',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  child: Image.asset(
                    "images/circle_group.png",
                    width: 110,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: space * 2,),
          Container(
            child: Text("Comment publier une annonce?"),
          ),
          SizedBox(height: space),
          Container(
            child: Text("Comment suivre vos colis?"),
          ),
          SizedBox(height: space),
          Container(
            child: Text("Comment faire une proposition?"),
          ),
          SizedBox(height: space),
          Container(
            child: Text("Condition générale d'utilisation ?"),
          )
        ],
      ),
    );
  }
}
