import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../custom/aiz_image.dart';
import '../data_model/product_details_response.dart';
import '../helpers/shared_value_helper.dart';
import '../repositories/product_repository.dart';
import '../screens/auction_products_details.dart';

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
  void initState(){
    super.initState();
  }

  // fetchAndSetVariantWiseInfo({bool change_appbar_string = true}) async {
  //   var colorString = _colorList.length > 0
  //       ? _colorList[_selectedColorIndex].toString().replaceAll("#", "")
  //       : "";
  //
  //   /*print("color string: "+color_string);
  //   return;*/
  //
  //   var variantResponse = await ProductRepository().getVariantWiseInfo(
  //       id: widget.id,
  //       color: colorString,
  //       variants: _choiceString,
  //       qty: _quantity);
  //   _price = variantResponse.variantData!.price;
  //   print("single price ${variantResponse.variantData!.price}");
  //   /*print("vr"+variantResponse.toJson().toString());
  //   return;*/
  //
  //   // _singlePrice = variantResponse.price;
  //   _stock = variantResponse.variantData!.stock;
  //   _stock_txt = variantResponse.variantData!.stockTxt;
  //   if (_quantity! > _stock!) {
  //     _quantity = _stock;
  //   }
  //
  //   _variant = variantResponse.variantData!.variant;
  //
  //   //fetchVariantPrice();
  //   // _singlePriceString = variantResponse.price_string;
  //   _totalPrice = variantResponse.variantData!.price;
  //
  //   // if (change_appbar_string) {
  //   //   _appbarPriceString = "${variantResponse.variant} ${_singlePriceString}";
  //   // }
  //
  //   int pindex = 0;
  //   _productDetails!.photos!.forEach((photo) {
  //     //print('con:'+ (photo.variant == _variant && variantResponse.image != "").toString());
  //     if (photo.variant == _variant &&
  //         variantResponse.variantData!.image != "") {
  //       _currentImage = pindex;
  //       _carouselController.jumpToPage(pindex);
  //     }
  //     pindex++;
  //   });
  //   setState(() {});
  // }
  void fetchAll() {
    fetchProductDetails();
    setProductDetailValues();

  }

  fetchProductDetails() async {
    var productDetailsResponse =
    await ProductRepository().getProductDetails(id: widget.id);

    if (productDetailsResponse.detailed_products!.length > 0) {
      _productDetails = productDetailsResponse.detailed_products![0];
    }
    print("Product Details: ${_productDetails!.name!}");
    print("Product Details: ${_productDetails!.thumbnail_image!}");

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
    if (_productDetails != null) {
      controller.loadHtmlString(makeHtml(_productDetails!.description!));
      // _appbarPriceString = _productDetails!.price_high_low;
      // _singlePrice = _productDetails!.calculable_price;
      // _singlePriceString = _productDetails!.main_price;
      // // fetchVariantPrice();
      // _stock = _productDetails!.current_stock;
      _productDetails!.photos!.forEach((photo) {
        _productImageList.add(photo.path);
      });
      print("Product image: ${_productImageList.length}");

      // _productDetails!.choice_options!.forEach((choiceOpiton) {
      //   _selectedChoices.add(choiceOpiton.options![0]);
      // });
      // _productDetails!.colors!.forEach((color) {
      //   _colorList.add(color);
      // });
      //
      // setChoiceString();

      // if (_productDetails!.colors.length > 0 ||
      //     _productDetails!.choice_options.length > 0) {
      //   fetchAndSetVariantWiseInfo(change_appbar_string: true);
      // }
      // fetchAndSetVariantWiseInfo(change_appbar_string: true);
      // _productDetailsFetched = true;

      setState(() {});
    }
  }

  buildShowAddFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 36.0),
              content: Container(
                height: 400,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        InkWell(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Container(

                            child: Icon(
                              Icons.close,

                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      //color:Colors.blue,
                      child: Text(
                        widget.name!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                   Column(
                     children: [
                       Container(
                           width: 150,
                           height: 150,
                           child: ClipRRect(
                             borderRadius: BorderRadius.vertical(
                                 top: Radius.circular(6), bottom: Radius.zero),
                             child: AIZImage.basicImage(_productDetails!.thumbnail_image!),
                           )),
                      _productImageList.length>0? SizedBox(
                        height: 50,
                        child: Padding(
                          padding: app_language_rtl.$!
                              ? EdgeInsets.only(left: 8.0)
                              : EdgeInsets.only(right: 8.0),
                          child: ListView.builder(
                              itemCount: _productImageList.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                int itemIndex = index;
                                return GestureDetector(
                                  onTap: () {
                                    // _currentImage = itemIndex;
                                    // print(_currentImage);
                                    // setState(() {});
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: _currentImage == itemIndex
                                              ? MyTheme.accent_color
                                              : Color.fromRGBO(112, 112, 112, .3),
                                          width: _currentImage == itemIndex ? 2 : 1),
                                      //shape: BoxShape.rectangle,
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child:
                                        /*Image.asset(
                                      singleProduct.product_images[index])*/
                                        FadeInImage.assetNetwork(
                                          placeholder: 'assets/placeholder.png',
                                          image: _productImageList[index],
                                          fit: BoxFit.contain,
                                        )),
                                  ),
                                );
                              }),
                        ),
                      ):Container(),
                     ],
                   )

                  ],
                )

              ),
              actions: [
              ],
            );
          });
        });
  }


  @override
  Widget build(BuildContext context) {
    //print((MediaQuery.of(context).size.width - 48 ) / 2);
    return Container(
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(),
        child: Stack(
          children: [
            Column(
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
                        SystemConfig.systemCurrency!.code != null
                            ? widget.main_price!.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!)
                            : widget.main_price!,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
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
                                  textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false),
                                  softWrap: false,
                                ),
                              ),
                            Visibility(
                              visible: whole_sale_addon_installed.$,
                              child: widget.is_wholesale != null &&
                                  widget.is_wholesale!
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
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    fetchAll();

                    buildShowAddFormDialog(context);
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
            )
          ],
        )
    );

    // disc;
  }

}
