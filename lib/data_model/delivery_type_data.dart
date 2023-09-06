class DeliveryTypeData {
  int id;
  int stateId;
  int cityId;
  int price;
  String deliveryName;
  String deliveryDescription;
  int status;

  DeliveryTypeData({
    required this.id,
    required this.stateId,
    required this.cityId,
    required this.price,
    required this.deliveryName,
    required this.deliveryDescription,
    required this.status,
  });

  factory DeliveryTypeData.fromJson(Map<String, dynamic> json) => DeliveryTypeData(
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