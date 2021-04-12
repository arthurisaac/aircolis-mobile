import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/propositions/newPropositionScreen.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  var radius = 50.0;
  bool animate = false;

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
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(departureDate);
    DateTime arrivalDate = doc['dateArrivee'].toDate();
    String arrivalDateLocale =
        DateFormat.yMMMd('${AppLocalizations.of(context).locale}')
            .format(arrivalDate);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height * 0.3,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg.png"),
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header(title: '${AppLocalizations.of(context).translate("adDetail")}',),
                  SizedBox(
                    height: space * 3,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: space,
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate("adDetail")}',
                    style: Theme.of(context).primaryTextTheme.headline5,
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(space),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: space,
                        ),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 4, right: 4, top: space / 2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50)),
                                    child: SvgPicture.asset(
                                      'images/icons/start.svg',
                                      width: 30,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 60,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  //height: 100,
                                  padding: EdgeInsets.all(space / 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context).translate("start")}',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${doc.get('departure')['city']}',
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .headline6
                                                .copyWith(color: Colors.black),
                                          ),
                                          SizedBox(
                                            width: space / 2,
                                          ),
                                          Text(
                                            '${doc.get('departure')['country']}',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '$departureDateLocale',
                                          ),
                                          SizedBox(
                                            width: space / 2,
                                          ),
                                          Text(doc['heureDepart']),
                                        ],
                                      ),
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  /*Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.black,
                                    ),*/
                                  Container(
                                    margin: EdgeInsets.only(left: 4, right: 4),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50)),
                                    child: SvgPicture.asset(
                                      'images/icons/end.svg',
                                      width: 30,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  //height: 100,
                                  padding: EdgeInsets.all(space / 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context).translate("arrival")}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[900]),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${doc.get('arrival')['city']}',
                                            style: Theme.of(context)
                                                .primaryTextTheme
                                                .headline6
                                                .copyWith(color: Colors.black),
                                          ),
                                          SizedBox(
                                            width: space / 2,
                                          ),
                                          Text(
                                            '${doc.get('arrival')['country']}',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            arrivalDateLocale,
                                          ),
                                          SizedBox(
                                            width: space / 2,
                                          ),
                                          Text(
                                            doc['heureArrivee'],
                                          ),
                                        ],
                                      ),
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
                            //TODO
                            detailBox(
                                context,
                                '${doc['weight']}',
                                'Kg',
                                '${AppLocalizations.of(context).translate("parcelWeight")}',
                                'images/icons/start.svg'),
                            detailBox(
                                context,
                                '${doc['length']}',
                                'cm',
                                '${AppLocalizations.of(context).translate("parcelLength")}',
                                'images/icons/length.svg'),
                            detailBox(
                                context,
                                '${doc['height']}',
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
                              margin: EdgeInsets.only(left: space),
                              child: Text(
                                  '${AppLocalizations.of(context).translate("priceKg")}'),
                            ),
                            SizedBox(height: space / 2),
                            Container(
                              margin: EdgeInsets.only(left: space),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          bottom: space * 2,
          left: space,
          right: space,
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
      ),
    );
  }

  Widget detailBox(
      context, String element, String unit, String unitName, String image) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.26,
      child: Column(
        children: [
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: space, vertical: space / 2),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(padding / 2)),
            child: Column(
              children: [
                //SvgPicture.asset(image),
                Row(
                  children: [
                    Text('$element ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headline5
                            .copyWith(color: Colors.black)),
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
