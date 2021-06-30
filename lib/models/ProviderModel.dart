import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProviderModel with ChangeNotifier {
  InAppPurchaseConnection _inAppPurchaseConnection =
      InAppPurchaseConnection.instance;
  bool avaible = true;
  // ignore: cancel_subscriptions
  StreamSubscription subscription;
  final String voyageurID = (Platform.isIOS)
      ? "in_app_payment_voyageur_ios"
      : "in_app_payment_voyageur";

  bool _isPurchased = false;

  bool get isPurchased => _isPurchased;

  set isPurchased(bool value) {
    _isPurchased = value;
    notifyListeners();
  }

  List _purchases = [];

  List get purchases => _purchases;

  set purchases(List value) {
    _purchases = value;
    notifyListeners();
  }

  List _products = [];

  List get products => _products;

  set products(List value) {
    _products = value;
    notifyListeners();
  }

  PurchaseDetails hasPurchases(String productID) {
    return purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  void verifyPurchase() {
    PurchaseDetails purchaseDetails = hasPurchases(voyageurID);
    if (purchaseDetails != null &&
        purchaseDetails.status == PurchaseStatus.purchased) {
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchaseConnection.completePurchase(purchaseDetails);
        isPurchased = true;
      }
    }
  }

  Future<void> _getProducts() async {
    Set<String> ids = Set.from([voyageurID]);
    ProductDetailsResponse response =
        await _inAppPurchaseConnection.queryProductDetails(ids);
    products = response.productDetails;
  }

  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response =
        await _inAppPurchaseConnection.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        _inAppPurchaseConnection.consumePurchase(purchase);
      }
    }
    purchases = response.pastPurchases;
  }

  void initialize() async {
    avaible = await _inAppPurchaseConnection.isAvailable();
    if (avaible) {
      await _getProducts();
      await _getPastPurchases();
      verifyPurchase();
      subscription =
          _inAppPurchaseConnection.purchaseUpdatedStream.listen((data) {
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }
}
