import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:active_ecommerce_flutter/data_model/brand_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class BrandRepository {

  Future<BrandResponse> getFilterPageBrands() async {
    String url=("${AppConfig.BASE_URL}/filter/brands");
    final response =
    await ApiRequest.get(url: url,headers: {
      "App-Language": app_language.$!,
    });
    return brandResponseFromJson(response.body);
  }

  Future<BrandResponse> getBrands({name = "", page = ""}) async {
    String url=("${AppConfig.BASE_URL}/brands"+
        "?page=${page}&name=${name}");
print("brand: $url");
    final response =
    await ApiRequest.get(url: url);
    return brandResponseFromJson(response.body);
  }



}
