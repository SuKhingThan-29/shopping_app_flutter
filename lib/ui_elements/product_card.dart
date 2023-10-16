import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../custom/aiz_image.dart';
import '../custom/btn.dart';
import '../custom/text_styles.dart';
import '../data_model/delivery_response.dart';
import '../data_model/product_details_response.dart';
import '../helpers/color_helper.dart';
import '../helpers/shared_value_helper.dart';
import '../helpers/shimmer_helper.dart';
import '../presenter/cart_counter.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';
import '../screens/auction_products_details.dart';
import '../screens/login.dart';
import '../screens/profile.dart';

class ProductCard extends StatefulWidget {
  var identifier;
  int? id;
  String? image;
  String? name;
  String? main_price;
  String? stroked_price;
  bool? has_discount;
  bool? is_wholesale;
  var discount;

  ProductCard({
    Key? key,
    this.identifier,
    this.id,
    this.image,
    this.name,
    this.main_price,
    this.is_wholesale = false,
    this.stroked_price,
    this.has_discount,
    this.discount,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  DetailedProduct? _productDetails;
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
  var _productImageList = [];
  int _currentImage = 0;

  int? _quantity = 1;
  int? _stock = 0;
  var _colorList = [];
  int _selectedColorIndex = 0;
  var _choiceString = "";
  String? _price = "";
  String? _variant = "";
  String? _totalPrice = "...";
  var _selectedChoices = [];

  String? _name;
  String? _thumbnail_image;
  ScrollController _colorScrollController = ScrollController();

  void initState() {
    super.initState();
  }


  void fetchAll(BuildContext context) {
    reset();
    fetchProductDetails(context);
  }

  fetchProductDetails(BuildContext context) async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(id: widget.id);

    if (productDetailsResponse.detailed_products!.length > 0) {
      _productDetails = productDetailsResponse.detailed_products![0];
    }

    setProductDetailValues();
    onShowDialog(context);

    setState(() {});
  }

  String makeHtml(String string) {
    return """
<!DOCTYPE html>
<html>

<head>
  <title>Title of the document</title>
  <style>
  *{
  margin:0;
  padding:0;
  }
    #wrap {
      padding: 0;
      overflow: hidden;
    }
    #scaled-frame {
      zoom: 2;
      -moz-transform: scale(2);
      -moz-transform-origin: 0 0;
      -o-transform: scale(2);
      -o-transform-origin: 0 0;
      -webkit-transform: scale(2);
      -webkit-transform-origin: 0 0;
    }
    #scaled-frame {
      border: 0px;      
    }

    @media screen and (-webkit-min-device-pixel-ratio:0) {
      #scaled-frame {
        zoom: 2;
      }

    }
  </style>
</head>

<body>
  <div id="scaled-frame">
$string
  </div>
</body>

</html>
""";
  }

  setProductDetailValues() {
    _productImageList.clear();
    _colorList.clear();
    if (_productDetails != null) {
      controller.loadHtmlString(makeHtml(_productDetails!.description!));
      _stock = _productDetails!.current_stock;
      print('fkefseofsf $_stock');
      _totalPrice=_productDetails!.discount_price;

      _productDetails!.photos!.forEach((photo) {
        _productImageList.add(photo.path);
      });

      _productDetails!.choice_options!.forEach((choiceOpiton) {
        _selectedChoices.add(choiceOpiton.options![0]);
      });
      _productDetails!.colors!.forEach((color) {
        _colorList.add(color);
      });

      setChoiceString();
      fetchAndSetVariantWiseInfo();

      setState(() {});
    }
  }

  setChoiceString() {
    _choiceString = _selectedChoices.join(",").toString();
    print(_choiceString);
    setState(() {});
  }

  reset() {
    _currentImage = 0;
    _productImageList.clear();
    _colorList.clear();
    _selectedChoices.clear();
    _choiceString = "";
    _variant = "";
    _selectedColorIndex = 0;
    _quantity = 1;
    setState(() {});
  }


  Row buildMainPriceRow() {
    return Row(
      children: [
        Text( _productDetails!.discount_price.toString(),
          style: TextStyle(
              color: MyTheme.accent_color,
              fontSize: 16.0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: _productDetails!.has_discount!,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
                _productDetails!.stroked_price!,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Color.fromRGBO(224, 224, 225, 1),
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                )),
          ),
        ),
        Visibility(
          visible: _productDetails!.has_discount!,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "${_productDetails!.discount}",
              style: TextStyles.largeBoldAccentTexStyle(),
            ),
          ),
        ),
      ],
    );
  }

  buildColorRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              'Color',
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          alignment: app_language_rtl.$!
              ? Alignment.centerRight
              : Alignment.centerLeft,
          height: 40,
          child: Scrollbar(
            controller: _colorScrollController,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 10,
                );
              },
              itemCount: _colorList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildColorItem(index),
                  ],
                );
              },
            ),
          ),
        )
      ],
    );
  }

  buildColorCheckerContainer() {
    return Padding(
        padding: const EdgeInsets.all(3),
        child: /*Icon(Icons.check, color: Colors.white, size: 16),*/
            Image.asset(
          "assets/white_tick.png",
          width: 16,
          height: 16,
        ));
  }

  _onColorChange(index) {
    _selectedColorIndex = index;
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  Widget buildColorItem(index) {
    return InkWell(
      onTap: () {
        _onColorChange(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: _selectedColorIndex == index ? 30 : 25,
        height: _selectedColorIndex == index ? 30 : 25,
        decoration: BoxDecoration(
          // border: Border.all(
          //     color: _selectedColorIndex == index
          //         ? Colors.purple
          //         : Colors.white,
          //     width: 1),
          borderRadius: BorderRadius.circular(16.0),
          color: ColorHelper.getColorFromColorCode(_colorList[index]),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(_selectedColorIndex == index ? 0.25 : 0.12),
              blurRadius: 10,
              spreadRadius: 2.0,
              offset: Offset(0.0, 6.0), // shadow direction: bottom right
            )
          ],
        ),
        child: _selectedColorIndex == index
            ? buildColorCheckerContainer()
            : Container(
                height: 25,
              ),
      ),
    );
  }

  onShowDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.close,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 200,
                            child: new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: _productImageList.length ?? 0,
                                itemBuilder: (BuildContext ctx, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      stateSetter(() {
                                        _currentImage = index;
                                        print("CurrentImage: $_currentImage");
                                      });
                                    },
                                    child: Container(
                                        width: 50,
                                        height: 50,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: _currentImage == index
                                                  ? MyTheme.accent_color
                                                  : Color.fromRGBO(
                                                      112, 112, 112, .3),
                                              width: _currentImage == index
                                                  ? 2
                                                  : 1),
                                          //shape: BoxShape.rectangle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: AIZImage.basicImage(
                                              _productImageList[_currentImage]),
                                        )),
                                  );
                                }),
                          ),
                          Container(
                              width: 200,
                              height: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6),
                                    bottom: Radius.zero),
                                child: AIZImage.basicImage(
                                    _productDetails!.thumbnail_image ?? ''),
                              ))
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          _productDetails!.name ?? '',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 14, right: 2),
                        child: _productDetails != null
                            ? buildMainPriceRow()
                            : ShimmerHelper().buildBasicShimmer(
                                height: 30.0,
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 14, right: 14),
                        child: _productDetails != null
                            ? (_colorList.length > 0
                                ? buildColorRow()
                                : Container())
                            : ShimmerHelper().buildBasicShimmer(
                                height: 30.0,
                              ),
                      ),
                      _stock != 0
                          ? buildQuantityRow(stateSetter)
                          : Container(child: Text("Out of stock")),
                      Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 14),
                        child: _productDetails != null
                            ? buildTotalPriceRow()
                            : ShimmerHelper().buildBasicShimmer(
                                height: 30.0,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? EdgeInsets.only(left: 8.0)
                          : EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: MyTheme.font_grey, width: 1.0)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                "assets/cart.png",
                                color: Colors.white,
                                height: 20,
                                width: 20,
                              ),
                            ),
                            Text(
                              "Add to cart",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          onPressAddToCart(context, _addedToCartSnackbar);
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  SnackBar _addedToCartSnackbar = SnackBar(
    content: Text(
      'Added to cart',
      style: TextStyle(color: MyTheme.font_grey),
    ),
    backgroundColor: MyTheme.soft_accent_color,
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'show cart all',
      onPressed: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return Cart(has_bottomnav: false);
        // })).then((value) {
        //   onPopped(value);
        // });
      },
      textColor: MyTheme.accent_color,
      disabledTextColor: Colors.grey,
    ),
  );

  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  addToCart({mode, context, snackbar}) async {
    if (is_logged_in.$ == false) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    var cartAddResponse = await CartRepository()
        .getCartAddResponse(widget.id, _variant, user_id.$, _quantity);
    print("add to cart response: ${cartAddResponse.result}");

    if (cartAddResponse.result == false) {
      ToastComponent.showDialog(cartAddResponse.message,
          gravity: Toast.bottom, duration: Toast.lengthLong);
      return;
    } else {
      Provider.of<CartCounter>(context, listen: false).getCount();

      if (mode == "add_to_cart") {

        Navigator.of(context).pop();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return CartScreen(has_bottomnav:false);
            }));

      }
    }
  }

  buildQuantityUpButton(StateSetter stateSetter) => Container(
        decoration: BoxDecorations.buildCircularButtonDecoration_1(),
        width: 36,
        child: IconButton(
            icon: Icon(Icons.add, size: 16, color: MyTheme.dark_grey),
            onPressed: () {
              stateSetter(() {
                if (_quantity! < _stock!) {
                  _quantity = (_quantity!) + 1;
                }
              });
              print("Quan up: $_quantity");
              fetchAndSetVariantWiseInfo(stateSetter: stateSetter);
            }),
      );

  buildQuantityDownButton(StateSetter stateSetter) => Container(
      decoration: BoxDecorations.buildCircularButtonDecoration_1(),
      width: 36,
      child: IconButton(
          icon: Icon(Icons.remove, size: 16, color: MyTheme.dark_grey),
          onPressed: () {
            stateSetter(() {
              if (_quantity! > 1) {
                _quantity = _quantity! - 1;
              }
            });
            print("Quan down: $_quantity");

            fetchAndSetVariantWiseInfo(stateSetter: stateSetter);
          }));

  fetchAndSetVariantWiseInfo({StateSetter? stateSetter}) async {
    var colorString = _colorList.length > 0
        ? _colorList[_selectedColorIndex].toString().replaceAll("#", "")
        : "";
    var variantResponse = await ProductRepository().getVariantWiseInfo(
        id: widget.id,
        color: colorString,
        variants: _choiceString,
        qty: _quantity);
    _price = variantResponse.variantData!.price;
    _stock = variantResponse.variantData!.stock;
    if (_quantity! > _stock!) {
      _quantity = _stock;
    }
    _variant = variantResponse.variantData!.variant;
    print("Variant quantity totalprice: $_totalPrice");

    stateSetter!(() {
      _totalPrice = variantResponse.variantData!.price;

    });
    int pindex = 0;
    _productDetails!.photos!.forEach((photo) {
      if (photo.variant == _variant &&
          variantResponse.variantData!.image != "") {
        _currentImage = pindex;
      }
      pindex++;
    });

    setState(() {});
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 40,
      color: MyTheme.amber,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Padding(
              padding: app_language_rtl.$!
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: Container(
                width: 75,
                child: Text(
                  'Total Price',
                  style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(

                      _totalPrice.toString(),
              style: TextStyle(
                  color: MyTheme.accent_color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Row buildQuantityRow(StateSetter stateSetter) {
    return Row(
      children: [
        Container(
          width: 75,
          child: Text(
            'Quantity',
            style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
          ),
        ),
        Container(
          height: 36,
          width: 110,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildQuantityDownButton(stateSetter),
              Container(
                  width: 36,
                  child: Center(
                      child: Text(
                    _quantity.toString(),
                    style: TextStyle(fontSize: 18, color: MyTheme.dark_grey),
                  ))),
              buildQuantityUpButton(stateSetter)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "($_stock)",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //print((MediaQuery.of(context).size.width - 48 ) / 2);
    return Container(
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return widget.identifier == 'auction'
                      ? AuctionProductsDetails(id: widget.id)
                      : ProductDetails(
                          id: widget.id,
                        );
                }));
              },
              child: Column(children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      width: double.infinity,
                      child: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6), bottom: Radius.zero),
                        child: AIZImage.basicImage(widget.image!),
                      )),
                ),
                Container(
                  height: 65,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          widget.name!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.2,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      // widget.has_discount!
                      widget.main_price != widget.stroked_price
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                SystemConfig.systemCurrency!.code != null
                                    ? widget.stroked_price!.replaceAll(
                                        SystemConfig.systemCurrency!.code!,
                                        SystemConfig.systemCurrency!.symbol!)
                                    : widget.main_price!,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: MyTheme.medium_grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          : Container(
                              height: 10.0,
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    widget.main_price!,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Align(
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
                            textHeightBehavior: TextHeightBehavior(
                                applyHeightToFirstAscent: false),
                            softWrap: false,
                          ),
                        ),
                      Visibility(
                        visible: whole_sale_addon_installed.$,
                        child:
                            widget.is_wholesale != null && widget.is_wholesale!
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
                )
              ]),
            ),
            GestureDetector(
              onTap: () {
                fetchAll(context);
              },
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0.0),
                  color: Color.fromRGBO(229, 241, 248, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/cart.png",
                    color: MyTheme.dark_font_grey,
                    height: 8,
                  ),
                ),
              ),
            ),
          ],
        ));

    // disc;
  }
}
