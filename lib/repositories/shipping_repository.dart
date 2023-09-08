import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/carriers_response.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/data_model/delivefytype_response.dart';
import 'package:active_ecommerce_flutter/data_model/delivery_info_response.dart';
import 'package:active_ecommerce_flutter/data_model/delivery_response.dart';
import 'package:active_ecommerce_flutter/helpers/response_check.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

class ShippingRepository {
  Future<dynamic> getDeliveryInfo() async {
    String url = ("${AppConfig.BASE_URL}${AppConfig.deliver_info}");
    print(url.toString());
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    bool checkResult = ResponseCheck.apply(response.body);

    if (!checkResult) return responseCheckModelFromJson(response.body);

    print("Delivery Info: ${response.body}");
    return deliveryInfoResponseFromJson(response.body);
  }

  Future<Deliverytype> getCarrierList(int? selectedAddressId) async {
    String url = ("${AppConfig.BASE_URL}/getdeliverytype/$selectedAddressId");
    print(url.toString());
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
      },

    );
    print('GetDeliveryType: ${deliverytypeFromJson(response.body)}');
    return deliverytypeFromJson(response.body);
  }

  Future<dynamic> postDeliveryInfo(deliverid) async {
    var post_body = jsonEncode({"assigneddeliverytype_id": deliverid});
    print("PostDelivery: $deliverid");
    String url = ("${AppConfig.BASE_URL}/store_delivery_info");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
      },
      body: post_body,
    );

    return deliveryResponseFromJson(response.body);
  }
}
