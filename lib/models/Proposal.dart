import 'package:flutter/material.dart';

class Proposal {
  final String uid;
  final String post;
  final double length;
  final double height;
  final double weight;
  final String description;
  final bool isApproved;
  final bool isReceived;

  //final bool isDelivered;
  final bool isNew;
  final bool canUse;
  final double total;
  final double rating;
  DateTime creation;

  Proposal({
    @required this.uid,
    @required this.post,
    @required this.length,
    @required this.height,
    @required this.weight,
    @required this.description,
    this.isApproved,
    this.isReceived,
    //@required this.isDelivered,
    this.isNew,
    this.canUse,
    this.rating,
    @required this.total,
    this.creation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['post'] = this.post;
    data['length'] = this.length;
    data['height'] = this.height;
    data['weight'] = this.weight;
    data['description'] = this.description;
    data['isApproved'] = this.isApproved;
    data['isReceived'] = this.isReceived;
    //data['isDelivered'] = this.isDelivered;
    data['isNew'] = this.isNew;
    data['canUse'] = this.canUse;
    data['total'] = this.total;
    data['rating'] = this.rating;
    data['creation'] = this.creation;
    return data;
  }
}
