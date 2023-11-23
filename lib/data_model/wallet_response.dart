// To parse this JSON data, do
//
//     final wallet = walletFromJson(jsonString);

import 'dart:convert';

Wallet walletFromJson(String str) => Wallet.fromJson(json.decode(str));

String walletToJson(Wallet data) => json.encode(data.toJson());

class Wallet {
  bool result;
  String message;
  String url;

  Wallet({
    required this.result,
    required this.message,
    required this.url,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      result: json["result"] ??
          false, // Provide a default value if 'result' is null
      message:
          json["message"] ?? "", // Provide a default value if 'message' is null
      url: json["url"] ?? "", // Provide a default value if 'url' is null
    );
  }

  Map<String, dynamic> toJson() => {
        "result": result,
        "message": message,
        "url": url,
      };
}
