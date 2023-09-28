import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/confirm_dialog.dart';
import 'package:active_ecommerce_flutter/custom/enum_classes.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/data_model/delivery_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/coupon_repository.dart';
import 'package:active_ecommerce_flutter/repositories/order_repository.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/repositories/shipping_repository.dart';
import 'package:active_ecommerce_flutter/repositories/wallet_repository.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:toast/toast.dart';

class Checkout extends StatefulWidget {
  int? order_id; // only need when making manual payment from order details
  String list;
  //final OffLinePaymentFor offLinePaymentFor;
  final PaymentFor? paymentFor;
  final double rechargeAmount;
  final String? title;
  final int? delivery_id;
  var packageId;

  Checkout(
      {Key? key,
      this.delivery_id,
      this.order_id = 0,
      this.paymentFor,
      this.list = "both",
      //this.offLinePaymentFor,
      this.rechargeAmount = 0.0,
      this.title,
      this.packageId = 0})
      : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  var _selected_payment_method_index = 0;
  String? _selected_payment_method = "";
  String? _selected_payment_method_key = "";

  ScrollController _mainScrollController = ScrollController();
  SingleValueDropDownController _couponControllerValue =
      SingleValueDropDownController();
  String? _couponController;
  int? _disprice;
  var _paymentTypeList = [];
  var _mycouponsList = [];
  bool _isInitial = true;
  String? _totalString = ". . .";
  int? _grandTotalValue = 0;
  int? _wallet = 0;
  String? _subTotalString = ". . .";
  String? _taxString = ". . .";
  String _shippingCostString = ". . .";
  String? _discountString = ". . .";
  String _used_coupon_code = "";
  bool? _coupon_applied = false;
  late BuildContext loadingcontext;
  String payment_type = "cart_payment";
  String? _title;
  dynamic _balanceDetails;
  DeliveryResponse? deliveryResponse;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*print("user data");
    print(is_logged_in.$);
    print(access_token.value);
    print(user_id.$);
    print(user_name.$);*/

