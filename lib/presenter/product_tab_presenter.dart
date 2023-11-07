import 'package:active_ecommerce_flutter/repositories/product_tab_repository.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../custom/toast_component.dart';

class ProductTabProvider extends ChangeNotifier{

  var allProductList = [];
  bool isAllProductInitial = true;
  ScrollController mainScrollController = ScrollController();
  int allProductPage = 1;

  getProductTab(String? name)async{
    allProductList.clear();
    var res = await ProductTabRepository().getProductTabResponseList(name);
    allProductList.addAll(res.product);
    isAllProductInitial = false;
    notifyListeners();
  }
  mainScrollListener(String? name) {
    mainScrollController.addListener(() {
      //print("position: " + xcrollController.position.pixels.toString());
      //print("max: " + xcrollController.position.maxScrollExtent.toString());

      if (mainScrollController.position.pixels ==
          mainScrollController.position.maxScrollExtent) {
        allProductPage++;
        ToastComponent.showDialog("More Products Loading...",
            gravity: Toast.center);
        getProductTab(name);
      }
    });
  }
}