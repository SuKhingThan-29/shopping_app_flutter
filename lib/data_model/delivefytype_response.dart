// To parse this JSON data, do
//
//     final deliverytype = deliverytypeFromJson(jsonString);

import 'dart:convert';

Deliverytype deliverytypeFromJson(String str) =>
    Deliverytype.fromJson(json.decode(str));

String deliverytypeToJson(Deliverytype data) => json.encode(data.toJson());

class Deliverytype {
  bool success;
  int status;
  List<Datum> data;

  Deliverytype({
    required this.success,
    required this.status,
    required this.data,
  });

  factory Deliverytype.fromJson(Map<String, dynamic> json) => Deliverytype(
        success: json["success"],
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int id;
  int stateId;
  int cityId;
  int price;
  String deliveryName;
  String deliveryDescription;
  int status;

  Datum({
    required this.id,
    required this.stateId,
    required this.cityId,
    required this.price,
    required this.deliveryName,
    required this.deliveryDescription,
    required this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        price: json["price"],
        deliveryName: json["delivery_name"],
        deliveryDescription: json["delivery_description"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "state_id": stateId,
        "city_id": cityId,
        "price": price,
        "delivery_name": deliveryName,
        "delivery_description": deliveryDescription,
        "status": status,
      };
}
