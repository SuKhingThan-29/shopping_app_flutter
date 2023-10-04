// To parse this JSON data, do
//
//     final noti = notiFromJson(jsonString);

import 'dart:convert';

Noti notiFromJson(String str) => Noti.fromJson(json.decode(str));

String notiToJson(Noti data) => json.encode(data.toJson());

class Noti {
  bool result;
  NotiData data;

  Noti({
    required this.result,
    required this.data,
  });

  factory Noti.fromJson(Map<String, dynamic> json) => Noti(
        result: json["result"],
        data: NotiData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "data": data.toJson(),
      };
}

class NotiData {
  int currentPage;
  List<Datum> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  NotiData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory NotiData.fromJson(Map<String, dynamic> json) => NotiData(
        currentPage: json["current_page"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Datum {
  String id;
  String type;
  String notifiableType;
  int notifiableId;
  DatumData data;
  dynamic readAt;
  DateTime createdAt;
  DateTime updatedAt;

  Datum({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        type: json["type"],
        notifiableType: json["notifiable_type"],
        notifiableId: json["notifiable_id"],
        data: DatumData.fromJson(json["data"]),
        readAt: json["read_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "notifiable_type": notifiableType,
        "notifiable_id": notifiableId,
        "data": data.toJson(),
        "read_at": readAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class DatumData {
  int orderId;
  String orderCode;
  int userId;
  int sellerId;
  String status;

  DatumData({
    required this.orderId,
    required this.orderCode,
    required this.userId,
    required this.sellerId,
    required this.status,
  });

  factory DatumData.fromJson(Map<String, dynamic> json) => DatumData(
        orderId: json["order_id"],
        orderCode: json["order_code"],
        userId: json["user_id"],
        sellerId: json["seller_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "order_code": orderCode,
        "user_id": userId,
        "seller_id": sellerId,
        "status": status,
      };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
