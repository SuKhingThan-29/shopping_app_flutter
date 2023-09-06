import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/carriers_response.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/data_model/delivefytype_response.dart';
import 'package:active_ecommerce_flutter/data_model/delivery_info_response.dart';
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

  Future<Deliverytype> getCarrierList() async {
    String url =
        ("https://gmpwyh-l.ethical-digit.com/api/v2/getdeliverytype/107");
    print(url.toString());
    final response = await ApiRequest.get(
      url: url,
    );
    print('GetDeliveryType: ${deliverytypeFromJson(response.body)}');
    return deliverytypeFromJson(response.body);
  }
}
