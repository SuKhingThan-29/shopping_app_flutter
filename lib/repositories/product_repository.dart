import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/classified_ads_details_response.dart';
import 'package:active_ecommerce_flutter/data_model/classified_ads_response.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_details_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart';
import 'package:active_ecommerce_flutter/data_model/variant_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

import '../data_model/variant_price_response.dart';

class ProductRepository {
  Future<ProductMiniResponse> getFeaturedProducts({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/featured?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      // "Currency-Code": SystemConfig.systemCurrency!.code!,
      // "Currency-Exchange-Rate": SystemConfig.systemCurrency!.exchangeRate!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBestSellingProducts() async {
    String url = ("${AppConfig.BASE_URL}/products/best-seller");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTodaysDealProducts() async {
    String url = ("${AppConfig.BASE_URL}/products/todays-deal");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      // "Currency-Code": SystemConfig.systemCurrency!.code!,
      // "Currency-Exchange-Rate":
      //     SystemConfig.systemCurrency!.exchangeRate.toString(),
    });

    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFlashDealProducts({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/flash-deal-products/" + id.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getCategoryProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/category/" +
        id.toString() +
        "?page=$page&name=$name");
    print("CategoryProduct url: $url");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getShopProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/seller/" +
        id.toString() +
        "?page=$page&name=$name");

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBrandProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/brand/" +
        id.toString() +
        "?page=$page&name=$name");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(url.toString());
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBrancedProducts({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/branched" + "?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(url.toString());
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getRecommendProducts({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/recommend/" + "?page=$page");
    final response = await ApiRequest.get(url: url);
    print(url.toString());
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getNewProducts({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/newest/" + "?page=$page");
    final response = await ApiRequest.get(url: url);
    print(url.toString());
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getProductsTab(
      {name = "",
      sort_key = "",
      page = 1,
      brands = "",
      categories = "",
      min = "",
      max = ""}) async {
    String url = ("${AppConfig.BASE_URL}/products/search" +
        "?page=$page&name=$name&sort_key=$sort_key&brands=$brands&categories=$categories&min=$min&max=$max");

    print('Home page: ${url.toString()}');
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFilteredProducts(
      {name = "",
      sort_key = "",
      page = 1,
      brands = "",
      categories = "",
      min = "",
      max = ""}) async {
    print(categories);
    String url = ("${AppConfig.BASE_URL}/products/search" +
        "?page=$page&name=$name&sort_key=$sort_key&brands=$brands&categories=$categories&min=$min&max=$max");

    print('Home page search: ${url.toString()}');
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      // "Currency-Code": SystemConfig.systemCurrency!.code!,
      // "Currency-Exchange-Rate":
      //     SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFilteredFlashDealProducts(
      {name = "",
      sort_key = "",
      page = "",
      brands = "",
      categories = "",
      min = "",
      max = ""}) async {
    print(page);
    String url = ("${AppConfig.BASE_URL}/flash-deal-products/$page" +
        "?sort_key=$sort_key");

    print('Home page search: ${url.toString()}');
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      // "Currency-Code": SystemConfig.systemCurrency!.code!,
      // "Currency-Exchange-Rate":
      //     SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getProductTabNewest(
      {name = "newest", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/newest" + "?page=${1}");

    print('Home page newest: ${url.toString()}');
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      //  "Currency-Code": SystemConfig.systemCurrency!.code!,
      //  "Currency-Exchange-Rate":
      // SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getDigitalProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/products/digital?page=$page");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return productMiniResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getClassifiedProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/all?page=$page");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getOwnClassifiedProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/own-products?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getClassifiedOtherAds({
    id = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/classified/related-products/$id");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsDetailsResponse> getClassifiedProductsDetails(id) async {
    String url = ("${AppConfig.BASE_URL}/classified/product-details/$id");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    print(response.body);
    return classifiedAdsDetailsResponseFromJson(response.body);
  }

  Future<CommonResponse> getDeleteClassifiedProductResponse(id) async {
    String url = ("${AppConfig.BASE_URL}/classified/delete/$id");
    print(url.toString());

    final response = await ApiRequest.delete(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> getStatusChangeClassifiedProductResponse(
      id, status) async {
    String url = ("${AppConfig.BASE_URL}/classified/change-status/$id");

    var postBody = jsonEncode({"status": status});
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }

  Future<ProductDetailsResponse> getProductDetails({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/" + id.toString());
    print("Product detail: ${url.toString()}");
    final response = await ApiRequest.get(url: url);

    return productDetailsResponseFromJson(response.body);
  }

  Future<ProductDetailsResponse> getDigitalProductDetails({int id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/" + id.toString());
    print(url.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });

    //print(response.body.toString());
    return productDetailsResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getRelatedProducts({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/related/" + id.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTopFromThisSellerProducts(
      {int? id = 0}) async {
    String url =
        ("${AppConfig.BASE_URL}/products/top-from-seller/" + id.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });

    print("top selling product url ${url.toString()}");
    print("top selling product ${response.body.toString()}");

    return productMiniResponseFromJson(response.body);
  }

  Future<VariantResponse> getVariantWiseInfo(
      {int? id = 0, color = '', variants = '', qty = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/variant/price");

    var postBody = jsonEncode({
      'id': id.toString(),
      "color": color,
      "variants": variants,
      "quantity": qty
    });
    print('Product variant: $postBody');

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
          // "Currency-Code": SystemConfig.systemCurrency!.code!,
          // "Currency-Exchange-Rate":
          //     SystemConfig.systemCurrency!.exchangeRate.toString(),
        },
        body: postBody);

    return variantResponseFromJson(response.body);
  }

  Future<VariantPriceResponse> getVariantPrice({id, quantity}) async {
    String url = ("${AppConfig.BASE_URL}/varient-price");

    var postBody = jsonEncode({"id": id, "quantity": quantity});
    print(url.toString());
    print(postBody.toString());
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
          "Currency-Code": SystemConfig.systemCurrency!.code!,
          "Currency-Exchange-Rate":
              SystemConfig.systemCurrency!.exchangeRate.toString(),
        },
        body: postBody);

    return variantPriceResponseFromJson(response.body);
  }
}
