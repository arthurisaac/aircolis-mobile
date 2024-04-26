import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactezNousScreen extends StatelessWidget {
  const ContactezNousScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*title: Text(
          "Contactez-nous",
          style: TextStyle(color: Colors.black),
        ),*/
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("images/contact_us.png"),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyText1
                              ?.copyWith(color: Colors.black, fontSize: 15),
                          children: [
                        TextSpan(
                            text:
                                "Afin de nous améliorer si vous avez: \nUne question ?\nUne Suggestion?\nUn problème?\n\nContactez-nous:")
                      ])),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      var _url = "mailto:aircolis@yahoo.com";
                      _launchURL(_url);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset("images/email.svg", width: 30),
                        SizedBox(width: 5),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  ?.copyWith(color: Colors.black),
                              children: [
                                //TextSpan(text: "Mail: "),
                                TextSpan(
                                    text: "aircolis@yahoo.com",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      var _url = "tel:+33605584358";
                      _launchURL(_url);
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset("images/smartphone.svg", width: 30),
                        SizedBox(width: 5),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  ?.copyWith(color: Colors.black),
                              children: [
                                //TextSpan(text: "Tél: "),
                                TextSpan(
                                    text: "+33 6 05 58 43 58",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      String uri =
                          "https://api.whatsapp.com/send?phone=33755859563&text=Bonjour, Merci de m'envoyer plus d'informations.";
                      _launchURL(Uri.encodeFull(uri));
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset("images/whatsapp.svg", width: 30),
                        SizedBox(width: 5),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  ?.copyWith(color: Colors.black),
                              children: [
                                //TextSpan(text: "Whatsapp: "),
                                TextSpan(
                                    text: "+33 6 05 58 43 58",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      String uri =
                          "https://facebook.com/Aircolis-105633928412162";
                      _launchURL(Uri.encodeFull(uri));
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset("images/facebook.svg", width: 30),
                        SizedBox(width: 5),
                        RichText(
                          text: TextSpan(
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  ?.copyWith(color: Colors.black),
                              children: [
                                //TextSpan(text: "Facebook: "),
                                TextSpan(
                                    text:
                                        "https://fb.com/Aircolis-105633928412162",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: deprecated_member_use
  void _launchURL(_url) async => await launch(_url);
}
