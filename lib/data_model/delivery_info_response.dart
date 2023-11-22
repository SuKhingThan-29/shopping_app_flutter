// To parse this JSON data, do
//
//     final deliveryInfoResponse = deliveryInfoResponseFromJson(jsonString);

import 'dart:convert';

List<DeliveryInfoResponse> deliveryInfoResponseFromJson(String str) =>
    List<DeliveryInfoResponse>.from(
        json.decode(str).map((x) => DeliveryInfoResponse.fromJson(x)));

String deliveryInfoResponseToJson(List<DeliveryInfoResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeliveryInfoResponse {
  DeliveryInfoResponse({
    this.name,
    this.ownerId,
    this.cartItems,
    this.carriers,
    this.pickupPoints,
  });

  String? name;
  var ownerId;
  List<CartItem>? cartItems;
  Carriers? carriers;
  List<PickupPoint>? pickupPoints;

  factory DeliveryInfoResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryInfoResponse(
        name: json["name"],
        ownerId: json["owner_id"],
        cartItems: List<CartItem>.from(
            json["cart_items"].map((x) => CartItem.fromJson(x))),
        carriers: Carriers.fromJson(json["carriers"]),
        pickupPoints: List<PickupPoint>.from(
            json["pickup_points"].map((x) => PickupPoint.fromJson(x))),
      );

  Map<String, dynamic> toJson() =>
      {
        "name": name,
        "owner_id": ownerId,
        "cart_items": List<dynamic>.from(cartItems!.map((x) => x.toJson())),
        "carriers": carriers!.toJson(),
        "pickup_points": List<dynamic>.from(
            pickupPoints!.map((x) => x.toJson())),
      };
}

class Carriers {
  Carriers({
    this.data,
  });

  List<Data>? data;

  factory Carriers.fromJson(Map<String, dynamic> json) =>
      Carriers(
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() =>
      {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Data {
  Data({
    this.id,
    this.name,
    this.logo,
    this.transitTime,
    this.freeShipping,
    this.transitPrice,
  });

  var id;
  String? name;
  String? logo;
  var transitTime;
  bool? freeShipping;
  String? transitPrice;

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
        transitTime: json["transit_time"],
        freeShipping: json["free_shipping"],
        transitPrice: json["transit_price"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
        "logo": logo,
        "transit_time": transitTime,
        "free_shipping": freeShipping,
        "transit_price": transitPrice,
      };
}


class CartItem {
  CartItem({
    this.id,
    this.ownerId,
    this.userId,
    this.productId,
    this.productName,
    this.productThumbnailImage,
    this.variation,
    this.price,
    this.currency_symbol,
    this.tax,
    this.shipping_cost,
    this.quantity,
    this.lowerLimit,
    this.upperLimit,
    this.total_price
  });

  var id;
  var ownerId;
  var userId;
  var productId;
  String? productName;
  String? productThumbnailImage;
  String? variation;
  int? price;
  String? currency_symbol;
  int? tax;
  int? shipping_cost;
  int? quantity;
  int? lowerLimit;
  int? upperLimit;
  int? total_price;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      CartItem(
          id: json["id"],
          ownerId: json["owner_id"],
          userId: json["user_id"],
          productId: json["product_id"],
          productName: json["product_name"],
          productThumbnailImage: json["product_thumbnail_image"],
          variation: json["variation"],
          price: json["price"],
          currency_symbol: json["currency_symbol"],
          tax: json["tax"],
          shipping_cost: json[ "shipping_cost"],
          quantity: json["quantity"],
          lowerLimit: json["lower_limit"],
          upperLimit: json["upper_limit"],
          total_price: json["total_price"]

      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "owner_id": ownerId,
        "user_id": userId,
        "product_id": productId,
        "product_name": productName,
        "product_thumbnail_image": productThumbnailImage,
        "variation": variation,
        "price": price,
        "currency_symbol": currency_symbol,
        "tax": tax,
        "shipping_cost": shipping_cost,
        "quantity": quantity,
        "lower_limit": lowerLimit,
        "upper_limit": upperLimit,
        "total_price":total_price
      };
}

class PickupPoint {
  PickupPoint({
    this.id,
    this.staffId,
    this.name,
    this.address,
    this.phone,
    this.pickUpStatus,
    this.cashOnPickupStatus,
  });

  var id;
  var staffId;
  String? name;
  String? address;
  String? phone;
  var pickUpStatus;
  dynamic cashOnPickupStatus;

  factory PickupPoint.fromJson(Map<String, dynamic> json) =>
      PickupPoint(
        id: json["id"],
        staffId: json["staff_id"],
        name: json["name"],
        address: json["address"],
        phone: json["phone"],
        pickUpStatus: json["pick_up_status"],
        cashOnPickupStatus: json["cash_on_pickup_status"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "staff_id": staffId,
        "name": name,
        "address": address,
        "phone": phone,
        "pick_up_status": pickUpStatus,
        "cash_on_pickup_status": cashOnPickupStatus,
      };
}
