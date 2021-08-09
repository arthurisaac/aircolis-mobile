import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactezNousScreen extends StatelessWidget {
  const ContactezNousScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contactez-nous"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Avez-vous une suggestion? Rencontrez-vous un problème? Avez-vous des questions? Contactez-nous :"),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                var _url = "mailto:goubarodrigue@yahoo.fr";
                _launchURL(_url);
              },
              child: RichText(text: TextSpan(
                style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(color: Colors.black),
                children: [
                  TextSpan(text: "Mail: "),
                  TextSpan(text: "goubarodrigue@yahoo.fr", style: TextStyle(color: Theme.of(context).primaryColor)),
                ]
              ),),
            ),
            GestureDetector(
              onTap: () {
                var _url = "tel:+33755859563";
                _launchURL(_url);
              },
              child: RichText(text: TextSpan(
                style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(color: Colors.black),
                children: [
                  TextSpan(text: "Tél: "),
                  TextSpan(text: "+33 7 55 85 95 63", style: TextStyle(color: Theme.of(context).primaryColor)),
                ]
              ),),
            ),
            GestureDetector(
              onTap: () {
                String uri =
                    "https://api.whatsapp.com/send?phone=33755859563&text=Bonjour, Merci de m'envoyer plus d'informations.";
                _launchURL(Uri.encodeFull(uri));
              },
              child: RichText(text: TextSpan(
                style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(color: Colors.black),
                children: [
                  TextSpan(text: "Whatsapp: "),
                  TextSpan(text: "+33 7 55 85 95 63", style: TextStyle(color: Theme.of(context).primaryColor)),
                ]
              ),),
            ),
          ],
        )
      ),
    );
  }

  void _launchURL(_url) async => await launch(_url);
}
