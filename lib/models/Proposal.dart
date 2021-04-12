import 'package:flutter/material.dart';

class Proposal {
  final String uid;
  final String post;
  final double length;
  final double height;
  final double weight;
  final String description;
  final bool isApproved;
  //final bool isReceived;
  //final bool isDelivered;
  final bool isNew;
  DateTime creation;

  Proposal({
    @required this.uid,
    @required this.post,
    @required this.length,
    @required this.height,
    @required this.weight,
    @required this.description,
    @required this.isApproved,
    //@required this.isReceived,
    //@required this.isDelivered,
    @required this.isNew,
    @required this.creation
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
    //data['isReceived'] = this.isReceived;
    //data['isDelivered'] = this.isDelivered;
    data['isNew'] = this.isNew;
    data['creation'] = this.creation;
    return data;
  }
}
