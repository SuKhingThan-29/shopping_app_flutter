import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstamojoScreen extends StatefulWidget {
  double? amount;
  String payment_type;
  String? payment_method_key;
  var package_id;
  InstamojoScreen(
      {Key? key,
      this.amount = 0.00,
      this.payment_type = "",
      this.package_id = "0",
      this.payment_method_key = ""})
      : super(key: key);

  @override
  _InstamojoScreenState createState() => _InstamojoScreenState();
}

class _InstamojoScreenState extends State<InstamojoScreen> {
  int? _combined_order_id = 0;
  bool _order_init = false;

  WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pay();
    // print(widget.payment_type);
    //
    // if (widget.payment_type == "cart_payment") {
    //   createOrder();
    // }else{
    //
    // razorpay();
    // }
  }

  pay() async {
    // Map<String,String> headers =Map.of({
    //   "Accept": "*/*",
    //   "Connection": "keep-alive",
    //   "Authorization": "Bearer ${access_token.$}",
    //   "App-Language": app_language.$!,
    //   "Content-Type":"multipart/form-data; boundary=<calculated when request is sent>"
    // });
    var headers = {
      "Accept": "*/*",
      "Connection": "keep-alive",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      // "Content-Type":"multipart/form-data; boundary=<calculated when request is sent>"
    };

    var body = jsonDecode('''{
      "payment_option":"instamojo_payment",
      "additional_info":"nai"
    }
   ''');

    String initial_url = "${AppConfig.BASE_URL}/test-payment";

    var req = http.MultipartRequest("POST", Uri.parse(initial_url));
    req.fields.addAll(
        {"payment_option": "instamojo_payment", "additional_info": "nai"});

    req.headers.addAll(headers);

    var rr = await req.send();

    var response = await rr.stream.bytesToString();

    //var response = await http.post(Uri.parse("${AppConfig.BASE_URL}/test-payment"),headers:headers );

    print(response);
    // print(initial_url);
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // onPageStarted: (controller) {
          //   _webViewController.loadRequest(Uri.parse(initial_url));
          // },
          onWebResourceError: (error) {},
          onPageStarted: (page) {
            print("start $page");
          },
          onPageFinished: (page) {
            print(page.toString());
            // getData();
          },
        ),
      )
      // ..loadRequest(Uri.parse(initial_url),
      //     headers: headers,
      //
      //  body:Uint8List.fromList(utf8.encode('{"payment_option":"instamojo_payment"}')),
      //     method: LoadRequestMethod.post,
      // )
      ..loadHtmlString(response);
  }

  String html(url) {
    print(url);
    return '''
<!DOCTYPE html>
<html>
  <body>
    <div id="wrap">
    <form action="${AppConfig.BASE_URL}/test-payment",method="POST">
      <input type="hidden" id="fname" name="fname" value="John">
      <input type="hidden" id="fname" name="fname" value="John">
      <input type="hidden" id="fname" name="fname" value="John">
      <input type="hidden" id="fname" name="fname" value="John">
      <input type="hidden" id="fname" name="fname" value="John">
    </form> 
    </div>
  </body>
</html>
    ''';
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});

    //razorpay();
    // print("-----------");

    // print(_combined_order_id);
    // print(user_id.$);
    // print(widget.amount);
    // print(widget.payment_method_key);
    // print(widget.payment_type);
    // print("-----------");
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  void getData() {
    print('called.........');
    String? payment_details = '';

    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      // var decodedJSON = jsonDecode(data);
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      //print(responseJSON.toString());
      if (responseJSON["result"] == false) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);

        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        print("a");
        payment_details = responseJSON['payment_details'];
        onPaymentSuccess(payment_details);
      }
    });
  }

  onPaymentSuccess(payment_details) async {
    print("b");

    var razorpayPaymentSuccessResponse = await PaymentRepository()
        .getRazorpayPaymentSuccessResponse(widget.payment_type, widget.amount,
            _combined_order_id, payment_details);

    if (razorpayPaymentSuccessResponse.result == false) {
      print("c");
      Toast.show(razorpayPaymentSuccessResponse.message!,
          duration: Toast.lengthLong, gravity: Toast.center);
      Navigator.pop(context);
      return;
    }

    Toast.show(razorpayPaymentSuccessResponse.message!,
        duration: Toast.lengthLong, gravity: Toast.center);
    if (widget.payment_type == "cart_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OrderList(from_checkout: true);
      }));

      /*OneContext().push(MaterialPageRoute(builder: (_) {
        return OrderList(from_checkout: true);
      }));*/
    } else if (widget.payment_type == "wallet_payment") {
      print("d");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Wallet(from_recharge: true);
      }));
    }
  }

  buildBody() {
    if (false
        //_order_init == false &&
        //_combined_order_id == 0 &&
        // widget.payment_type == "cart_payment"
        ) {
      return Container(
        child: Center(
          child: Text(AppLocalizations.of(context)!.creating_order),
        ),
      );
    } else {
      return SizedBox.expand(
        child: Container(
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
        AppLocalizations.of(context)!.pay_with_instamojo,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
