import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/helpers/response_check.dart';

import 'package:active_ecommerce_flutter/data_model/wallet_balance_response.dart';
import 'package:active_ecommerce_flutter/data_model/wallet_recharge_response.dart';
import 'package:active_ecommerce_flutter/helpers/response_check.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';

class WalletRepository {
  Future<dynamic> getBalance() async {
    String url=("${AppConfig.BASE_URL}/wallet/balance");
    print(url.toString());
    print("Bearer ${access_token.$}");
    final response = await ApiRequest.get(
      url:url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
      middleware: BannedUser()
    );
    return walletBalanceResponseFromJson(response.body);
  }

  Future<dynamic> getRechargeList({int page = 1}) async {
    String url=(
        "${AppConfig.BASE_URL}/wallet/history?page=${page}");

    final response = await ApiRequest.get(
      url:url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
      middleware: BannedUser()
    );

      return walletRechargeResponseFromJson(response.body);
  }
}
