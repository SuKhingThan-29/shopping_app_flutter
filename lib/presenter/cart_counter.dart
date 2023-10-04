

import 'dart:async';

import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../helpers/shared_value_helper.dart';
import '../repositories/profile_repository.dart';

class CartCounter extends ChangeNotifier{

  int cartCounter=0;



  getCount()async{
    var res = await CartRepository().getCartCount();
    cartCounter = res.count;
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;

    String? fcmToken = await _fcm.getToken();
    print("--fcm token login-- ${is_logged_in.$}");

    if (fcmToken != null) {
      print("--fcm token-- $fcmToken");
      await ProfileRepository()
          .getDeviceTokenUpdateResponse(fcmToken);

    }
    notifyListeners();
  }

}