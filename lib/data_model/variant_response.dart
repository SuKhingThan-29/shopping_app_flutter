// To parse this JSON VariantData, do
//
//     final variantResponse = variantResponseFromJson(jsonString);

import 'dart:convert';

VariantResponse variantResponseFromJson(String str) =>
    VariantResponse.fromJson(json.decode(str));

String variantResponseToJson(VariantResponse VariantData) =>
    json.encode(VariantData.toJson());

class VariantResponse {
  bool? result;
  VariantData? variantData;

  VariantResponse({
    this.result,
    this.variantData,
  });

  factory VariantResponse.fromJson(Map<String, dynamic> json) =>
      VariantResponse(
        result: json["result"],
        variantData: VariantData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "data": variantData!.toJson(),
      };
}
class Buy_x_get_x_quantity {
  int? outOfQuantity;
  int? plus;


  Buy_x_get_x_quantity({
    this.outOfQuantity,
    this.plus,
  });

  factory Buy_x_get_x_quantity.fromJson(Map<String, dynamic> json) => Buy_x_get_x_quantity(
    outOfQuantity: json["outOfQuantity"]??0,
    plus: json["plus"]??0,

  );

  Map<String, dynamic> toJson() => {
    "outOfQuantity": outOfQuantity,
    "plus": plus,

  };


}
class Buy_x_get_y_quantity {
  int? productId;
  int? stockId;
  String? name;


  Buy_x_get_y_quantity({
    this.productId,
    this.stockId,
    this.name
  });

  factory Buy_x_get_y_quantity.fromJson(Map<String, dynamic> json) => Buy_x_get_y_quantity(
    productId: json["productId"]??0,
    stockId: json["stockId"]??0,
    name:json["name"]??""

  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "stockId": stockId,
    "name":name

  };


}
class VariantData {
  String? price;
  int? stock;
  var stockTxt;
  int? digital;
  String? variant;
  String? variation;
  int? maxLimit;
  int? inStock;
  String? image;
  Buy_x_get_x_quantity? buy_x_get_x_quantity;
  List<Buy_x_get_y_quantity>? buy_x_get_y_quantity;

  VariantData({
    this.price,
    this.stock,
    this.stockTxt,
    this.digital,
    this.variant,
    this.variation,
    this.maxLimit,
    this.inStock,
    this.image,
    this.buy_x_get_x_quantity,
     this.buy_x_get_y_quantity,
  });

  factory VariantData.fromJson(Map<String, dynamic> json) => VariantData(
        price: json["price"],
        stock: int.parse(json["stock"].toString()),
        stockTxt: json["stock_txt"],
        digital: int.parse(json["digital"].toString()),
        variant: json["variant"],
        variation: json["variation"],
        maxLimit: int.parse(json["max_limit"].toString()),
        inStock: int.parse(json["in_stock"].toString()),
        image: json["image"],
    buy_x_get_x_quantity: Buy_x_get_x_quantity.fromJson(json['buy_x_get_x_quantity']),
    buy_x_get_y_quantity: List<Buy_x_get_y_quantity>.from(json["buy_x_get_y_quantity"].map((x) =>Buy_x_get_y_quantity.fromJson(x))).isEmpty?[]:List<Buy_x_get_y_quantity>.from(json["buy_x_get_y_quantity"].map((x) =>Buy_x_get_y_quantity.fromJson(x)))
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "stock": stock,
        "digital": digital,
        "variant": variant,
        "variation": variation,
        "max_limit": maxLimit,
        "in_stock": inStock,
        "image": image,
        "buy_x_get_x_quantity":buy_x_get_x_quantity!.toJson(),
    "buy_x_get_y_quantity": List<dynamic>.from(buy_x_get_y_quantity!.map((x) => x.toJson())),

  };
}
