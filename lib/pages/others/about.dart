import 'package:aircolis/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(space),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("images/aircolis.png"),
                width: 100,
                height: 100,
              ),
              SizedBox(height: space),
              Text('Version 1.0.0'),
              SizedBox(height: space),
              RichText(
                text: TextSpan(
                    style: Theme.of(context)
                        .primaryTextTheme
                        .bodyText2
                        .copyWith(color: Colors.black, fontSize: 14),
                    text:
                        "Aircolis est une application qui met en relation les voyageurs et les expéditeurs de colis. Les voyageurs publient les informations du voyage, le poids qu’ils peuvent transporter. Tout expéditeur de colis souhaitant envoyer son colis peut faire des propositions du nombre de kilo qu’il souhaite et entrer en contact avec le voyageur."),
              ),
              SizedBox(height: space),
              Container(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    String uri = CGU_LINK;
                    await canLaunch(Uri.encodeFull(uri));
                    await launch(Uri.encodeFull(uri));
                  },
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context)
                          .primaryTextTheme
                          .bodyText2
                          .copyWith(color: Colors.black),
                      children: [
                        TextSpan(text: "Voir nos "),
                        TextSpan(text: "conditions d'utilisation", style: TextStyle(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
