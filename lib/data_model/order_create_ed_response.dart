// To parse this JSON data, do
//
//     final orderCreateResponse = orderCreateResponseFromJson(jsonString);

import 'dart:convert';

OrderCreateEdResponse orderCreateEdResponseFromJson(String str) => OrderCreateEdResponse.fromJson(json.decode(str));

String orderCreateResponseToJson(OrderCreateEdResponse data) => json.encode(data.toJson());

class OrderCreateEdResponse {
  OrderCreateEdResponse({
    this.combined_order_id,
    this.message,
    this.result,
    this.url,

  });

  int? combined_order_id;
  String? message;
  bool? result;
  String? url;



  factory OrderCreateEdResponse.fromJson(Map<String, dynamic> json) => OrderCreateEdResponse(
    combined_order_id: json["combined_order_id"],
    message: json["message"],
    result: json["result"],
      url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "combined_order_id": combined_order_id,
    "message": message,
    "result": result,
    "url":url,
  };
}