    fetchAll();
    fetchBalanceDetails();
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
    _mycouponsList.clear();
  }

  fetchStoreDeliveryInfo() async {
    print("checkout deliveryId: ${widget.delivery_id}");
    deliveryResponse =
        await ShippingRepository().postDeliveryInfo(widget.delivery_id);
    print("checkout grandtotal: ${deliveryResponse!.grand_total}");
    if (deliveryResponse != null) {
      _subTotalString = deliveryResponse!.subtotal.toString();
      _shippingCostString = deliveryResponse!.delivery_price.toString();
      _discountString = deliveryResponse!.discount.toString();
      _grandTotalValue = deliveryResponse!.grand_total;
      _wallet = deliveryResponse!.wallet;
    }
    setState(() {});
  }

  fetchAll() {
    fetchList();
    fetchMyCoupons();
    if (is_logged_in.$ == true) {
      // if (widget.paymentFor != PaymentFor.Order) {
      //   _grandTotalValue = widget.rechargeAmount.toInt();
      //   payment_type = widget.paymentFor == PaymentFor.WalletRecharge
      //       ? "wallet_payment"
      //       : "customer_package_payment";
      // } else {
      //   fetchSummary();
      // }
      fetchStoreDeliveryInfo();
    }
  }

  fetchList() async {
    var paymentTypeResponseList = await PaymentRepository()
        .getPaymentResponseList(
            list: widget.list,
            mode: widget.paymentFor != PaymentFor.Order &&
                    widget.paymentFor != PaymentFor.ManualPayment
                ? "wallet"
                : "order");
    _paymentTypeList.addAll(paymentTypeResponseList);
    if (_paymentTypeList.length > 0) {
      _selected_payment_method = _paymentTypeList[0].payment_type;
      _selected_payment_method_key = _paymentTypeList[0].payment_type_key;
    }
    _isInitial = false;
    setState(() {});
  }

  // fetchSummary() async {
  //   var cartSummaryResponse =
  //   await CartRepository().getCartSummaryResponse(widget.delivery_id);
  //
  //   if (cartSummaryResponse != null) {
  //     _subTotalString = cartSummaryResponse.sub_total;
  //     _taxString = cartSummaryResponse.tax;
  //     _shippingCostString = cartSummaryResponse.shipping_cost;
  //     _discountString = cartSummaryResponse.discount;
  //     _totalString = cartSummaryResponse.grand_total;
  //     _grandTotalValue = cartSummaryResponse.grand_total_value;
  //     _used_coupon_code = cartSummaryResponse.coupon_code ?? _used_coupon_code;
  //     _couponController = _used_coupon_code;
  //     _coupon_applied = cartSummaryResponse.coupon_applied;
  //     setState(() {});
  //   }
  // }
  fetchBalanceDetails() async {
    var balanceDetailsResponse = await WalletRepository().getBalance();

    _balanceDetails = balanceDetailsResponse;

    setState(() {});
  }

  fetchMyCoupons() async {
    _mycouponsList.clear();
    var orderResponse = await OrderRepository().getMyCoupon();
    _mycouponsList.addAll(orderResponse.data);
    _isInitial = false;
    print("Mycoupon list: ${_mycouponsList.length}");
    setState(() {});
  }

  reset() {
    _paymentTypeList.clear();
    _isInitial = true;
    _selected_payment_method_index = 0;
    _selected_payment_method = "";
    _selected_payment_method_key = "";
    setState(() {});

    reset_summary();
  }

  reset_summary() {
    _totalString = ". . .";
    _grandTotalValue = 0;
    _subTotalString = ". . .";
    _taxString = ". . .";
    _shippingCostString = ". . .";
    _wallet = 0;
    _discountString = ". . .";
    _used_coupon_code = "";
    _couponController = _used_coupon_code;
    _coupon_applied = false;

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) {
    reset();
    fetchAll();
  }

  onCouponApply() async {
    var couponCode = _couponController.toString();
    if (couponCode == "") {
      ToastComponent.showDialog(AppLocalizations.of(context)!.enter_coupon_code,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var couponApplyResponse =
        await CouponRepository().getCouponApplyResponse(couponCode);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(couponApplyResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (couponApplyResponse.result == true) {
      ToastComponent.showDialog(couponApplyResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    }

    reset_summary();
    fetchStoreDeliveryInfo();
  }

  onCouponRemove() async {
    var couponRemoveResponse =
        await CouponRepository().getCouponRemoveResponse();

    if (couponRemoveResponse.result == false) {
      ToastComponent.showDialog(couponRemoveResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    if (couponRemoveResponse.result == true) {
      ToastComponent.showDialog(couponRemoveResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    }

    reset_summary();
    fetchStoreDeliveryInfo();
  }

  List<DropDownValueModel> dropDownList = [];

  onPressPlaceOrderOrProceed() {
    print(_selected_payment_method);
    if (_selected_payment_method == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.please_choose_one_option_to_pay,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else {
      ConfirmDialog.show(
        context,
        title: "Confirm Order",
        message: "Do you want to confirm this order?",
        yesText: "Yes",
        noText: "Not",
        pressYes: () {
          if (_selected_payment_method == "cash_payment") {
            pay_by_cod();
          } else if (_selected_payment_method == "ed_payment") {
            pay_by_edpayment();
          }
        },
      );
    }
  }

  pay_by_edpayment() async {
    loading();
    var orderCreateEDResponse = await PaymentRepository()
        .getOrderCreateResponseFrom_Ed_Payment(
            _selected_payment_method_key, widget.delivery_id);
    Navigator.of(loadingcontext).pop();
    print("order create ed response: ${orderCreateEDResponse.url}");
    if (orderCreateEDResponse.result == false) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }

    if (orderCreateEDResponse.result == true &&
        orderCreateEDResponse.url != null) {
      print("Invoice ID: ${orderCreateEDResponse.combined_order_id}");
      _launchUrl(orderCreateEDResponse.url);
    } else if (orderCreateEDResponse.result == true &&
        orderCreateEDResponse.url == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OrderList(from_checkout: true);
      }));
    }
  }

  Future<void> _launchUrl(_url) async {
    await FlutterWebBrowser.openWebPage(url: _url);
  }

  pay_by_wallet(price) async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromWallet(
            _selected_payment_method_key, price!.toDouble());

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
  }

  pay_by_cod() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromCod(
            _selected_payment_method_key, widget.delivery_id);
    Navigator.of(loadingcontext).pop();
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  pay_by_manual_payment() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromManualPayment(_selected_payment_method_key);
    Navigator.pop(loadingcontext);
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  onPaymentMethodItemTap(index) {
    if (_selected_payment_method_key !=
        _paymentTypeList[index].payment_type_key) {
      setState(() {
        _selected_payment_method_index = index;
        _selected_payment_method = _paymentTypeList[index].payment_type;
        _selected_payment_method_key = _paymentTypeList[index].payment_type_key;
      });
    }

    //print(_selected_payment_method);
    //print(_selected_payment_method_key);
  }

  onPressDetails() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            EdgeInsets.only(top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
        content: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 16.0),
          child: Container(
            height: 150,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!.subtotal_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Spacer(),
                        Text(
                          // SystemConfig.systemCurrency != null
                          //     ? _subTotalString!.replaceAll(
                          //     SystemConfig.systemCurrency!.code!,
                          //     SystemConfig.systemCurrency!.symbol!)
                          //     :
                          '$_subTotalString ${SystemConfig.systemCurrency!.symbol}',
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    )),
                // Padding(
                //     padding: const EdgeInsets.only(bottom: 8),
                //     child: Row(
                //       children: [
                //         Container(
                //           width: 120,
                //           child: Text(
                //             AppLocalizations.of(context)!.tax_all_capital,
                //             textAlign: TextAlign.end,
                //             style: TextStyle(
                //                 color: MyTheme.font_grey,
                //                 fontSize: 14,
                //                 fontWeight: FontWeight.w600),
                //           ),
                //         ),
                //         Spacer(),
                //         Text(
                //           SystemConfig.systemCurrency != null
                //               ? _taxString!.replaceAll(
                //               SystemConfig.systemCurrency!.code!,
                //               SystemConfig.systemCurrency!.symbol!)
                //               : _taxString!,
                //           style: TextStyle(
                //               color: MyTheme.font_grey,
                //               fontSize: 14,
                //               fontWeight: FontWeight.w600),
                //         ),
                //       ],
                //     )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!
                                .shipping_cost_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Spacer(),
                        Text(
                          // SystemConfig.systemCurrency != null
                          //     ? _shippingCostString!.replaceAll(
                          //     SystemConfig.systemCurrency!.code!,
                          //     SystemConfig.systemCurrency!.symbol!)
                          //     :
                          '$_shippingCostString ${SystemConfig.systemCurrency!.symbol}',
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!.coupon_ucf,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Spacer(),
                        Text(
                          // SystemConfig.systemCurrency != null
                          //     ? _discountString!.replaceAll(
                          //     SystemConfig.systemCurrency!.code!,
                          //     SystemConfig.systemCurrency!.symbol!)
                          //     :
                          '$_discountString ${SystemConfig.systemCurrency!.symbol}',
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            "Wallet",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Spacer(),
                        Text(
                          // SystemConfig.systemCurrency != null
                          //     ? _discountString!.replaceAll(
                          //     SystemConfig.systemCurrency!.code!,
                          //     SystemConfig.systemCurrency!.symbol!)
                          //     :
                          '$_wallet ${SystemConfig.systemCurrency!.symbol}',
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    )),
                Divider(),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            AppLocalizations.of(context)!
                                .grand_total_all_capital,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Spacer(),
                        Text(
                          // SystemConfig.systemCurrency != null
                          //     ? _grandTotalValue!.toString().replaceAll(
                          //     SystemConfig.systemCurrency!.code!,
                          //     SystemConfig.systemCurrency!.symbol!)
                          //     :
                          '$_grandTotalValue ${SystemConfig.systemCurrency!.symbol}',
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        actions: [
          Btn.basic(
            child: Text(
              AppLocalizations.of(context)!.close_all_lower,
              style: TextStyle(color: MyTheme.medium_grey),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          bottomNavigationBar: buildBottomAppBar(context),
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
                          child: buildPaymentMethodList(),
                        ),
                        Container(
                          height: 140,
                        )
                      ]),
                    )
                  ],
                ),
              ),

              //Apply Coupon and order details container
              Align(
                alignment: Alignment.bottomCenter,
                child: widget.paymentFor == PaymentFor.WalletRecharge ||
                        widget.paymentFor == PaymentFor.PackagePay
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,

                          /*border: Border(
                      top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                    )*/
                        ),
                        height: widget.paymentFor == PaymentFor.ManualPayment
                            ? 80
                            : 400,
                        //color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              widget.paymentFor == PaymentFor.Order
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: buildApplyCouponRow(context),
                                    )
                                  : Container(),
                              Divider(),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .subtotal_all_capital,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        Text(
                                          '$_subTotalString ${SystemConfig.systemCurrency!.symbol}',
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .shipping_cost_all_capital,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        Text(
                                          // SystemConfig.systemCurrency != null
                                          //     ? _shippingCostString!.replaceAll(
                                          //     SystemConfig.systemCurrency!.code!,
                                          //     SystemConfig.systemCurrency!.symbol!)
                                          //     :
                                          '$_shippingCostString ${SystemConfig.systemCurrency!.symbol}',
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .coupon_ucf,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        Text(
                                          // SystemConfig.systemCurrency != null
                                          //     ? _discountString!.replaceAll(
                                          //     SystemConfig.systemCurrency!.code!,
                                          //     SystemConfig.systemCurrency!.symbol!)
                                          //     :
                                          '$_discountString ${SystemConfig.systemCurrency!.symbol}',
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Wallet",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        Text(
                                          // SystemConfig.systemCurrency != null
                                          //     ? _discountString!.replaceAll(
                                          //     SystemConfig.systemCurrency!.code!,
                                          //     SystemConfig.systemCurrency!.symbol!)
                                          //     :
                                          '- $_wallet ${SystemConfig.systemCurrency!.symbol}',
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .grand_total_all_capital,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: MyTheme.font_grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Spacer(),
                                        Text(
                                          // SystemConfig.systemCurrency != null
                                          //     ? _grandTotalValue!.toString().replaceAll(
                                          //     SystemConfig.systemCurrency!.code!,
                                          //     SystemConfig.systemCurrency!.symbol!)
                                          //     :
                                          '$_grandTotalValue ${SystemConfig.systemCurrency!.symbol}',
                                          style: TextStyle(
                                              color: MyTheme.accent_color,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              )
            ],
          )),
    );
  }

  Row buildApplyCouponRow(BuildContext context) {
    dropDownList.clear();
    for (int i = 0; i < _mycouponsList.length; i++) {
      String name = _mycouponsList[i].code;
      int value = _mycouponsList[i].discount;

      dropDownList.add(DropDownValueModel(name: name, value: value));
    }
    return Row(
      children: [
        Container(
          height: 42,
          width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
          child: DropDownTextField(
            controller: _couponControllerValue,
            clearOption: true,
            // enableSearch: true,
            // dropdownColor: Colors.green,
            searchDecoration: const InputDecoration(
                hintText: "enter your custom hint text here"),
            validator: (value) {
              if (value == null) {
                return "Required field";
              } else {
                return null;
              }
            },
            dropDownItemCount: _mycouponsList.length,

            dropDownList: dropDownList,
            onChanged: (val) {
              setState(() {
                print(val.name);
                _couponController = val.name;
                _disprice = val.value;
                print("Coupon: $_disprice");
              });
            },
          ),
        ),
        !_coupon_applied!
            ? Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    AppLocalizations.of(context)!.apply_coupon_all_capital,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponApply();
                  },
                ),
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: Btn.basic(
                  minWidth: MediaQuery.of(context).size.width,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  )),
                  child: Text(
                    AppLocalizations.of(context)!.remove_ucf,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponRemove();
                  },
                ),
              )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.title!,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildPaymentMethodList() {
    if (_isInitial && _paymentTypeList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_paymentTypeList.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 14,
            );
          },
          itemCount: _paymentTypeList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: buildPaymentMethodItemCard(index),
            );
          },
        ),
      );
    } else if (!_isInitial && _paymentTypeList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.no_payment_method_is_added,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  GestureDetector buildPaymentMethodItemCard(index) {
    return GestureDetector(
      onTap: () {
        onPaymentMethodItemTap(index);
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
                border: Border.all(
                    color: _selected_payment_method_key ==
                            _paymentTypeList[index].payment_type_key
                        ? MyTheme.accent_color
                        : MyTheme.light_grey,
                    width: _selected_payment_method_key ==
                            _paymentTypeList[index].payment_type_key
                        ? 2.0
                        : 0.0)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 100,
                      height: 100,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:
                              /*Image.asset(
                          _paymentTypeList[index].image,
                          fit: BoxFit.fitWidth,
                        ),*/
                              FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder.png',
                            image: _paymentTypeList[index].payment_type ==
                                    "manual_payment"
                                ? _paymentTypeList[index].image
                                : _paymentTypeList[index].image,
                            fit: BoxFit.fitWidth,
                          ))),
                  Container(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            _paymentTypeList[index].title,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: buildPaymentMethodCheckContainer(
                _selected_payment_method_key ==
                    _paymentTypeList[index].payment_type_key),
          )
        ],
      ),
    );
  }

  Widget buildPaymentMethodCheckContainer(bool check) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: check ? 1 : 0,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(Icons.check, color: Colors.white, size: 10),
        ),
      ),
    );
    /* Visibility(
      visible: check,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(Icons.check, color: Colors.white, size: 10),
        ),
      ),
    );*/
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Btn.minWidthFixHeight(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              color: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                widget.paymentFor == PaymentFor.WalletRecharge
                    ? AppLocalizations.of(context)!.recharge_wallet_ucf
                    : widget.paymentFor == PaymentFor.ManualPayment
                        ? AppLocalizations.of(context)!.proceed_all_caps
                        : widget.paymentFor == PaymentFor.PackagePay
                            ? AppLocalizations.of(context)!.buy_package_ucf
                            : AppLocalizations.of(context)!
                                .place_my_order_all_capital,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressPlaceOrderOrProceed();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget grandTotalSection() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: MyTheme.soft_accent_color),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context)!.total_amount_ucf,
                style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
              ),
            ),
            Visibility(
              visible: widget.paymentFor != PaymentFor.ManualPayment,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () {
                    // int? balance=0;
                    // print("Grandtotal: $_grandTotalValue");
                    //
                    // if(_balanceDetails!=null && _balanceDetails.balance!=0){
                    //   balance= int.parse(_balanceDetails.balance.replaceAll(RegExp(r'[^0-9]'),''));
                    // }
                    // if(balance.toDouble() > _grandTotalValue!.toDouble()){
                    // //  _grandTotalValue=balance.toInt() - _grandTotalValue!;
                    //   pay_by_wallet(_grandTotalValue);
                    //   _grandTotalValue=0;
                    // }else{
                    //   _grandTotalValue=_grandTotalValue! - balance!;
                    //   pay_by_wallet(balance);
                    // }
                    // print("Grandtotal balance: $_grandTotalValue");
                    // setState(() {
                    //
                    // });
                    onPressDetails();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.see_details_all_lower,
                    style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: deliveryResponse == null
                  ? Container()
                  : Text(
                      '${deliveryResponse!.grand_total ?? 0} ${SystemConfig.systemCurrency!.symbol}',
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context)!.please_wait_ucf}"),
            ],
          ));
        });
  }
}
