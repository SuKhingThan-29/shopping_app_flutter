import 'dart:convert';

import 'package:active_ecommerce_flutter/data_model/auction_product_bid_place_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../data_model/auction_product_details_response.dart';
import '../data_model/product_mini_response.dart';
import '../helpers/shared_value_helper.dart';

class AuctionProductsRepository {
  Future<ProductMiniResponse> getAuctionProducts({page = 1}) async {
    String url=("${AppConfig.BASE_URL}/auction/products?page=${page}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<AuctionProductDetailsResponse> getAuctionProductsDetails(
      { int? id = 0}) async {
    String url=("${AppConfig.BASE_URL}/auction/products/${id}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
    });
    return auctionProductDetailsResponseFromJson(response.body);
  }

  Future<AuctionProductPlaceBidResponse> placeBidResponse(
      String product_id, String amount) async {
    print(product_id);
    print(amount);

    var post_body = jsonEncode({
      "product_id": "${product_id}",
      "amount": "$amount",
    });

    String url=("${AppConfig.BASE_URL}/auction/place-bid");
    final response = await ApiRequest.post(url:url,
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}"
        },
        body: post_body);

    return auctionProductPlaceBidResponseFromJson(response.body);
  }
}
