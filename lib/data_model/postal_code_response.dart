// To parse this JSON data, do
//
//     final cityResponse = cityResponseFromJson(jsonString);

import 'dart:convert';

PostalResponse postalResponseFromJson(String str) => PostalResponse.fromJson(json.decode(str));

String postalResponseToJson(PostalResponse data) => json.encode(data.toJson());

class PostalResponse {
  PostalResponse({
    this.data,
    this.success,
    this.status,
  });

  int? data;
  bool? success;
  int? status;

  factory PostalResponse.fromJson(Map<String, dynamic> json) => PostalResponse(
    data: json["data"],
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data,
    "success": success,
    "status": status,
  };
}

