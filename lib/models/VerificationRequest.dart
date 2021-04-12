import 'package:flutter/material.dart';

class VerificationRequest {
  final String uid;
  final String documentType;
  final String documentRecto;
  final String documentVerso;

  VerificationRequest({
    @required this.documentType,
    @required this.uid,
    @required this.documentRecto,
    this.documentVerso,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['documentType'] = this.documentType;
    data['documentRecto'] = this.documentRecto;
    data['documentVerso'] = this.documentVerso;
    return data;
  }
}
