import 'dart:convert';

UnReadMessage unReadMessageFromJson(String str) => UnReadMessage.fromJson(json.decode(str));

String unReadMessagenToJson(UnReadMessage obj) => json.encode(obj.toJson());

class UnReadMessage {
  bool result;
  int count;

  UnReadMessage({
    required this.result,
    required this.count,
  });

  factory UnReadMessage.fromJson(Map<String, dynamic> json) => UnReadMessage(
    result: json["result"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "result": result,
    "count": count,
  };
}
