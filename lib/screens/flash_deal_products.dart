import 'package:active_ecommerce_flutter/custom/aiz_image.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/string_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:toast/toast.dart';

class FlashDealProducts extends StatefulWidget {
  FlashDealProducts(
      {Key? key,
      this.flash_deal_id,
      this.flash_deal_name,
      this.countdownTimerController,
      this.bannerUrl})
      : super(key: key);
  final int? flash_deal_id;
  final CountdownTimerController? countdownTimerController;
  final String? bannerUrl;
  final String? flash_deal_name;

  @override
  _FlashDealProductsState createState() => _FlashDealProductsState();
}

class _FlashDealProductsState extends State<FlashDealProducts> {
  TextEditingController _searchController = new TextEditingController();

  Future<ProductMiniResponse>? _future;

  late List<Product> _searchList;
  late List<Product> _fullList;
  ScrollController? _scrollController;
  String? _selectedSort = "";
  int? _totalData = 0;
  bool _showLoadingContainer = false;
  List<dynamic> _productList = [];
  List<Category> _subCategoryList = [];
  bool _isInitial = true;
  int _page = 1;
  String _searchKey = "";

  final TextEditingController _minPriceController = new TextEditingController();
  final TextEditingController _maxPriceController = new TextEditingController();

  String timeText(String txt, {default_length = 3}) {
    var blank_zeros = default_length == 3 ? "000" : "00";
    var leading_zeros = "";
    if (txt != null) {
      if (default_length == 3 && txt.length == 1) {
        leading_zeros = "00";
      } else if (default_length == 3 && txt.length == 2) {
        leading_zeros = "0";
      } else if (default_length == 2 && txt.length == 1) {
        leading_zeros = "0";
      }
    }

    var newtxt = (txt == null || txt == "" || txt == null.toString())
        ? blank_zeros
        : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leading_zeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  @override
  void initState() {
    // TODO: implement initState
    _future =
        ProductRepository().getFlashDealProducts(id: widget.flash_deal_id);
    _searchList = [];
    _fullList = [];
    super.initState();
  }

  _buildSearchList(search_key) async {
    _searchList.clear();
    //print(_fullList.length);

    if (search_key.isEmpty) {
      _searchList.addAll(_fullList);
      setState(() {});
      //print("_searchList.length on empty " + _searchList.length.toString());
      //print("_fullList.length on empty " + _fullList.length.toString());
    } else {
      for (var i = 0; i < _fullList.length; i++) {
        if (StringHelper().stringContains(_fullList[i].name, search_key)!) {
          _searchList.add(_fullList[i]);
          setState(() {});
        }
      }

      //print("_searchList.length with txt " + _searchList.length.toString());
      //print("_fullList.length with txt " + _fullList.length.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildProductList(context),
      ),
    );
  }

