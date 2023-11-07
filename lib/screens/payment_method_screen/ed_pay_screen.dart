import 'dart:convert';

import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EdPayScreen extends StatefulWidget {
  String? initial_url;


  EdPayScreen(
      {Key? key,
      this.initial_url,
      })
      : super(key: key);

  @override
  _EdPayScreenScreenState createState() => _EdPayScreenScreenState();
}

class _EdPayScreenScreenState extends State<EdPayScreen> {
  WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    edPay();

  }

  edPay() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // onPageStarted: (controller) {
          //   _webViewController.loadRequest((_initial_url));
          // },
          onWebResourceError: (error) {},
          onPageFinished: (page) {
            // print("OnPageFinished: $page");
            // if (page.contains("/bkash/api/callback")) {
            //   getData();
            // } else if (page.contains("/bkash/api/fail")) {
            //   ToastComponent.showDialog("Payment cancelled",
            //       gravity: Toast.center, duration: Toast.lengthLong);
            //   Navigator.of(context).pop();
            //   return;
            // }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initial_url!));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  void getData() {
    String? payment_details = '';
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      print(data);
      if (responseJSON["result"] == false) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        payment_details = responseJSON['payment_details'];
        //onPaymentSuccess(responseJSON);
      }
    });
  }

  // onPaymentSuccess(payment_details) async {
  //   setState(() {});
  //
  //   var bkashPaymentProcessResponse =
  //   await PaymentRepository().getBkashPaymentProcessResponse(
  //     amount: widget.amount,
  //     token: _token,
  //     payment_type: widget.payment_type,
  //     combined_order_id: _combined_order_id,
  //     package_id: widget.package_id,
  //     payment_id: payment_details['paymentID'],
  //   );
  //
  //   if (bkashPaymentProcessResponse.result == false) {
  //     Toast.show(bkashPaymentProcessResponse.message!,
  //         duration: Toast.lengthLong, gravity: Toast.center);
  //     Navigator.pop(context);
  //     return;
  //   }
  //
  //   Toast.show(bkashPaymentProcessResponse.message!,
  //       duration: Toast.lengthLong, gravity: Toast.center);
  //   if (widget.payment_type == "cart_payment") {
  //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //       return OrderList(from_checkout: true);
  //     }));
  //   } else if (widget.payment_type == "wallet_payment") {
  //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //       return Wallet(from_recharge: true);
  //     }));
  //   }
  // }
  buildBody() {
    if (widget.initial_url==null) {
      return Container(
        child: Center(
          child: Text(AppLocalizations.of(context)!.fetching_paypal_url),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      );
    }
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
        AppLocalizations.of(context)!.pay_with_paypal,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
