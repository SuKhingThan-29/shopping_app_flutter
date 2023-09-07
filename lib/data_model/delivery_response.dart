// To parse this JSON data, do
//
//     final deliveryResponse = deliveryResponseFromJson(jsonString);

import 'dart:convert';

DeliveryResponse deliveryResponseFromJson(String str) =>
    DeliveryResponse.fromJson(json.decode(str));

String deliveryResponseToJson(DeliveryResponse data) =>
    json.encode(data.toJson());

class DeliveryResponse {
  bool success;
  int status;
  List<Cart> carts;
  ShippingInfo shippingInfo;
  int total;
  Delivery delivery;
  User user;
  List<dynamic> availableCoupons;

  DeliveryResponse({
    required this.success,
    required this.status,
    required this.carts,
    required this.shippingInfo,
    required this.total,
    required this.delivery,
    required this.user,
    required this.availableCoupons,
  });

  factory DeliveryResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryResponse(
        success: json["success"],
        status: json["status"],
        carts: List<Cart>.from(json["carts"].map((x) => Cart.fromJson(x))),
        shippingInfo: ShippingInfo.fromJson(json["shipping_info"]),
        total: json["total"],
        delivery: Delivery.fromJson(json["delivery"]),
        user: User.fromJson(json["user"]),
        availableCoupons:
            List<dynamic>.from(json["availableCoupons"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "status": status,
        "carts": List<dynamic>.from(carts.map((x) => x.toJson())),
        "shipping_info": shippingInfo.toJson(),
        "total": total,
        "delivery": delivery.toJson(),
        "user": user.toJson(),
        "availableCoupons": List<dynamic>.from(availableCoupons.map((x) => x)),
      };
}

class Cart {
  int id;
  int ownerId;
  int userId;
  dynamic tempUserId;
  int addressId;
  int productId;
  dynamic variation;
  int price;
  int tax;
  int shippingCost;
  String shippingType;
  int pickupPoint;
  dynamic carrierId;
  int discount;
  dynamic productReferralCode;
  dynamic couponCode;
  int couponApplied;
  int quantity;
  DateTime createdAt;
  DateTime updatedAt;

  Cart({
    required this.id,
    required this.ownerId,
    required this.userId,
    required this.tempUserId,
    required this.addressId,
    required this.productId,
    required this.variation,
    required this.price,
    required this.tax,
    required this.shippingCost,
    required this.shippingType,
    required this.pickupPoint,
    required this.carrierId,
    required this.discount,
    required this.productReferralCode,
    required this.couponCode,
    required this.couponApplied,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        ownerId: json["owner_id"],
        userId: json["user_id"],
        tempUserId: json["temp_user_id"],
        addressId: json["address_id"],
        productId: json["product_id"],
        variation: json["variation"],
        price: json["price"],
        tax: json["tax"],
        shippingCost: json["shipping_cost"],
        shippingType: json["shipping_type"],
        pickupPoint: json["pickup_point"],
        carrierId: json["carrier_id"],
        discount: json["discount"],
        productReferralCode: json["product_referral_code"],
        couponCode: json["coupon_code"],
        couponApplied: json["coupon_applied"],
        quantity: json["quantity"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner_id": ownerId,
        "user_id": userId,
        "temp_user_id": tempUserId,
        "address_id": addressId,
        "product_id": productId,
        "variation": variation,
        "price": price,
        "tax": tax,
        "shipping_cost": shippingCost,
        "shipping_type": shippingType,
        "pickup_point": pickupPoint,
        "carrier_id": carrierId,
        "discount": discount,
        "product_referral_code": productReferralCode,
        "coupon_code": couponCode,
        "coupon_applied": couponApplied,
        "quantity": quantity,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Delivery {
  int id;
  int stateId;
  int cityId;
  int deliveryId;
  int price;
  int status;
  DateTime createdAt;
  DateTime updatedAt;

  Delivery({
    required this.id,
    required this.stateId,
    required this.cityId,
    required this.deliveryId,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
        id: json["id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        deliveryId: json["delivery_id"],
        price: json["price"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "state_id": stateId,
        "city_id": cityId,
        "delivery_id": deliveryId,
        "price": price,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class ShippingInfo {
  int id;
  int userId;
  String address;
  int countryId;
  int stateId;
  int cityId;
  dynamic deliveryId;
  dynamic longitude;
  dynamic latitude;
  String postalCode;
  String phone;
  int setDefault;
  DateTime createdAt;
  DateTime updatedAt;

  ShippingInfo({
    required this.id,
    required this.userId,
    required this.address,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.deliveryId,
    required this.longitude,
    required this.latitude,
    required this.postalCode,
    required this.phone,
    required this.setDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) => ShippingInfo(
        id: json["id"],
        userId: json["user_id"],
        address: json["address"],
        countryId: json["country_id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        deliveryId: json["delivery_id"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        postalCode: json["postal_code"],
        phone: json["phone"],
        setDefault: json["set_default"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "address": address,
        "country_id": countryId,
        "state_id": stateId,
        "city_id": cityId,
        "delivery_id": deliveryId,
        "longitude": longitude,
        "latitude": latitude,
        "postal_code": postalCode,
        "phone": phone,
        "set_default": setDefault,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class User {
  int id;
  dynamic referredBy;
  String provider;
  String providerId;
  dynamic refreshToken;
  String accessToken;
  String userType;
  String name;
  String gender;
  String email;
  DateTime emailVerifiedAt;
  dynamic verificationCode;
  dynamic newEmailVerificiationCode;
  dynamic deviceToken;
  dynamic avatar;
  dynamic avatarOriginal;
  dynamic address;
  dynamic country;
  dynamic state;
  dynamic city;
  dynamic postalCode;
  dynamic phone;
  int balance;
  int accumulatedPoints;
  int banned;
  int totalPoints;
  dynamic referralCode;
  dynamic customerPackageId;
  int remainingUploads;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.referredBy,
    required this.provider,
    required this.providerId,
    required this.refreshToken,
    required this.accessToken,
    required this.userType,
    required this.name,
    required this.gender,
    required this.email,
    required this.emailVerifiedAt,
    required this.verificationCode,
    required this.newEmailVerificiationCode,
    required this.deviceToken,
    required this.avatar,
    required this.avatarOriginal,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.phone,
    required this.balance,
    required this.accumulatedPoints,
    required this.banned,
    required this.totalPoints,
    required this.referralCode,
    required this.customerPackageId,
    required this.remainingUploads,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        referredBy: json["referred_by"],
        provider: json["provider"],
        providerId: json["provider_id"],
        refreshToken: json["refresh_token"],
        accessToken: json["access_token"],
        userType: json["user_type"],
        name: json["name"],
        gender: json["gender"],
        email: json["email"],
        emailVerifiedAt: DateTime.parse(json["email_verified_at"]),
        verificationCode: json["verification_code"],
        newEmailVerificiationCode: json["new_email_verificiation_code"],
        deviceToken: json["device_token"],
        avatar: json["avatar"],
        avatarOriginal: json["avatar_original"],
        address: json["address"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        postalCode: json["postal_code"],
        phone: json["phone"],
        balance: json["balance"],
        accumulatedPoints: json["accumulated_points"],
        banned: json["banned"],
        totalPoints: json["total_points"],
        referralCode: json["referral_code"],
        customerPackageId: json["customer_package_id"],
        remainingUploads: json["remaining_uploads"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referred_by": referredBy,
        "provider": provider,
        "provider_id": providerId,
        "refresh_token": refreshToken,
        "access_token": accessToken,
        "user_type": userType,
        "name": name,
        "gender": gender,
        "email": email,
        "email_verified_at": emailVerifiedAt.toIso8601String(),
        "verification_code": verificationCode,
        "new_email_verificiation_code": newEmailVerificiationCode,
        "device_token": deviceToken,
        "avatar": avatar,
        "avatar_original": avatarOriginal,
        "address": address,
        "country": country,
        "state": state,
        "city": city,
        "postal_code": postalCode,
        "phone": phone,
        "balance": balance,
        "accumulated_points": accumulatedPoints,
        "banned": banned,
        "total_points": totalPoints,
        "referral_code": referralCode,
        "customer_package_id": customerPackageId,
        "remaining_uploads": remainingUploads,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
