import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/helpers/addons_helper.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/currency_presenter.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../custom/full_screen_dialog.dart';
import 'cart.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key,deepLink=null}) : super(key: key);
  String? deepLink;

  @override
  State<SplashScreen> createState() => SplashScreenState();
}
typedef BoolCallback = bool Function();

class SplashScreenState extends State<SplashScreen> {
  int ver = 1;
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  getUserInfo() async {
    var version = await ProfileRepository().getVersion();
    print(Platform.isAndroid);
    if (Platform.isAndroid) {
      ver = version.android.mobileVersion;
      print('mobileversion $ver');
    } else {
      ver = version.ios.mobileVersion;
      print('mobileversion $ver');
    }

  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      print("version: ${_packageInfo.version}");
    });
  }

  bool isCancel = false;
  final GlobalKey<TutorialOverlayState> splashWidgetKey=GlobalKey<TutorialOverlayState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showDialogOnEnter();
    // });
    getUserInfo();
    _initPackageInfo();
    getSharedValueHelperData().then((value) {
      Future.delayed(Duration(seconds: 3)).then((value) {
        Provider.of<LocaleProvider>(context, listen: false)
            .setLocale(app_mobile_language.$!);
        print("SplashScreen: ${widget.deepLink}");
        if(widget.deepLink==null){
          _showTutorialOverlay(context);
        }
        else{
          callUpdateApp();
        }


      });
    });
  }

  bool myCallback() {
    // Your code here
    print("callback: ");
    Navigator.of(context).pop();
    callUpdateApp();
    return true; // Replace with your own boolean logic
  }

  void callUpdateApp(){
    if (ver != _packageInfo.version ) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update',
                  style:
                  TextStyle(fontSize: 15, color: MyTheme.dark_font_grey),
                ),
                Text(
                  'Are you want to update',
                  style:
                  TextStyle(fontSize: 13, color: MyTheme.dark_font_grey),
                ),
                Divider(),
                // Add your image and text row here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      child: Platform.isAndroid
                          ? Image.asset('assets/playstore.png')
                          : Image.asset('assets/appstore.png'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      Platform.isAndroid
                          ? 'Google Play Store'
                          : 'Apple App Store',
                      style: TextStyle(
                          fontSize: 13, color: MyTheme.dark_font_grey),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final url = Uri.parse(
                    Platform.isAndroid
                        ? 'https://play.google.com/store/apps/details?id=gmp.ethicaldigit.com&hl=en&gl=US'
                        : 'https://apps.apple.com/us/app/ga-mone-pwint-online/id6467404178',
                  ); // Replace with your app's package name or the link you want to open.

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        );
      });
    } Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Main(
            go_back: false,
            init_splash: false,
          );
        },
      ),
          (route) => true,
    );

  }
  void _showTutorialOverlay(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      fullscreenDialog: true,
        builder: (BuildContext context)=> TutorialOverlay(onButtonPressed:(){
      setState(() {
        print("button pressed");
        Navigator.of(context).pop();
        callUpdateApp();
      });
    },callback:myCallback)));
  }
  @override
  Widget build(BuildContext context) {
    return splashScreen();
  }

  Widget splashScreen() {
    return Container(
      width: DeviceInfo(context).height,
      height: DeviceInfo(context).height,
      color: MyTheme.splash_screen_color,
      child: InkWell(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Hero(
                tag: "backgroundImageInSplash",
                child: Container(
                  child: Image.asset("assets/app_logo.png"),
                ),
              ),
              radius: 140.0,
            ),
            Positioned.fill(
              top: DeviceInfo(context).height! / 2 - 72,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Hero(
                      tag: "splashscreenImage",
                      child: Container(
                        height: 72,
                        width: 72,
                        padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                            color: MyTheme.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: Image.asset(
                          "assets/app_logo.png",
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      AppConfig.app_name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.white),
                    ),
                  ),
                  Text(
                    "V " + _packageInfo.version,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 51.0),
                  child: Text(
                    AppConfig.copyright_text,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                    ],
                  )),
            ),*/
          ],
        ),
      ),
    );
  }

  Future<String?> getSharedValueHelperData() async {
    access_token.load().whenComplete(() {
      AuthHelper().fetch_and_set();
    });
    AddonsHelper().setAddonsData();
    BusinessSettingHelper().setBusinessSettingData();
    await app_language.load();
    await app_mobile_language.load();
    await app_language_rtl.load();
    await system_currency.load();
    Provider.of<CurrencyPresenter>(context, listen: false).fetchListData();

    print("new splash screen ${app_mobile_language.$}");
    print("new splash screen ${app_language.$}");

    print("new splash screen app_language_rtl ${app_language_rtl.$}");

    return app_mobile_language.$;
  }
}

