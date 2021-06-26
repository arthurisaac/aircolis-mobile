import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/auth/loginPopup.dart';
import 'package:aircolis/pages/propositions/newPropositionScreen.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class DetailsPostScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  const DetailsPostScreen({Key key, this.doc}) : super(key: key);

  @override
  _DetailsPostScreenState createState() => _DetailsPostScreenState();
}

class _DetailsPostScreenState extends State<DetailsPostScreen> {
  var radius = 30.0;
  bool animate = false;
  var user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var doc = widget.doc;
    if (animate)
      animate = false;
    else
      animate = true;

    //Country departureCountry = Country.fromJson(doc['departure']);
    //Country arrivalCountry = Country.fromJson(doc['arrival']);
    DateTime departureDate = doc['dateDepart'].toDate();
    String departureDateLocale =
        DateFormat('dd-MM-yyyy hh:mm').format(departureDate);
    DateTime arrivalDate = doc['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat('dd-MM-yyyy hh:mm').format(arrivalDate);

    return (!user.isAnonymous)
        ? Scaffold(
            //extendBodyBehindAppBar: true,
            appBar: AppBar(
              brightness: Brightness.dark,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text("Détails", style: TextStyle(color: Colors.black),),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Stack(
              children: [
                /*Container(
                  height: size.height * 0.3,
                  width: size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/travel.jpeg"),
                      fit: BoxFit.cover,
                      alignment: Alignment.topRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                  ),
                ),*/
                SingleChildScrollView(
                  child: Container(
                    //margin: EdgeInsets.only(top: space * 8),
                    padding: EdgeInsets.all(space),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 85,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        '$departureDateLocale',
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 4, right: 4, top: space / 2),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: SvgPicture.asset(
                                        'images/icons/start.svg',
                                        width: 20,
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 70,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    //height: 100,
                                    padding: EdgeInsets.all(space / 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${AppLocalizations.of(context).translate("start")}',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .bodyText2,
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${doc.get('departure')['city']}',
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .headline6
                                                    .copyWith(
                                                        color: Colors.black),
                                              ),
                                              TextSpan(text: ' \n'),
                                              TextSpan(
                                                text:
                                                    '${doc.get('departure')['country']}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 85,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(arrivalDateLocale),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 4, right: 4),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: SvgPicture.asset(
                                        'images/icons/end.svg',
                                        width: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    //height: 100,
                                    padding: EdgeInsets.all(space / 2),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${AppLocalizations.of(context).translate("arrival")}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[900]),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .bodyText2,
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${doc.get('arrival')['city']}',
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .headline6
                                                    .copyWith(
                                                        color: Colors.black),
                                              ),
                                              TextSpan(text: ' \n'),
                                              TextSpan(
                                                text:
                                                    '${doc.get('arrival')['country']}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: space * 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text('${doc['weight']} Kg'),
                              //Text('${doc['length']}'),
                              //Text('${doc['height']}'),
                              detailBox(
                                  context,
                                  '${doc['parcelWeight'].toInt()}',
                                  'Kg',
                                  '${AppLocalizations.of(context).translate("parcelWeight")}',
                                  'images/icons/start.svg'),
                              detailBox(
                                  context,
                                  '${doc['parcelLength'].toInt()}',
                                  'cm',
                                  '${AppLocalizations.of(context).translate("parcelLength")}',
                                  'images/icons/length.svg'),
                              detailBox(
                                  context,
                                  '${doc['parcelHeight'].toInt()}',
                                  'cm',
                                  '${AppLocalizations.of(context).translate("parcelHeight")}',
                                  'images/icons/height.svg'),
                            ],
                          ),
                          SizedBox(height: space),
                          Divider(
                            height: 2.0,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(height: space),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: space),
                                child: Text(
                                    '${AppLocalizations.of(context).translate("priceKg")}'),
                              ),
                              SizedBox(height: space / 2),
                              Container(
                                //margin: EdgeInsets.only(left: space),
                                child: Text(
                                  '${doc['price']} ${Utils.getCurrencySize(doc['currency'])}',
                                  style: TextStyle(
                                    fontSize: size.width * 0.07,
                                    color: Color(0xFFAC1212),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: space),
                          Divider(
                            height: 2.0,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(
                            height: space,
                          ),
                          Text(
                            '${AppLocalizations.of(context).translate("methodOfPaymentAccept")}',
                          ),
                          Text(
                            doc['paymentMethod'],
                            style: TextStyle(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: space,
                          ),
                          (user != null && doc['uid'] == user.uid)
                              ? Container()
                              : FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Container();
                                    }

                                    if (snapshot.hasData) {
                                      if (snapshot.data.exists) {
                                        if (snapshot.data
                                            .get('isVerified') != null) {
                                          if (snapshot.data.get('isVerified') !=
                                                  null &&
                                              snapshot.data.get('isVerified')) {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                bottom: space * 2,
                                              ),
                                              child: AirButton(
                                                text: Text(
                                                    '${AppLocalizations.of(context).translate("makeAProposal")}'),
                                                onPressed: () {
                                                  showCupertinoModalBottomSheet(
                                                    context: context,
                                                    builder: (context) =>
                                                        NewProposalScreen(
                                                      doc: doc,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                bottom: space * 2,
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            padding),
                                                  ),
                                                  primary: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                onPressed: () {
                                                  showCupertinoModalBottomSheet(
                                                    context: context,
                                                    builder: (context) =>
                                                        VerifyAccountStep(),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              padding)),
                                                  child: Center(
                                                      child: Text(
                                                    'Vérifier votre compte pour faire des propositions',
                                                    textAlign: TextAlign.center,
                                                  )),
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          return Container(
                                            margin: EdgeInsets.all(space),
                                            alignment: Alignment.center,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LoginScreen()));
                                              },
                                              child: Center(
                                                child: Text(
                                                    'Se connecter pour faire des propositions'),
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        return Container(
                                          margin: EdgeInsets.all(space),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                                'Se connecter pour faire des propositions'),
                                          ),
                                        );
                                      }
                                    }

                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }),
                          /*(user != null &&
                            user != widget.doc.get('uid') &&
                            user.emailVerified)
                        ? Container(
                            margin: EdgeInsets.only(
                              bottom: space * 2,
                            ),
                            child: AirButton(
                              text: Text(
                                  '${AppLocalizations.of(context).translate("makeAProposal").toUpperCase()}'),
                              onPressed: () {
                                showCupertinoModalBottomSheet(
                                  context: context,
                                  builder: (context) => NewProposalScreen(
                                    doc: doc,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container()*/
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : LoginPopupScreen();
  }

  Widget detailBox(
      context, String element, String unit, String unitName, String image) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.27,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: space / 2, vertical: space / 2),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(padding / 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //SvgPicture.asset(image),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$element ',
                      style:
                          Theme.of(context).primaryTextTheme.headline5.copyWith(
                                color: Colors.black,
                              ),
                    ),
                    Container(
                      child: Text('$unit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: space / 2,
          ),
          Text(
            'Max. $unitName',
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
