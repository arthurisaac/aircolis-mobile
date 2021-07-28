import 'package:aircolis/models/Airport.dart';
import 'package:flutter/material.dart';

class Post {
  String uid;
  Airport departure;
  Airport arrival;
  String departureCity;
  String arrivalCity;
  DateTime dateDepart;
  DateTime dateArrivee;
  double price;
  String paymentMethod;
  double parcelHeight;
  double parcelLength;
  String currency;
  double parcelWeight;
  DateTime createdAt;
  DateTime deletedAt;
  bool visible;
  List<dynamic> tracking;
  bool isFinished;
  bool isDeleted;

  Post({
    @required this.uid,
    this.departure,
    this.arrival,
    @required this.dateDepart,
    @required this.dateArrivee,
    @required this.price,
    @required this.currency,
    @required this.paymentMethod,
    @required this.parcelWeight,
    @required this.createdAt,
    @required this.visible,
    this.deletedAt,
    this.parcelLength,
    this.parcelHeight,
    this.tracking,
    this.isFinished,
    this.isDeleted,
  });

  Post.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    departureCity = json['departureCity'];
    arrivalCity = json['arrivalCity'];
    departure = json['departure'];
    arrival = json['arrival'];
    dateDepart = json['dateDepart'];
    dateArrivee = json['dateArrivee'];
    price = json['price'];
    currency = json['currency'];
    paymentMethod = json['paymentMethod'];
    parcelLength = json['parcelLength'];
    parcelHeight = json['parcelHeight'];
    parcelWeight = json['parcelWeight'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    visible = json['visible'];
    tracking = json['tracking'];
    isFinished = json['isFinished'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uid'] = this.uid;
    data['departure'] = this.departure.toJson();
    data['arrival'] = this.arrival.toJson();
    data['dateDepart'] = this.dateDepart;
    data['dateArrivee'] = this.dateArrivee;
    data['price'] = this.price;
    data['currency'] = this.currency;
    data['paymentMethod'] = this.paymentMethod;
    data['parcelLength'] = this.parcelLength;
    data['parcelHeight'] = this.parcelHeight;
    data['parcelWeight'] = this.parcelWeight;
    data['created_at'] = this.createdAt;
    data['deleted_at'] = this.deletedAt;
    data['visible'] = this.visible;
    data['tracking'] = this.tracking;
    data['isFinished'] = this.isFinished;
    data['isDeleted'] = this.isDeleted;

    return data;
  }
}
