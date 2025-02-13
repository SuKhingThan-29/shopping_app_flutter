import 'dart:async';

import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../repositories/brand_repository.dart';

class HomePresenter extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  int current_slider = 0;
  ScrollController? allProductScrollController;
  ScrollController? featuredCategoryScrollController;
  ScrollController mainScrollController = ScrollController();

  late AnimationController pirated_logo_controller;
  late Animation pirated_logo_animation;

  var carouselImageList = [];
  var bannerOneImageList = [];
  var bannerTwoImageList = [];
  var featuredCategoryList = [];
  var todaysDealProducts = [];
  var flashDealProducts = [];

  bool isCategoryInitial = true;

  bool isCarouselInitial = true;
  bool isBannerOneInitial = true;
  bool isBannerTwoInitial = true;
  bool isTodayDetailInitial = true;
  bool isFlashDealInitial = true;

  var featuredProductList = [];
  bool isFeaturedProductInitial = true;
  int? totalFeaturedProductData = 0;
  int featuredProductPage = 1;
  bool showFeaturedLoadingContainer = false;

  bool isTodayDeal = false;
  bool isFlashDeal = false;

  var allBrandList = [];
  bool isBrandInitial =true;
  int? totalBrandData = 0;
  int allBrandPage=1;
  bool showBrandLoadingContainer = false;

  var allProductList = [];
  bool isAllProductInitial = true;
  int? totalAllProductData = 0;
  int allProductPage = 1;
  bool showAllLoadingContainer = false;
  int cartCount = 0;
  int lastPage=1;
  String selectedTab="Recommended";
  bool isScrollData=false;
  bool isMoreProduct=false;


  fetchAll() {
    fetchCarouselImages();
    fetchBannerOneImages();
    fetchBannerTwoImages();
    fetchFeaturedCategories();
    fetchFeaturedProducts();
    fetchAllProducts(tab: selectedTab);
    fetchTodayDealData();
    fetchFlashDealData();
  }
  setTab(String tab){
    selectedTab=tab;
    notifyListeners();
  }

  handleSelectProductTab(String tab) {
    selectedTab=tab;
    resetAllProductList();
    resetBrandList();
    fetchAllProducts(tab: selectedTab);
    notifyListeners();
  }

  fetchTodayDealData() async {
    var deal = await ProductRepository().getTodaysDealProducts();
    print(deal.products!.length);
    if (deal.success! && deal.products!.isNotEmpty) {
      todaysDealProducts.addAll(deal.products!);
      isTodayDeal = true;
      isTodayDetailInitial = false;
      notifyListeners();
    }
  }

  fetchFlashDealData() async {
    var deal = await FlashDealRepository().getFlashDeals();

    if (deal.success! && deal.flashDeals!.isNotEmpty) {
      flashDealProducts.addAll(deal.flashDeals!);
      isFlashDeal = true;
      isFlashDealInitial = false;
      notifyListeners();
    }
  }

  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders();
    carouselResponse.sliders!.forEach((slider) {
      carouselImageList.add(slider.photo);
    });
    isCarouselInitial = false;
    notifyListeners();
  }

  fetchBannerOneImages() async {
    var bannerOneResponse = await SlidersRepository().getBannerOneImages();
    bannerOneResponse.sliders!.forEach((slider) {
      bannerOneImageList.add(slider.photo);
    });
    isBannerOneInitial = false;
    notifyListeners();
  }

  fetchBannerTwoImages() async {
    var bannerTwoResponse = await SlidersRepository().getBannerTwoImages();
    bannerTwoResponse.sliders!.forEach((slider) {
      bannerTwoImageList.add(slider.photo);
    });
    isBannerTwoInitial = false;
    notifyListeners();
  }

  fetchFeaturedCategories() async {
    var categoryResponse = await CategoryRepository().getCategories();
    featuredCategoryList.addAll(categoryResponse.categories!);
    isCategoryInitial = false;
    notifyListeners();
  }

  fetchFeaturedProducts() async {
    var productResponse = await ProductRepository().getFeaturedProducts(
      page: featuredProductPage,
    );
    featuredProductPage++;
    featuredProductList.addAll(productResponse.products!);
    isFeaturedProductInitial = false;
    totalFeaturedProductData = productResponse.meta!.total;
    showFeaturedLoadingContainer = false;
    notifyListeners();
  }
  fetchBrandData() async {
    var brandResponse = await BrandRepository().getBrands(page: allBrandPage);
    allBrandList.addAll(brandResponse.brands!);
    isBrandInitial = false;
    totalBrandData = brandResponse.meta!.total;
    print("Total Branddata list: ${allBrandList.length}");

    print("Total Branddata: $totalBrandData");
    showBrandLoadingContainer = false;
    notifyListeners();
  }
  fetchAllProducts({String tab = ""}) async {
    print("Tab Selected $tab");
    var productResponse;
    var brandResponse;

    if (tab == "New") {
      productResponse =
          await ProductRepository().getNewProducts(page: allProductPage);
      showAllLoadingContainer=false;


    } else if(tab == "Recommended") {
      print("AppLang recom: ${app_language.$}");
      productResponse =
          await ProductRepository().getRecommendProducts(page: allProductPage);
      showAllLoadingContainer=false;

    }else if(tab == "Brand"){
      fetchBrandData();
      resetAllProductList();
    }

    if (productResponse.products!.isEmpty) {
      isAllProductInitial = false;
      showAllLoadingContainer = false;
      return;
    }
    if(productResponse.products!.isNotEmpty){
      allProductList.addAll(productResponse.products!);
      print("productList: ${allProductList.length}");
      isAllProductInitial = false;
      totalAllProductData = productResponse.meta!.total;
      showAllLoadingContainer = false;
    }

    notifyListeners();
  }

  reset() {
    carouselImageList.clear();
    bannerOneImageList.clear();
    bannerTwoImageList.clear();
    featuredCategoryList.clear();

    isCarouselInitial = true;
    isBannerOneInitial = true;
    isBannerTwoInitial = true;
    isCategoryInitial = true;
    cartCount = 0;

    resetFeaturedProductList();
    resetAllProductList();
    resetBrandList();
  }

  Future<void> onRefresh() async {
    reset();
    fetchAll();
  }

  resetFeaturedProductList() {
    featuredProductList.clear();
    isFeaturedProductInitial = true;
    totalFeaturedProductData = 0;
    featuredProductPage = 1;
    showFeaturedLoadingContainer = false;
    notifyListeners();
  }

  resetAllProductList() {
    allProductList.clear();
    isAllProductInitial = true;
    totalAllProductData = 0;
    allProductPage = 1;
    showAllLoadingContainer = false;
    notifyListeners();
  }

  resetBrandList() {
    allBrandList.clear();
    isBrandInitial = true;
    totalBrandData = 0;
    allBrandPage = 1;
    showAllLoadingContainer = false;
    notifyListeners();
  }
  mainScrollListener() {
    mainScrollController.addListener(() {
      //print("position: " + xcrollController.position.pixels.toString());
      //print("max: " + xcrollController.position.maxScrollExtent.toString());

      if (mainScrollController.position.pixels ==
          mainScrollController.position.maxScrollExtent) {
        if(selectedTab=="Brand"){
          showBrandLoadingContainer=true;
        }else{
          showAllLoadingContainer = true;
        }
          notifyListeners();
          print("selected tab scroll: $selectedTab");
          if(selectedTab=="Brand"){
            allBrandPage++;
            fetchBrandData();
          }else{
            allProductPage++;
            fetchAllProducts(tab: selectedTab);
          }

      }
    });

    notifyListeners();

  }

  initPiratedAnimation(vnc) {
    pirated_logo_controller =
        AnimationController(vsync: vnc, duration: Duration(milliseconds: 2000));
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
        CurvedAnimation(
            curve: Curves.bounceOut, parent: pirated_logo_controller));

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  // incrementFeaturedProductPage(){
  //   featuredProductPage++;
  //   notifyListeners();
  //
  // }

  incrementCurrentSlider(index) {
    current_slider = index;
    notifyListeners();
  }

  // void dispose() {
  //   pirated_logo_controller.dispose();
  //   notifyListeners();
  // }
  //

  @override
  void dispose() {
    // TODO: implement dispose
    pirated_logo_controller.dispose();
    notifyListeners();
    super.dispose();
  }
}
