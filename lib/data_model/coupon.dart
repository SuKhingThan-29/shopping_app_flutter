// To parse this JSON data, do
//
//     final buyCoupon = buyCouponFromJson(jsonString);

import 'dart:convert';

BuyCoupon buyCouponFromJson(String str) => BuyCoupon.fromJson(json.decode(str));

String buyCouponToJson(BuyCoupon data) => json.encode(data.toJson());

class BuyCoupon {
  List<CouponData> data;
  Links links;
  //Meta meta;

  BuyCoupon({
    required this.data,
    required this.links,
   // required this.meta,
  });

  factory BuyCoupon.fromJson(Map<String, dynamic> json) => BuyCoupon(
        data: List<CouponData>.from(json["data"].map((x) => CouponData.fromJson(x))),
        links: Links.fromJson(json["links"]),
        //meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "links": links.toJson(),
       // "meta": meta.toJson(),
      };
}

class CouponData {
  int id;
  String code;
  String type;
  String details;
  int discount;
  String discountType;
  String startDate;
  String endDate;
  int pointAmount;
  bool isVerified;
  bool isAvailable;
  bool isOwned;
  bool canBuy;

  CouponData({
    required this.id,
    required this.code,
    required this.type,
    required this.details,
    required this.discount,
    required this.discountType,
    required this.startDate,
    required this.endDate,
    required this.pointAmount,
    required this.isVerified,
    required this.isAvailable,
    required this.isOwned,
    required this.canBuy,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) => CouponData(
        id: json["id"],
        code: json["code"],
        type: json["type"],
        details: json["details"],
        discount: json["discount"],
        discountType: json["discount_type"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        pointAmount: json["point_amount"],
        isVerified: json["is_verified"],
        isAvailable: json["is_available"],
        isOwned: json["is_owned"],
        canBuy: json["can_buy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "type": type,
        "details": details,
        "discount": discount,
        "discount_type": discountType,
        "start_date": startDate,
        "end_date": endDate,
        "point_amount": pointAmount,
        "is_verified": isVerified,
        "is_available": isAvailable,
        "is_owned": isOwned,
        "can_buy": canBuy,
      };
}

class Links {
  String first;
  String last;
  dynamic prev;
  dynamic next;

  Links({
    required this.first,
    required this.last,
    required this.prev,
    required this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        first: json["first"],
        last: json["last"],
        prev: json["prev"],
        next: json["next"],
      );

  Map<String, dynamic> toJson() => {
        "first": first,
        "last": last,
        "prev": prev,
        "next": next,
      };
}

class Meta {
  int currentPage;
  int from;
  int lastPage;
  List<Link> links;
  String path;
  int perPage;
  int to;
  int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["current_page"],
        from: json["from"],
        lastPage: json["last_page"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        path: json["path"],
        perPage: json["per_page"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "from": from,
        "last_page": lastPage,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "path": path,
        "per_page": perPage,
        "to": to,
        "total": total,
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
