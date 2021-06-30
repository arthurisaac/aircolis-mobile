import 'package:aircolis/components/button.dart';
import 'package:aircolis/models/ProviderModel.dart';
import 'package:aircolis/pages/auth/loginPopup.dart';
import 'package:aircolis/pages/posts/newPost/postFormScreen.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  var user = FirebaseAuth.instance?.currentUser;
  InAppPurchaseConnection _inAppPurchaseConnection =
      InAppPurchaseConnection.instance;

  void payer(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    _inAppPurchaseConnection.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);
    return (user == null || user.isAnonymous)
        ? LoginPopupScreen()
        : FutureBuilder(
            future: AuthService().getUserDoc(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null && snapshot.data['isVerified']) {
                  //return PostFormScreen();

                  return Stack(
                    children: [
                      Scaffold(
                        body: SafeArea(
                          child: Container(
                            padding: EdgeInsets.all(space),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.1, 0.4, 0.7, 0.9],
                                colors: [
                                  Color(0xB444CFCA),
                                  Color(0xFF44CFCA),
                                  Color(0xFF5CC4C0),
                                  Color(0xFF38ADA9),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                provider.avaible
                                    ? Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          padding)),
                                              child: Text(
                                                "Abonnement à vie"
                                                    .toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .primaryTextTheme
                                                    .headline5
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            Lottie.asset(
                                                "assets/travelers-find-location.json"),
                                            RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(
                                                    style: Theme.of(context)
                                                        .primaryTextTheme
                                                        .headline6
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "Payer une seule fois et publier vos annonces à volonté à seulement ",
                                                      ),
                                                      TextSpan(
                                                          text: "25 \$",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))
                                                    ])),
                                            SizedBox(
                                              height: space * 2,
                                            ),
                                            ElevatedButton(
                                              onPressed: () {},
                                              child:
                                                  Text("S'abonner maintenant"),
                                            )
                                          ],
                                        ),
                                      )
                                    : Text('Store is Available'),
                                for (var prod in provider.products)
                                  if (provider.hasPurchases(prod.id) !=
                                      null) ...[
                                    Center(
                                      child: FittedBox(
                                        child: Text("Merci!"),
                                      ),
                                    )
                                  ] else ...[
                                    Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        padding)),
                                            child: Text(
                                              "Abonnement à vie".toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .headline5
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Lottie.asset(
                                              "assets/travelers-find-location.json"),
                                          RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .headline6
                                                      .copyWith(
                                                          color: Colors.white),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "Payer une seule fois et publier vos annonces à volonté à seulement ",
                                                    ),
                                                    TextSpan(
                                                        text: "${prod.price}",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                  ])),
                                          SizedBox(
                                            height: space * 2,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              payer(prod);
                                            },
                                            child: Text("S'abonner maintenant"),
                                          )
                                        ],
                                      ),
                                    )
                                  ]
                              ],
                            ),
                          ),
                        ),
                      ),
                      for (var prod in provider.products)
                        if (provider.hasPurchases(prod.id) != null) ...[
                          PostFormScreen()
                        ] else ...[
                          Container()
                        ]
                    ],
                  );
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0.0,
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
                    body: Container(
                      margin: EdgeInsets.all(space),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "images/icons/unverified.svg",
                              width: MediaQuery.of(context).size.height * 0.2,
                            ),
                            SizedBox(
                              height: space * 2,
                            ),
                            Text(
                              "${AppLocalizations.of(context).translate("yourAccountHasNotBeenVerified")}",
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: space * 2,
                            ),
                            AirButton(
                              text: Text(
                                '${AppLocalizations.of(context).translate("confirmAccount")}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => VerifyAccountStep(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: space,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
              if (snapshot.hasError) {
                return SomethingWentWrong(
                  description: snapshot.error.toString(),
                );
              }
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
  }
}
