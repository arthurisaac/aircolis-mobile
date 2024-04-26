import 'package:flutter/material.dart';

class Tracking {
  String? title;
  bool? validated;
  DateTime? creation;

  Tracking({
    @required this.title,
    @required this.validated,
  });

  Tracking.fromJson(Map<String, dynamic> json) {
    creation = json['creation'];
    title = json['title'];
    validated = json['validated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;
    data['creation'] = this.creation;
    data['validated'] = this.validated;
    return data;
  }
}
