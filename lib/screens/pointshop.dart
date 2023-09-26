import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/data_model/coupon.dart';

import 'package:active_ecommerce_flutter/repositories/order_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:one_context/one_context.dart';
import 'package:validators/validators.dart';

class PaymentStatus {
  String option_key;
  String name;

  PaymentStatus(this.option_key, this.name);
}

class DeliveryStatus {
  String option_key;
  String name;

  DeliveryStatus(this.option_key, this.name);
}

class PointShop extends StatefulWidget {
  PointShop({Key? key, this.from_checkout = false}) : super(key: key);
  final bool from_checkout;

  @override
  _PointShopState createState() => _PointShopState();
}

class _PointShopState extends State<PointShop> {
  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();

  //------------------------------------
  List<dynamic> _orderList = [];
  bool _isInitial = true;
  int? _totalData = 0;
  bool _showLoadingContainer = false;
  List<dynamic> _orderResponseList = [];

  @override
  void initState() {
    // init();
    super.initState();

    fetchData();

    // _xcrollController.addListener(() {
    //   print("position: " + _xcrollController.position.pixels.toString());
    //   print("max: " + _xcrollController.position.maxScrollExtent.toString());

    //   if (_xcrollController.position.pixels ==
    //       _xcrollController.position.maxScrollExtent) {
    //     setState(() {});
    //     _showLoadingContainer = true;
    //     fetchData();
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  reset() {
    _orderList.clear();
    _isInitial = true;
    _totalData = 0;
    _showLoadingContainer = false;
  }

  resetFilterKeys() {
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    resetFilterKeys();
    fetchData();
  }

  fetchData() async {
    _orderResponseList.clear();
    var orderResponse = await OrderRepository().getCoupon();
    _orderResponseList.addAll(orderResponse.data);
    _isInitial = false;
    //  _totalData = orderResponse.meta.total;
    _showLoadingContainer = false;
    _orderList.clear();
    _orderList =
        _orderResponseList.where((item) => item.canBuy == true).toList();
    print("CouponData: ${_orderResponseList.length}");

    for (var i in _orderList) {
      print("CouponData response code: ${i.code}");
      print("CouponData response: ${i.canBuy}");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (widget.from_checkout) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return Main();
            }), (reute) => false);
            return Future<bool>.value(false);
          } else {
            return Future<bool>.value(true);
          }
        },
        child: Directionality(
          textDirection:
              app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: buildAppBar(context),
              body: Stack(
                children: [
                  Container(
                      margin: EdgeInsets.only(bottom: 100),
                      child: buildOrderListList()),
                  SizedBox(
                    height: 100,
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: buildLoadingContainer()),
                ],
              )),
        ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
            _totalData == _orderList.where((item) => item.canBuy == true).length
                ? AppLocalizations.of(context)!.no_more_orders_ucf
                : AppLocalizations.of(context)!.loading_more_orders_ucf),
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0),
      child: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            new Container(),
          ],
          elevation: 0.0,
          titleSpacing: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: MediaQuery.of(context).viewPadding.top >
                          30 //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                      ? const EdgeInsets.only(top: 36.0)
                      : const EdgeInsets.only(top: 14.0),
                  child: buildTopAppBarContainer(),
                ),
              ],
            ),
          )),
    );
  }

  Container buildTopAppBarContainer() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.coupon_ucf,
            style: TextStyle(
                fontSize: 20,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  buildOrderListList() {
    if (_isInitial &&
        _orderList.where((item) => item.canBuy == true).length == 0) {
      return SingleChildScrollView(
          child: ListView.builder(
        controller: _scrollController,
        itemCount: 10,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            child: Shimmer.fromColors(
              baseColor: MyTheme.shimmer_base,
              highlightColor: MyTheme.shimmer_highlighted,
              child: Container(
                height: 75,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          );
        },
      ));
    } else if (_orderList.where((item) => item.canBuy == true).length > 0) {
      return RefreshIndicator(
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        displacement: 0,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          controller: _xcrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              height: 14,
            ),
            padding:
                const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 0),
            itemCount: _orderList.where((item) => item.canBuy == true).length,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return OrderDetails(
                  //     id: _orderList[index].id,
                  //   );
                  // }));
                },
                child: buildOrderListItemCard(index),
              );
            },
          ),
        ),
      );
    } else if (_totalData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_data_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  buildOrderListItemCard(int index) {
    if (_orderList.any((item) => item.canBuy) == true) {
      return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 245, 239, 192),
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Image.asset(
                      "assets/per.png",
                      width: 50,
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_orderList.where((item) => item.canBuy == true).elementAt(index).discount} MMK',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Valid: ${_orderList.where((item) => item.canBuy == true).elementAt(index).startDate} to ${_orderList.where((item) => item.canBuy == true).elementAt(index).endDate}',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color.fromARGB(255, 40, 40, 40),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  // Container(
                  //   color: Colors.white,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(5.0),
                  //     child: Text(
                  //       _orderList
                  //           .where((item) => item.canBuy == true)
                  //           .elementAt(index)
                  //           .code,
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/point.png",
                        width: 20,
                        height: 20,
                      ),
                      Text(
                        'Point: ${_orderList.where((item) => item.canBuy == true).elementAt(index).pointAmount} Point',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 84, 83, 83),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 55),
                  InkWell(
                      onTap: () async {
                        var response = await OrderRepository().buyCoupon(
                            _orderList
                                .where((item) => item.canBuy == true)
                                .elementAt(index)
                                .id);
                        print(response);
                        ToastComponent.showDialog(response.message);
                        if (response.message == true) {
                          _onRefresh();
                          print(_orderList);
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the radius as needed
                          border: Border.all(
                            color:
                                Colors.black, // Set the border color to black
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 3, bottom: 3),
                          child: const Text(
                            'Buy',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  Container buildPaymentStatusCheckContainer(String payment_status) {
    return Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: payment_status == "paid" ? Colors.green : Colors.red),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(payment_status == "paid" ? Icons.check : Icons.check,
            color: Colors.white, size: 10),
      ),
    );
  }
}
