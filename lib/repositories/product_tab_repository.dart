import '../app_config.dart';
import '../data_model/product_tab_response.dart';
import '../helpers/shared_value_helper.dart';
import '../helpers/system_config.dart';
import 'api-request.dart';

class ProductTabRepository{
  Future<dynamic> getProductTabResponseList(
      String? name,
      ) async {
    String url=("${AppConfig.BASE_URL}/$name");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
      SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productTabResponseFromJson(response.body);
  }
}
