import 'dart:async';
import 'dart:io';

import 'package:aircolis/components/button.dart';
import 'package:aircolis/pages/auth/loginPopup.dart';
import 'package:aircolis/pages/posts/newPost/postFormScreen.dart';
import 'package:aircolis/pages/verifiedAccount/verifyAccountStep.dart';
import 'package:aircolis/services/authService.dart';
import 'package:aircolis/somethingWentWrong.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/consumable_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

const bool _kAutoConsume = true;

const String _kConsumableId = 'in_app_payment_voyageur';
const List<String> _kProductIds = <String>[
  _kConsumableId,
];

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  var user = FirebaseAuth.instance?.currentUser;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _isAvailable ? _buildRestoreButton() : Container(),
            !_isAvailable ? _buildConnectionCheckTile() : Container(),
            _buildProductList(),
            //_buildConsumableBox(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: (user == null || user.isAnonymous)
          ? LoginPopupScreen()
          : FutureBuilder(
              future: AuthService().getUserDoc(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null && snapshot.data['isVerified']) {
                    return Container(
                      width: double.infinity,
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
                      child: Stack(
                        children: stack,
                      ),
                    );
                  }
                  return unVerified();
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
            ),
    );
  }

  Widget unVerified() {
    return Container(
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
                  fontSize: MediaQuery.of(context).size.width * 0.04,
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
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text(
          'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this phone been configured correctly? Report the bug to the Aircolis support.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Vérification en cours...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    //final ListTile productHeader = ListTile(title: Text('Products for Sale'));
    // List<ListTile> productList = <ListTile>[];
    List<Widget> productList = <Widget>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(
        ListTile(
          title: Text('[${_notFoundIds.join(", ")}] non trouvé',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text('Une erreur s\'est prroduite.'),
        ),
      );
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(
      _products.map(
        (ProductDetails productDetails) {
          PurchaseDetails previousPurchase = purchases[productDetails.id];
          return Column(
            children: [
              Lottie.asset("assets/travelers-find-location.json"),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(color: Colors.black),
                  children: [
                    TextSpan(
                      text:
                          "Payer une seule fois et publier vos annonces à volonté à seulement ",
                    ),
                    TextSpan(
                      text: "${productDetails.price}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: space,
              ),
              previousPurchase != null
                  ? Icon(Icons.check)
                  : TextButton(
                      child: Text("Payer maintenant"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        primary: Colors.white,
                      ),
                      onPressed: () {
                        PurchaseParam purchaseParam;

                        if (Platform.isAndroid) {
                          // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                          // verify the latest status of you your subscription by using server side receipt validation
                          // and update the UI accordingly. The subscription purchase status shown
                          // inside the app may not be accurate.
                          final oldSubscription =
                              _getOldSubscription(productDetails, purchases);

                          purchaseParam = GooglePlayPurchaseParam(
                              productDetails: productDetails,
                              applicationUserName: null,
                              changeSubscriptionParam: (oldSubscription != null)
                                  ? ChangeSubscriptionParam(
                                      oldPurchaseDetails: oldSubscription,
                                      prorationMode: ProrationMode
                                          .immediateWithTimeProration,
                                    )
                                  : null);
                        } else {
                          purchaseParam = PurchaseParam(
                            productDetails: productDetails,
                            applicationUserName: null,
                          );
                        }

                        if (productDetails.id == _kConsumableId) {
                          _inAppPurchase.buyConsumable(
                              purchaseParam: purchaseParam,
                              autoConsume: _kAutoConsume || Platform.isIOS);
                        } else {
                          _inAppPurchase.buyNonConsumable(
                              purchaseParam: purchaseParam);
                        }
                      },
                    )
            ],
          );
        },
      ),
    );

    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Column(children: <Widget>[] + productList),
    );
  }

  Card _buildConsumableBox() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Vérification en cours...'))));
    }
    if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
      return Card();
    }
    final ListTile consumableHeader =
        ListTile(title: Text('Purchased consumables'));
    final List<Widget> tokens = _consumables.map((String id) {
      return GridTile(
        child: IconButton(
          icon: Icon(
            Icons.stars,
            size: 42.0,
            color: Colors.orange,
          ),
          splashColor: Colors.yellowAccent,
          onPressed: () => consume(id),
        ),
      );
    }).toList();
    return Card(
        child: Column(children: <Widget>[
      consumableHeader,
      Divider(),
      GridView.count(
        crossAxisCount: 5,
        children: tokens,
        shrinkWrap: true,
        padding: EdgeInsets.all(16.0),
      )
    ]));
  }

  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text(
              'Restaurer votre souscription',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              primary: Colors.black,
            ),
            onPressed: () => _inAppPurchase.restorePurchases(),
          ),
        ],
      ),
    );
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID);
      List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  GooglePlayPurchaseDetails _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails oldSubscription;
    return oldSubscription;
  }

/*void payer(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    _inAppPurchaseConnection.buyNonConsumable(purchaseParam: purchaseParam);
  }*/

/*@override
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
                            width: double.infinity,
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
                                    ? Container()
                                    : Text(
                                        "Vous n'êtes pas éligigle pour publier des annonces."),
                                for (var prod in provider.products)
                                  if (provider.hasPurchases(prod.id) !=
                                      null) ...[
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PostFormScreen()));
                                        },
                                        child: Text("Continuer!"),
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
  }*/
}
