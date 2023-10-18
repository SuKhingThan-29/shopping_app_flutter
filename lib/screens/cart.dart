import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/text_styles.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/screens/select_address.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

class CartScreen extends StatefulWidget {
  CartScreen(
      {Key? key,
      this.has_bottomnav,
      this.from_navigation = false,
      this.counter})
      : super(key: key);
  final bool? has_bottomnav;
  final bool from_navigation;
  final CartCounter? counter;

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  var _shopList = [];
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = ". . .";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*print("user data");
    print(is_logged_in.$);
    print(access_token.value);
    print(user_id.$);
    print(user_name.$);*/

    if (is_logged_in.$ == true) {
      fetchData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  getCartCount() {
    Provider.of<CartCounter>(context, listen: false).getCount();
    // var res = await CartRepository().getCartCount();
    // widget.counter.controller.sink.add(res.count);
  }

  fetchData() async {
    getCartCount();
    var cartResponseList =
        await CartRepository().getCartResponseList(user_id.$);

    if (cartResponseList != null && cartResponseList.length > 0) {
      _shopList = cartResponseList;
    }
    _isInitial = false;
    getSetCartTotal();
    setState(() {});
  }

  getSetCartTotal() async {
    _cartTotal = 0.00;
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cartItem) {
            // print(cartItem.total_price);
            // print(cartItem.quantity);
            // print(cartItem.price);
            print("Card id: ${cartItem.total_price}");
            print(cartItem);
            //_cartTotal += cartItem.total_price;
            _cartTotal += cartItem.quantity * cartItem.price;
            _cartTotalString =
                '${SystemConfig.systemCurrency!.symbol} ${intl.NumberFormat.decimalPattern().format(_cartTotal)}';
            print(_cartTotal);
            print(_cartTotalString);
            setState(() {});
          });
        }
      });
    }
    // var variantResponse = await ProductRepository().getVariantWiseInfo(
    //     id: widget.id,
    //     color: "",
    //     variants: "",
    //     qty: _quantity);
    // _price=variantResponse.variantData!.price;
    // print("single price ${variantResponse.variantData!.price}");
  }

  partialTotalString(index) {
    var partialTotal = 0.00;
    var partialTotalString = "";
    if (_shopList[index].cart_items.length > 0) {
      _shopList[index].cart_items.forEach((cartItem) {
        //partialTotal += cartItem.total_price;
        partialTotal += cartItem.quantity * cartItem.price;
        partialTotalString =
            '${intl.NumberFormat.decimalPattern().format(partialTotal)} MMK';
      });
    }

    return partialTotalString;
  }

  onQuantityIncrease(sellerIndex, itemIndex) async {
    if (_shopList[sellerIndex].cart_items[itemIndex].quantity <
        _shopList[sellerIndex].cart_items[itemIndex].upper_limit) {
      _shopList[sellerIndex].cart_items[itemIndex].quantity++;
      // _shopList[sellerIndex].cart_items[itemIndex].total_price =
      //     _shopList[sellerIndex].cart_items[itemIndex].quantity *
      //         _shopList[sellerIndex].cart_items[itemIndex].price;
      // print(_shopList[sellerIndex].cart_items[itemIndex].quantity);
      // getSetCartTotal();
      await process(mode: "");
      getSetCartTotal();
      setState(() {});
    } else {
      ToastComponent.showSnackBar(
        context,
        "${AppLocalizations.of(context)!.cannot_order_more_than} ${_shopList[sellerIndex].cart_items[itemIndex].upper_limit} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
      );
    }
  }

  onQuantityDecrease(sellerIndex, itemIndex) async {
    if (_shopList[sellerIndex].cart_items[itemIndex].quantity >
        _shopList[sellerIndex].cart_items[itemIndex].lower_limit) {
      _shopList[sellerIndex].cart_items[itemIndex].quantity--;
      // getSetCartTotal();
      await process(mode: "");
      getSetCartTotal();
      setState(() {});
    } else {
      ToastComponent.showSnackBar(
        context,
        "${AppLocalizations.of(context)!.cannot_order_more_than} ${_shopList[sellerIndex].cart_items[itemIndex].lower_limit} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
      );
    }
  }

  onPressDelete(cartId) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!
                      .are_you_sure_to_remove_this_item,
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                Btn.basic(
                  child: Text(
                    AppLocalizations.of(context)!.cancel_ucf,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                Btn.basic(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    AppLocalizations.of(context)!.confirm_ucf,
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(cartId);
                  },
                ),
              ],
            ));
  }

  confirmDelete(cartId) async {
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cartId);

    if (cartDeleteResponse.result == true) {
      reset();
      fetchData();
    } else {
      ToastComponent.showSnackBar(
        context,
        cartDeleteResponse.message,
      );
    }
  }

  onPressUpdate() {
    process(mode: "update");
  }

  onPressProceedToShipping() {
    process(mode: "proceed_to_shipping");
  }

  process({mode}) async {
    var cartIds = [];
    var cartQuantities = [];
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cartItem) {
            cartIds.add(cartItem.id);
            cartQuantities.add(cartItem.quantity);
          });
        }
      });
    }

    if (cartIds.length == 0) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.cart_is_empty,
      );
      return;
    }

    var cartIdsString = cartIds.join(',').toString();
    var cartQuantitiesString = cartQuantities.join(',').toString();

    print(cartIdsString);
    print(cartQuantitiesString);

    var cartProcessResponse = await CartRepository()
        .getCartProcessResponse(cartIdsString, cartQuantitiesString);

    if (cartProcessResponse.result == false) {
      // ToastComponent.showSnackBar(cartProcessResponse.message,
      //     gravity: Toast.center, duration: Toast.lengthLong);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cartProcessResponse.message}')),
      );
    } else {
      // ToastComponent.showSnackBar(cartProcessResponse.message,
      //     gravity: Toast.center, duration: Toast.lengthLong);

      if (mode == "update") {
        reset();
        fetchData();
      } else if (mode == "proceed_to_shipping") {
        AIZRoute.push(context, SelectAddress()).then((value) {
          onPopped(value);
        });
      }
    }
  }

  reset() {
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = ". . .";

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  onPopped(value) async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          key: _scaffoldKey,
          //drawer: MainDrawer(),
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildCartSellerList(),
                        ),
                        Container(
                          height: widget.has_bottomnav! ? 140 : 100,
                        )
                      ]),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildBottomContainer(),
              )
            ],
          )),
    );
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        /*border: Border(
                  top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                )*/
      ),

      height: widget.has_bottomnav! ? 200 : 120,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: MyTheme.soft_accent_color),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      AppLocalizations.of(context)!.total_amount_ucf,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("$_cartTotalString",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48) * (1 / 3),
                    height: 58,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        // border:
                        //     Border.all(color: MyTheme.accent_color, width: 1),
                        borderRadius: app_language_rtl.$!
                            ? const BorderRadius.only(
                                topLeft: const Radius.circular(0.0),
                                bottomLeft: const Radius.circular(0.0),
                                topRight: const Radius.circular(6.0),
                                bottomRight: const Radius.circular(6.0),
                              )
                            : const BorderRadius.only(
                                topLeft: const Radius.circular(6.0),
                                bottomLeft: const Radius.circular(6.0),
                                topRight: const Radius.circular(0.0),
                                bottomRight: const Radius.circular(0.0),
                              )),
                    child: Btn.basic(
                      minWidth: MediaQuery.of(context).size.width,
                      color: MyTheme.soft_accent_color,
                      shape: app_language_rtl.$!
                          ? RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(0.0),
                              bottomLeft: const Radius.circular(0.0),
                              topRight: const Radius.circular(6.0),
                              bottomRight: const Radius.circular(6.0),
                            ))
                          : RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(6.0),
                              bottomLeft: const Radius.circular(6.0),
                              topRight: const Radius.circular(0.0),
                              bottomRight: const Radius.circular(0.0),
                            )),
                      child: Text(
                        AppLocalizations.of(context)!.update_cart_ucf,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        onPressUpdate();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 58,
                    width: (MediaQuery.of(context).size.width - 48) * (2 / 3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: MyTheme.accent_color, width: 1),
                        borderRadius: app_language_rtl.$!
                            ? const BorderRadius.only(
                                topLeft: const Radius.circular(6.0),
                                bottomLeft: const Radius.circular(6.0),
                                topRight: const Radius.circular(0.0),
                                bottomRight: const Radius.circular(0.0),
                              )
                            : const BorderRadius.only(
                                topLeft: const Radius.circular(0.0),
                                bottomLeft: const Radius.circular(0.0),
                                topRight: const Radius.circular(6.0),
                                bottomRight: const Radius.circular(6.0),
                              )),
                    child: Btn.basic(
                      minWidth: MediaQuery.of(context).size.width,
                      color: MyTheme.accent_color,
                      shape: app_language_rtl.$!
                          ? RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(6.0),
                              bottomLeft: const Radius.circular(6.0),
                              topRight: const Radius.circular(0.0),
                              bottomRight: const Radius.circular(0.0),
                            ))
                          : RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(0.0),
                              bottomLeft: const Radius.circular(0.0),
                              topRight: const Radius.circular(6.0),
                              bottomRight: const Radius.circular(6.0),
                            )),
                      child: Text(
                        AppLocalizations.of(context)!.proceed_to_shipping_ucf,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        onPressProceedToShipping();
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => widget.from_navigation
            ? UsefulElements.backToMain(context, go_back: false)
            : UsefulElements.backButton(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.shopping_cart_ucf,
        style: TextStyles.buildAppBarTexStyle(),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildCartSellerList() {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.please_log_in_to_see_the_cart_items,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shopList.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 26,
          ),
          itemCount: _shopList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Text(
                        _shopList[index].name,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        partialTotalString(index),
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                buildCartSellerItemList(index),
              ],
            );
          },
        ),
      );
    } else if (!_isInitial && _shopList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.cart_is_empty,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  SingleChildScrollView buildCartSellerItemList(sellerIndex) {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 14,
        ),
        itemCount: _shopList[sellerIndex].cart_items.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard(sellerIndex, index);
        },
      ),
    );
  }

  buildCartSellerItemCard(sellerIndex, itemIndex) {
    return Container(
      height: 120,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                width: DeviceInfo(context).width! / 4,
                height: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(6), right: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: _shopList[sellerIndex]
                          .cart_items[itemIndex]
                          .product_thumbnail_image,
                      fit: BoxFit.cover,
                    ))),
            Container(
              //color: Colors.red,
              width: DeviceInfo(context).width! / 2.5,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _shopList[sellerIndex].cart_items[itemIndex].product_name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 23.0),
                      child: Row(
                        children: [
                          Text(
                            '${intl.NumberFormat.decimalPattern().format((_shopList[sellerIndex].cart_items[itemIndex].price! * _shopList[sellerIndex].cart_items[itemIndex].quantity!)!)} MMK',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Container(
              width: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      onPressDelete(
                          _shopList[sellerIndex].cart_items[itemIndex].id);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Image.asset(
                          'assets/trash.png',
                          height: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      onQuantityIncrease(sellerIndex, itemIndex);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.add,
                        color: MyTheme.accent_color,
                        size: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      _shopList[sellerIndex]
                          .cart_items[itemIndex]
                          .quantity
                          .toString(),
                      style:
                          TextStyle(color: MyTheme.accent_color, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onQuantityDecrease(sellerIndex, itemIndex);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.remove,
                        color: MyTheme.accent_color,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
