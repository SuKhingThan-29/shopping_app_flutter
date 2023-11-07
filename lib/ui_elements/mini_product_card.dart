import 'package:active_ecommerce_flutter/custom/aiz_image.dart';
import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:active_ecommerce_flutter/screens/select_address.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;

import '../helpers/shared_value_helper.dart';

class MiniProductCard extends StatefulWidget {
  int? id;
  String? image;
  String? name;
  String? main_price;
  String? stroked_price;
  bool? has_discount;
  bool? is_wholesale;
  var discount;
  MiniProductCard({
    Key? key,
    this.id,
    this.image,
    this.name,
    this.main_price,
    this.stroked_price,
    this.has_discount,
    this.is_wholesale = false,
    this.discount,
  }) : super(key: key);

  @override
  _MiniProductCardState createState() => _MiniProductCardState();
}

class _MiniProductCardState extends State<MiniProductCard> {
  var _shopList = [];
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = ". . .";

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

  reset() {
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = ". . .";

    setState(() {});
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
      ToastComponent.showSnackBar(context,AppLocalizations.of(context)!.cart_is_empty);
      return;
    }

    var cartIdsString = cartIds.join(',').toString();
    var cartQuantitiesString = cartQuantities.join(',').toString();

    print(cartIdsString);
    print(cartQuantitiesString);

    var cartProcessResponse = await CartRepository()
        .getCartProcessResponse(cartIdsString, cartQuantitiesString);

    if (cartProcessResponse.result == false) {
      ToastComponent.showSnackBar(context,cartProcessResponse.message,
          );
    } else {
      ToastComponent.showSnackBar(context,cartProcessResponse.message,
          );

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

  onPopped(value) async {
    reset();
    fetchData();
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
      ToastComponent.showSnackBar(context,
          "${AppLocalizations.of(context)!.cannot_order_more_than} ${_shopList[sellerIndex].cart_items[itemIndex].upper_limit} ${AppLocalizations.of(context)!.items_of_this_all_lower}",
         );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(
            id: widget.id,
          );
        }));
      },
      child: Container(
        width: 135,
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child: Stack(children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 5 / 4,
                  child: Container(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6), bottom: Radius.zero),
                        // child: FadeInImage.assetNetwork(
                        //   placeholder: 'assets/placeholder.png',
                        //   image: widget.image!,
                        //   fit: BoxFit.cover,
                        // )
                        // child: CachedNetworkImage(
                        //   imageUrl: widget.image!,
                        //   fit: BoxFit.cover,
                        //   placeholder: (context, url) => Center(
                        //   child: CircularProgressIndicator(),),
                        //   errorWidget: (context, url, error) => Icon(Icons.error),
                        // ),
                        child: AIZImage.basicImage(widget.image!),
                      )),
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                  child: Text(
                    widget.name!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                // widget.has_discount!
                widget.main_price != widget.stroked_price
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          SystemConfig.systemCurrency != null
                              ? widget.stroked_price!.replaceAll(
                                  SystemConfig.systemCurrency!.code!,
                                  SystemConfig.systemCurrency!.symbol!)
                              : widget.stroked_price!,
                          maxLines: 1,
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: MyTheme.medium_grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text(
                    SystemConfig.systemCurrency != null
                        ? widget.main_price!.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!)
                        : widget.main_price!,
                    maxLines: 1,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
          // discount and wholesale
          Positioned.fill(
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.has_discount!)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xffe62e04),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomLeft: Radius.circular(6.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x14000000),
                            offset: Offset(-1, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.discount ?? "",
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xffffffff),
                          fontWeight: FontWeight.w700,
                          height: 1.8,
                        ),
                        textHeightBehavior:
                            TextHeightBehavior(applyHeightToFirstAscent: false),
                        softWrap: false,
                      ),
                    ),
                  Visibility(
                    visible: whole_sale_addon_installed.$,
                    child: widget.is_wholesale!
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(6.0),
                                bottomLeft: Radius.circular(6.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x14000000),
                                  offset: Offset(-1, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              "Wholesale",
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                                height: 1.8,
                              ),
                              textHeightBehavior: TextHeightBehavior(
                                  applyHeightToFirstAscent: false),
                              softWrap: false,
                            ),
                          )
                        : SizedBox.shrink(),
                  )
                ],
              ),
            ),
          ),

          // whole sale
        ]),
      ),
    );
  }
}
