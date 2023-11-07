// To parse this JSON data, do
//
//     final deliverytype = deliverytypeFromJson(jsonString);

import 'dart:convert';

import 'package:active_ecommerce_flutter/data_model/delivery_type_data.dart';

Deliverytype deliverytypeFromJson(String str) =>
    Deliverytype.fromJson(json.decode(str));

String deliverytypeToJson(Deliverytype data) => json.encode(data.toJson());

class Deliverytype {
  bool success;
  int status;
  List<DeliveryTypeData> deliveryTypeData;

  Deliverytype({
    required this.success,
    required this.status,
    required this.deliveryTypeData,
  });

  factory Deliverytype.fromJson(Map<String, dynamic> json) => Deliverytype(
        success: json["success"],
        status: json["status"],
    deliveryTypeData: List<DeliveryTypeData>.from(json["data"].map((x) => DeliveryTypeData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "status": status,
        "data": List<dynamic>.from(deliveryTypeData.map((x) => x.toJson())),
      };
}


