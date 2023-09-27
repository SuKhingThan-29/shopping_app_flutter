import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:active_ecommerce_flutter/data_model/confirm_code_response.dart';
import 'package:active_ecommerce_flutter/data_model/login_response.dart';
import 'package:active_ecommerce_flutter/data_model/logout_response.dart';
import 'package:active_ecommerce_flutter/data_model/password_confirm_response.dart';
import 'package:active_ecommerce_flutter/data_model/password_forget_response.dart';
import 'package:active_ecommerce_flutter/data_model/resend_code_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class AuthRepository {
  Future<LoginResponse> getLoginResponse(String? email, String password) async {
    var postBody = jsonEncode({
      "email": "$email",
      "password": "$password",
      "identity_matrix": AppConfig.purchase_code
    });

    String url = ("${AppConfig.BASE_URL}/auth/login");
    print("Login url: $url");
    print("Login request: ${postBody}");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getSocialLoginResponse(
    String socialProvider,
    String? name,
    String? email,
    String? provider, {
    access_token = "",
    secret_token = "",
  }) async {
    email = email == ("null") ? "" : email;

    var postBody = jsonEncode({
      "name": name,
      "email": email,
      "provider": "$provider",
      "social_provider": "$socialProvider",
      "access_token": "$access_token",
      "secret_token": "$secret_token"
    });

    print(postBody);
    String url = ("${AppConfig.BASE_URL}/auth/social-login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);
    print(postBody);
    print(response.body.toString());
    return loginResponseFromJson(response.body);
  }

  Future<LogoutResponse> getLogoutResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/logout");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    print(response.body);

    return logoutResponseFromJson(response.body);
  }

  Future<CommonResponse> getAccountDeleteResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/account-deletion");

    print(url.toString());

    print("Bearer ${access_token.$}");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    print(response.body);
    return commonResponseFromJson(response.body);
  }

  Future<LoginResponse> getSignupResponse(
    String name,
    String? email,
    String? phone,
    String password,
    String passowrdConfirmation,
    String registerBy,
    String gender,
    int countryId,
    int stateId,
    int cityId,
    int postalCode,
    String capchaKey,
  ) async {
    var postBody = jsonEncode({
      "name": "$name",
      "email": "$email",
      "phone":"$phone",
      "password": "$password",
      "password_confirmation": "$passowrdConfirmation",
      "register_by": "$registerBy",
      "gender": gender,
      "country_id": countryId,
      "state_id": stateId,
      "city_id": cityId,
      "postal_code": postalCode,
      "country_code":"95"
      // "g-recaptcha-response": "$capchaKey",
    });

    String url = ("${AppConfig.BASE_URL}/auth/signup");
    print('Signup: $postBody');
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);
    print("Signup response: ${response.body}");

    return loginResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getResendCodeResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/resend_code");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
        "Authorization": "Bearer ${access_token.$}",
      },
    );
    return resendCodeResponseFromJson(response.body);
  }

  Future<ConfirmCodeResponse> getConfirmCodeResponse(
      String verificationCode) async {
    var postBody = jsonEncode(
        {"verification_code": "$verificationCode", "user_id": "${user_id.$}"});
    print('Bearer ${access_token.$}');
    print(user_id.$);

    String url = ("${AppConfig.BASE_URL}/auth/confirm_code");
    print(url);
    print(postBody);
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: postBody);
    print(response.body);
    return confirmCodeResponseFromJson(response.body);
  }

  Future<PasswordForgetResponse> getPasswordForgetResponse(
      String? emailOrPhone, String sendCodeBy) async {
    var postBody = jsonEncode(
        {"email_or_phone": "$emailOrPhone", "send_code_by": "$sendCodeBy"});

    String url = ("${AppConfig.BASE_URL}/auth/password/forget_request");

    print(url.toString());
    print(postBody.toString());

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return passwordForgetResponseFromJson(response.body);
  }

  Future<PasswordConfirmResponse> getPasswordConfirmResponse(
      String verificationCode, String password) async {
    var postBody = jsonEncode(
        {"verification_code": "$verificationCode", "password": "$password"});

    String url = ("${AppConfig.BASE_URL}/auth/password/confirm_reset");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return passwordConfirmResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getPasswordResendCodeResponse(
      String? emailOrCode, String verifyBy) async {
    var postBody =
        jsonEncode({"email_or_code": "$emailOrCode", "verify_by": "$verifyBy"});

    String url = ("${AppConfig.BASE_URL}/auth/password/resend_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return resendCodeResponseFromJson(response.body);
  }

  Future<LoginResponse> getUserByTokenResponse() async {
    var postBody = jsonEncode({"access_token": "${access_token.$}"});

    String url = ("${AppConfig.BASE_URL}/auth/info");
    if (access_token.$!.isNotEmpty) {
      final response = await ApiRequest.post(
          url: url,
          headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
          },
          body: postBody);

      return loginResponseFromJson(response.body);
    }
    return LoginResponse();
  }
}