  bool? shouldProductBoxBeVisible(product_name, search_key) {
    if (search_key == "") {
      return true; //do not check if the search key is empty
    }
    return StringHelper().stringContains(product_name, search_key);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 75,
      /*bottom: PreferredSize(
          child: Container(
            color: MyTheme.textfield_grey,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(4.0)),*/
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(context),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        width: 250,
        child: TextField(
          controller: _searchController,
          onChanged: (txt) {
            print(txt);
            _buildSearchList(txt);
            // print(_searchList.toString());
            // print(_searchList.length);
          },
          onTap: () {},
          autofocus: true,
          decoration: InputDecoration(
              hintText: "Search Product for flash deal  ",
              hintStyle:
                  TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyTheme.white, width: 0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyTheme.white, width: 0.0),
              ),
              contentPadding: EdgeInsets.all(0.0)),
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.search, color: MyTheme.dark_grey),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  buildProductList(context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<ProductMiniResponse> snapshot) {
          if (snapshot.hasError) {
            return Container();
          } else if (snapshot.hasData) {
            var productResponse = snapshot.data;
            if (_fullList.length == 0) {
              _fullList.addAll(productResponse!.products!);
              _searchList.addAll(productResponse!.products!);
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  buildFlashDealsBanner(context),
                  MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    itemCount: _searchList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10, left: 18, right: 18),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // 3
                      return ProductCard(
                        id: _searchList[index].id,
                        image: _searchList[index].thumbnail_image,
                        name: _searchList[index].name,
                        main_price: _searchList[index].main_price,
                        stroked_price: _searchList[index].stroked_price,
                        has_discount: _searchList[index].has_discount,
                        discount: _searchList[index].discount,
                        is_wholesale: _searchList[index].isWholesale,
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  headerShimmer(),
                  ShimmerHelper()
                      .buildProductGridShimmer(scontroller: _scrollController),
                ],
              ),
            );
          }
        });
  }

  Container buildFlashDealsBanner(BuildContext context) {
    fetchProductData() async {
      print(widget.flash_deal_id);
      // print("sc:"+_selectedCategories.join(",").toString());
      // print("sb:"+_selectedBrands.join(",").toString());
      var productResponse = await ProductRepository()
          .getFilteredFlashDealProducts(
              page: widget.flash_deal_id,
              name: _searchKey,
              sort_key: _selectedSort,
              max: _maxPriceController.text.toString(),
              min: _minPriceController.text.toString());

      _searchList.addAll(productResponse.products!);
      print("${_searchList[0].stroked_price} ${_searchList[0].name}");
      _isInitial = false;
      _totalData = productResponse.meta?.total;
      _showLoadingContainer = false;
      setState(() {});
    }

    resetProductList() {
      _searchList.clear();
      _isInitial = true;
      _totalData = 0;
      _page = 1;
      _showLoadingContainer = false;
      setState(() {});
    }

    reset() {
      _subCategoryList.clear();
      _searchList.clear();
      _isInitial = true;
      _totalData = 0;
      _page = 1;
      _showLoadingContainer = false;
      setState(() {});
    }

    _onSortChange() {
      _searchList.clear();
      // print(_fullList[0].discount);
      reset();
      resetProductList();
      fetchProductData();
    }

    return Container(
      //color: MyTheme.amber,
      height: 320,
      child: CountdownTimer(
        controller: widget.countdownTimerController,
        widgetBuilder: (_, CurrentRemainingTime? time) {
          return Column(
            children: [
              buildFlashDealBanner(),
              Container(
                child: Column(
                  children: [
                    Container(
                      width: DeviceInfo(context).width,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecorations.buildBoxDecoration_1(),
                      child: Center(
                          child: time == null
                              ? Text(
                                  AppLocalizations.of(context)!.ended_ucf,
                                  style: TextStyle(
                                      color: MyTheme.accent_color,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                )
                              : buildTimerRowRow(time)),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => Directionality(
                                    textDirection: app_language_rtl.$!
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: AlertDialog(
                                      contentPadding: EdgeInsets.only(
                                          top: 16.0,
                                          left: 2.0,
                                          right: 2.0,
                                          bottom: 2.0),
                                      content: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24.0),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .sort_products_by_ucf,
                                                )),
                                            RadioListTile(
                                              dense: true,
                                              value: "",
                                              groupValue: _selectedSort,
                                              activeColor: MyTheme.font_grey,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .default_ucf),
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  _selectedSort = value;
                                                });
                                                _onSortChange();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            RadioListTile(
                                              dense: true,
                                              value: "price_high_to_low",
                                              groupValue: _selectedSort,
                                              activeColor: MyTheme.font_grey,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .price_high_to_low),
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  _selectedSort = value;
                                                });
                                                _onSortChange();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            RadioListTile(
                                              dense: true,
                                              value: "price_low_to_high",
                                              groupValue: _selectedSort,
                                              activeColor: MyTheme.font_grey,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .price_low_to_high),
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  _selectedSort = value;
                                                });
                                                _onSortChange();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            RadioListTile(
                                              dense: true,
                                              value: "new_arrival",
                                              groupValue: _selectedSort,
                                              activeColor: MyTheme.font_grey,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .new_arrival_ucf),
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  _selectedSort = value;
                                                });
                                                _onSortChange();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            RadioListTile(
                                              dense: true,
                                              value: "popularity",
                                              groupValue: _selectedSort,
                                              activeColor: MyTheme.font_grey,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .popularity_ucf),
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  _selectedSort = value;
                                                });
                                                _onSortChange();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            RadioListTile(
                                              dense: true,
                                              value: "top_rated",
                                              groupValue: _selectedSort,
                                              activeColor: MyTheme.font_grey,
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .leading,
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .top_rated_ucf),
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  _selectedSort = value;
                                                });
                                                _onSortChange();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      }),
                                      actions: [
                                        Btn.basic(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .close_all_capital,
                                            style: TextStyle(
                                                color: MyTheme.medium_grey),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.symmetric(
                                  vertical: BorderSide(
                                      color: MyTheme.light_grey, width: .5),
                                  horizontal: BorderSide(
                                      color: MyTheme.light_grey, width: 1))),
                          height: 36,
                          width: MediaQuery.of(context).size.width * .33,
                          child: Center(
                              child: Container(
                            width: 50,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_vert,
                                  size: 13,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "Sort",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  headerShimmer() {
    return Container(
      // color: MyTheme.amber,
      height: 215,
      child: Stack(
        children: [
          buildFlashDealBannerShimmer(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: DeviceInfo(context).width,
              margin: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Container(
                child: buildTimerRowRowShimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildFlashDealBanner() {
    print("Banner url: ${DeviceInfo(context).width}");
    return Container(
      width: DeviceInfo(context).width,
      height: 180,
      child: AIZImage.basicImage(widget.bannerUrl!,fit: BoxFit.contain
      ),
    );
  }

  Widget buildFlashDealBannerShimmer() {
    return ShimmerHelper().buildBasicShimmerCustomRadius(
        width: DeviceInfo(context).width,
        height: 180,
        color: MyTheme.medium_grey_50);
  }

  Widget buildTimerRowRow(CurrentRemainingTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.watch_later_outlined,
            color: MyTheme.grey_153,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            children: [
              Text('day'),
              timerContainer(
                Text(
                  timeText(time.days.toString(), default_length: 3),
                  style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 4,
          ),
          Column(
            children: [
              Text('hr'),
              timerContainer(
                Text(
                  timeText(time.hours.toString(), default_length: 2),
                  style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 4,
          ),
          Column(
            children: [
              Text('min'),
              timerContainer(
                Text(
                  timeText(time.min.toString(), default_length: 2),
                  style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 4,
          ),
          Column(
            children: [
              Text('sec'),
              timerContainer(
                Text(
                  timeText(time.sec.toString(), default_length: 2),
                  style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Image.asset(
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildTimerRowRowShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.watch_later_outlined,
            color: MyTheme.grey_153,
          ),
          SizedBox(
            width: 10,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 4,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 4,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 4,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 10,
          ),
          Image.asset(
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget timerContainer(Widget child) {
    return Container(
      constraints: BoxConstraints(minWidth: 30, minHeight: 24),
      child: child,
      alignment: Alignment.center,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: MyTheme.accent_color,
      ),
    );
  }
}
