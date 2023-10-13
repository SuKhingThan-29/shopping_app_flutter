import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../custom/btn.dart';
import '../helpers/shared_value_helper.dart';

class CategoryProducts extends StatefulWidget {
  CategoryProducts({Key? key, this.category_name, this.category_id})
      : super(key: key);
  final String? category_name;
  final int? category_id;

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<dynamic> _productList = [];
  List<Category> _subCategoryList = [];
  bool _isInitial = true;
  int _page = 1;
  String _searchKey = "";
  int? _totalData = 0;
  bool _showLoadingContainer = false;
  bool _showSearchBar = false;

  String? _selectedSort = "";

  // bool _isProductInitial = true;
  //int _productPage = 1;
  // int? _totalProductData = 0;
  // bool _showProductLoadingContainer = false;

  final TextEditingController _minPriceController = new TextEditingController();
  final TextEditingController _maxPriceController = new TextEditingController();

  getSubCategory() async {
    var res =
        await CategoryRepository().getCategories(parent_id: widget.category_id);
    _subCategoryList.addAll(res.categories!);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAllDate();

    _xcrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  fetchData() async {
    var productResponse = await ProductRepository().getCategoryProducts(
        id: widget.category_id, page: _page, name: _searchKey);
    _productList.addAll(productResponse.products!);
    _isInitial = false;
    _totalData = productResponse.meta!.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchAllDate() {
    fetchData();
    getSubCategory();
  }

  reset() {
    _subCategoryList.clear();
    _productList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAllDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            buildProductList(),
            Align(
                alignment: Alignment.bottomCenter,
                child: buildLoadingContainer())
          ],
        ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _productList.length
            ? AppLocalizations.of(context)!.no_more_products_ucf
            : AppLocalizations.of(context)!.loading_more_products_ucf),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: _subCategoryList.isEmpty
          ? DeviceInfo(context).height! / 10
          : DeviceInfo(context).height! / 5,
      flexibleSpace: Container(
        height: DeviceInfo(context).height! / 3,
        width: DeviceInfo(context).width,
        color: MyTheme.accent_color,
        alignment: Alignment.topRight,
        child: Image.asset(
          "assets/background_1.png",
        ),
      ),
      bottom: PreferredSize(
          child: AnimatedContainer(
            //color: MyTheme.textfield_grey,
            height: _subCategoryList.isEmpty ? 0 : 100,
            duration: Duration(milliseconds: 500),
            child: !_isInitial ? buildSubCategory() : buildSubCategory(),
          ),
          preferredSize: Size.fromHeight(0.0)),
      // leading: Builder(
      //   builder: (context) => IconButton(
      //     icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      title: buildAppBarTitle(context),
      elevation: 0.0,
      titleSpacing: 0,
      // actions: <Widget>[
      //   Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      //     child: IconButton(
      //       icon: Icon(Icons.search, color: MyTheme.dark_grey),
      //       onPressed: () {
      //         _searchKey = _searchController.text.toString();
      //         reset();
      //         fetchData();
      //       },
      //     ),
      //   ),
      // ],
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: buildAppBarTitleOption(context),
        secondChild: buildAppBarSearchOption(context),
        firstCurve: Curves.fastOutSlowIn,
        secondCurve: Curves.fastOutSlowIn,
        crossFadeState: _showSearchBar
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 500));
  }

  Container buildAppBarTitleOption(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 20,
            child: UsefulElements.backButton(context, color: "white"),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: DeviceInfo(context).width! / 2,
            child: Text(
              widget.category_name!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Spacer(),
          SizedBox(
            width: 20,
            child: IconButton(
                onPressed: () {
                  _showSearchBar = true;
                  setState(() {});
                },
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.search,
                  size: 25,
                )),
          ),
        ],
      ),
    );
  }

  Container buildAppBarSearchOption(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18),
      width: DeviceInfo(context).width,
      height: 40,
      child: TextField(
        controller: _searchController,
        onTap: () {},
        onChanged: (txt) {
          _searchKey = txt;
          reset();
          fetchData();
        },
        onSubmitted: (txt) {
          _searchKey = txt;
          reset();
          fetchData();
        },
        autofocus: false,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              _showSearchBar = false;
              setState(() {});
            },
            icon: Icon(
              Icons.clear,
              color: MyTheme.grey_153,
            ),
          ),
          filled: true,
          fillColor: MyTheme.white.withOpacity(0.6),
          hintText: "${AppLocalizations.of(context)!.search_products_from} : " +
              widget.category_name!,
          hintStyle: TextStyle(fontSize: 14.0, color: MyTheme.font_grey),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius: BorderRadius.circular(6)),
          contentPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  _onSortChange() {
    reset();
    resetProductList();
    fetchProductData();
  }

  resetProductList() {
    _productList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchProductData() async {
    //print("sc:"+_selectedCategories.join(",").toString());
    //print("sb:"+_selectedBrands.join(",").toString());
    var productResponse = await ProductRepository().getFilteredProducts(
        page: _page,
        name: _searchKey,
        sort_key: _selectedSort,
        max: _maxPriceController.text.toString(),
        min: _minPriceController.text.toString());

    _productList.addAll(productResponse.products!);
    _isInitial = false;
    _totalData = productResponse.meta!.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  Column buildSubCategory() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
              padding: EdgeInsets.only(left: 18, right: 18, bottom: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CategoryProducts(
                            category_id: _subCategoryList[index].id,
                            category_name: _subCategoryList[index].name,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    height: _subCategoryList.isEmpty ? 0 : 46,
                    width: _subCategoryList.isEmpty ? 0 : 96,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecorations.buildBoxDecoration_1(),
                    child: Text(
                      _subCategoryList[index].name!,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.font_grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 10,
                );
              },
              itemCount: _subCategoryList.length),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => Directionality(
                      textDirection: app_language_rtl.$!
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: AlertDialog(
                        contentPadding: EdgeInsets.only(
                            top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
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
                                    ListTileControlAffinity.leading,
                                title: Text(
                                    AppLocalizations.of(context)!.default_ucf),
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
                                    ListTileControlAffinity.leading,
                                title: Text(AppLocalizations.of(context)!
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
                                    ListTileControlAffinity.leading,
                                title: Text(AppLocalizations.of(context)!
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
                                    ListTileControlAffinity.leading,
                                title: Text(AppLocalizations.of(context)!
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
                                    ListTileControlAffinity.leading,
                                title: Text(AppLocalizations.of(context)!
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
                                    ListTileControlAffinity.leading,
                                title: Text(AppLocalizations.of(context)!
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
                              AppLocalizations.of(context)!.close_all_capital,
                              style: TextStyle(color: MyTheme.medium_grey),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
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
                    vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                    horizontal:
                        BorderSide(color: MyTheme.light_grey, width: 1))),
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
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  buildProductList() {
    if (_isInitial && _productList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildProductGridShimmer(scontroller: _scrollController));
    } else if (_productList.length > 0) {
      return RefreshIndicator(
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        displacement: 0,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          controller: _xcrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            itemCount: _productList.length,
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              // 3
              return ProductCard(
                  id: _productList[index].id,
                  image: _productList[index].thumbnail_image,
                  name: _productList[index].name,
                  main_price: _productList[index].main_price,
                  stroked_price: _productList[index].stroked_price,
                  discount: _productList[index].discount,
                  is_wholesale: _productList[index].isWholesale,
                  has_discount: _productList[index].has_discount);
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
}
