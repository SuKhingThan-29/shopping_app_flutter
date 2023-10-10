import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/user_info_response.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';

import 'package:active_ecommerce_flutter/repositories/order_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:one_context/one_context.dart';

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

class Coupon extends StatefulWidget {
  Coupon({Key? key, this.from_checkout = false}) : super(key: key);
  final bool from_checkout;

  @override
  _CouponState createState() => _CouponState();
}

class _CouponState extends State<Coupon> {
  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();

  //------------------------------------
  List<dynamic> _orderList = [];
  bool _isInitial = true;
  int? _totalData = 0;
  bool _showLoadingContainer = false;
  UserInformation? _userInfo;
  int? _member_level;

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
    setState(() {});
    fetchData();
  }

  getUserInfo() async {
    var userInfoRes = await ProfileRepository().getUserInfoResponse();
    if (userInfoRes.data.isNotEmpty) {
      _userInfo = userInfoRes.data.first;
      _member_level = _userInfo!.total_points;
      print("member level: $_member_level");
    }

    setState(() {});
  }

  fetchData() async {
    getUserInfo();
    var orderResponse = await OrderRepository().getMyCoupon();
    _orderList.addAll(orderResponse.data);
    _isInitial = false;
    _totalData = orderResponse.meta.total;
    _showLoadingContainer = false;
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
                  // Padding(
                  //   padding: const EdgeInsets.all(15),
                  //   child: Container(
                  //     alignment: Alignment.topCenter,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(20.0),
                  //       color: Colors.transparent,
                  //       image: DecorationImage(
                  //         image: AssetImage('assets/pointbg.jpg'),
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //     padding: EdgeInsets.all(20),
                  //     height: 150,
                  //     // child: Column(
                  //     //   mainAxisAlignment: MainAxisAlignment.center,
                  //     //   children: [
                  //     //     Text(
                  //     //       'Point Balance',
                  //     //       style: TextStyle(
                  //     //         fontSize: 25,
                  //     //         color: Color.fromARGB(255, 255, 255, 255),
                  //     //         fontWeight: FontWeight.bold,
                  //     //       ),
                  //     //     ),
                  //     //     SizedBox(
                  //     //       height: 15,
                  //     //     ),
                  //     //     Row(
                  //     //       mainAxisAlignment:
                  //     //           MainAxisAlignment.center, // Center the Row
                  //     //       children: [
                  //     //         Image.asset(
                  //     //           "assets/point.png",
                  //     //           width: 30,
                  //     //           height: 30,
                  //     //         ),
                  //     //         SizedBox(width: 5),
                  //     //         Text(
                  //     //           '$_member_level Point',
                  //     //           style: TextStyle(
                  //     //             fontSize: 25,
                  //     //             color: Color.fromARGB(255, 253, 252, 252),
                  //     //             fontWeight: FontWeight.bold,
                  //     //           ),
                  //     //         ),
                  //     //       ],
                  //     //     ),
                  //     //   ],
                  //     // ),
                  //   ),
                  // ),
                  Container(
                      margin: EdgeInsets.only(bottom: 10, top: 200),
                      child: buildOrderListList()),
                  SizedBox(
                    height: 10,
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
        child: Text(_totalData == _orderList.length
            ? AppLocalizations.of(context)!.no_more_orders_ucf
            : AppLocalizations.of(context)!.loading_more_orders_ucf),
      ),
    );
  }

  buildBottomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [],
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(104.0),
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
        children: [
          Builder(
            builder: (context) => IconButton(
              padding: EdgeInsets.zero,
              icon: UsefulElements.backIcon(context),
              onPressed: () {
                if (widget.from_checkout) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Main();
                  }));
                } else {
                  return Navigator.of(context).pop();
                }
              },
            ),
          ),
          Text(
            'My Coupon',
            style: TextStyle(
                fontSize: 16,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  buildOrderListList() {
    if (_isInitial && _orderList.length == 0) {
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
    } else if (_orderList.length > 0) {
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
            itemCount: _orderList.length,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.black, // Border color
          width: 2.0, // Border width
        ),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
                          '${_orderList[index].discount} MMK',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Valid: ${_orderList[index].startDate} to ${_orderList[index].endDate}',
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
                      'Point: ${_orderList[index].pointAmount} Point',
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
            // Column(
            //   children: [
            //     SizedBox(height: 55),
            //     InkWell(
            //         onTap: () async {
            //           var response = await OrderRepository()
            //               .buyCoupon(_orderList[index].id);
            //           print(response);
            //           ToastComponent.showDialog(response.message);
            //           if (response.message == true) {
            //             _onRefresh();
            //             print(_orderList);
            //             Navigator.of(context, rootNavigator: true).pop();
            //           }
            //         },
            //         child: Container(
            //           margin: EdgeInsets.only(top: 10),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(
            //                 20.0), // Adjust the radius as needed
            //             border: Border.all(
            //               color: Colors.black, // Set the border color to black
            //             ),
            //           ),
            //           child: Padding(
            //             padding: const EdgeInsets.only(
            //                 left: 15, right: 15, top: 3, bottom: 3),
            //             child: const Text(
            //               'Buy',
            //               style: TextStyle(
            //                 fontSize: 17,
            //                 fontWeight: FontWeight.normal,
            //                 color: Colors.black,
            //               ),
            //             ),
            //           ),
            //         )),
            //   ],
            // )
          ],
        ),
      ),
    );
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
