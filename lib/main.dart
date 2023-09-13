import 'package:active_ecommerce_flutter/firebase_options.dart';
import 'package:active_ecommerce_flutter/helpers/addons_helper.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/presenter/currency_presenter.dart';
import 'package:active_ecommerce_flutter/presenter/home_presenter.dart';
import 'package:active_ecommerce_flutter/profile_test.dart';
import 'package:active_ecommerce_flutter/screens/address.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/screens/digital_product/digital_products.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/map_location.dart';
import 'package:active_ecommerce_flutter/screens/messenger_list.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/product_reviews.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:active_ecommerce_flutter/screens/refund_request.dart';
import 'package:active_ecommerce_flutter/screens/splash_screen.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_selling_products.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/splash.dart';
import 'package:shared_value/shared_value.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'dart:async';
import 'app_config.dart';
import 'package:active_ecommerce_flutter/services/push_notification_service.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'lang_config.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/auction_products.dart';
import 'screens/auction_products_details.dart';
import 'screens/brand_products.dart';
import 'screens/category_products.dart';
import 'screens/chat.dart';
import 'screens/checkout.dart';
import 'screens/classified_ads/classified_ads.dart';
import 'screens/classified_ads/classified_product_details.dart';
import 'screens/classified_ads/my_classified_ads.dart';
import 'screens/club_point.dart';
import 'screens/digital_product/digital_product_details.dart';
import 'screens/digital_product/purchased_digital_produts.dart';
import 'screens/flash_deal_list.dart';
import 'screens/flash_deal_products.dart';
import 'screens/home.dart';
import 'screens/package/packages.dart';
import 'screens/product_details.dart';
import 'screens/seller_details.dart';
import 'screens/seller_products.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterDownloader.initialize(
      debug: true,
      // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // AddonsHelper().setAddonsData();
  // BusinessSettingHelper().setBusinessSettingData();
  // app_language.load();
  // app_mobile_language.load();
  // app_language_rtl.load();
  //
  // access_token.load().whenComplete(() {
  //   AuthHelper().fetch_and_set();
  // });

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(
    SharedValue.wrapApp(
      MyApp(),
    ),
  );

  //   runApp(GetMaterialApp(
  //   routes: {
  //     //For Deep Link
  //     '/profiles': (BuildContext context) =>
  //     const ProfileTest()
  //   },
  //
  //   debugShowCheckedModeBanner: false,
  //   theme: ThemeData(
  //     primarySwatch: Colors.deepPurple,
  //   ),
  //   title: 'Better player demo',
  //   home:  SplashScreen(),
  // ));

}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  //  initDynamicLinks();

    Future.delayed(Duration.zero).then(
      (value) async {
        Firebase.initializeApp().then((value) {
          if (OtherConfig.USE_PUSH_NOTIFICATION) {
            Future.delayed(Duration(milliseconds: 10), () async {
              PushNotificationService().initialise();
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // FirebaseDynamicLinks.instance.onLink(
    //     onSuccess: (PendingDynamicLinkData dynamicLink) async {
    //       final Uri deepLink = dynamicLink?.link;
    //
    //       // Handle the deep link and navigate to the appropriate screen
    //       if (deepLink != null) {
    //         // Extract information from the deep link, if needed
    //          String path = deepLink.path;
    //
    //         // Use your Provider to handle the navigation
    //         // context.read<YourProvider>().handleDeepLink(path);
    //       }
    //     }, onError: (OnLinkErrorException e) async {
    //   print('onLinkError');
    //   print(e.message);
    // });
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (context) => CartCounter()),
          ChangeNotifierProvider(create: (context) => CurrencyPresenter()),
           // ChangeNotifierProvider(create: (context) => HomePresenter())
        ],
        child: Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
          return MaterialApp(
            initialRoute: "/",
            routes:
              {
                "/":(context)=>SplashScreen(),
                "/classified_ads":(context)=>ClassifiedAds(),
                "/classified_ads_details":(context)=>ClassifiedAdsDetails(id:0),
                "/my_classified_ads":(context)=>MyClassifiedAds(),
                "/digital_product_details":(context)=>DigitalProductDetails(id: 0,),
                "/digital_products":(context)=>DigitalProducts(),
                "/purchased_digital_products":(context)=>PurchasedDigitalProducts(),
                "/update_package":(context)=>UpdatePackage(),
                "/address":(context)=>Address(),
                "/auction_products":(context)=>AuctionProducts(),
                "/auction_products_details":(context)=>AuctionProductsDetails(id: 0),
                "/brand_products":(context)=>BrandProducts(id: 0,brand_name: ""),
                "/cart":(context)=>Cart(),
                "/category_list":(context)=>CategoryList(parent_category_id: 0,is_base_category: true,parent_category_name: "",is_top_category: false),
                "/category_products":(context)=>CategoryProducts(category_id: 0,category_name: ""),
                "/chat":(context)=>Chat(),
                "/checkout":(context)=>Checkout(),
                "/clubpoint":(context)=>Clubpoint(),
                "/flash_deal_list":(context)=>FlashDealList(),
                "/flash_deal_products":(context)=>FlashDealProducts(),
                "/home":(context)=>Home(),
                "/login":(context)=>Login(),
                "/main":(context)=>Main(),
                "/map_location":(context)=>MapLocation(),
                "/messenger_list":(context)=>MessengerList(),
                "/order_details":(context)=>OrderDetails(),
                "/order_list":(context)=>OrderList(),
                "/product_details":(context)=>ProductDetails(id: 0,),
                "/product_reviews":(context)=>ProductReviews(id: 0,),
                "/profile":(context)=>Profile(),
                "/refund_request":(context)=>RefundRequest(),
                "/seller_details":(context)=>SellerDetails(id: 0,),
                "/seller_products":(context)=>SellerProducts(),
                "/todays_deal_products":(context)=>TodaysDealProducts(),
                "/top_selling_products":(context)=>TopSellingProducts(),
                "/wallet":(context)=>Wallet(),

              },
            builder: OneContext().builder,
            navigatorKey: OneContext().navigator.key,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              scaffoldBackgroundColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              /*textTheme: TextTheme(
              bodyText1: TextStyle(),
              bodyText2: TextStyle(fontSize: 12.0),
            )*/
              //
              // the below code is getting fonts from http
              textTheme: GoogleFonts.publicSansTextTheme(textTheme).copyWith(
                bodyText1:
                    GoogleFonts.publicSans(textStyle: textTheme.bodyText1),
                bodyText2: GoogleFonts.publicSans(
                    textStyle: textTheme.bodyText2, fontSize: 12),
              ),
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: LangConfig().supportedLocales(),
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (AppLocalizations.delegate.isSupported(deviceLocale!)) {
                return deviceLocale;
              }
              return const Locale('en');
            },
            //home: SplashScreen(),
            // home: Splash(),
          );
        }));
  }
}



// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'dart:async';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'firebase_options.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//
//   runApp(GetMaterialApp(
//     routes: {
//       //For Deep Link
//       '/profiles': (BuildContext context) =>
//       const ProfileTest()
//     },
//
//     debugShowCheckedModeBanner: false,
//     theme: ThemeData(
//       primarySwatch: Colors.deepPurple,
//     ),
//     title: 'Better player demo',
//     home:  _MainScreen(),
//   ));
// }
//
class _MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  String? _linkMessage;
  bool _isCreatingLink = false;

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final String _testString =
      'To test: long press link and then copy and click from a non-browser '
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      'is properly setup. Look at firebase_dynamic_links/README.md for more '
      'details.';

  final String DynamicLink = 'https://www.google.com?screen=/orderDetail';
  final String Link = 'https://ethicaldigit.page.link';

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      print("Deeplink path: ${dynamicLinkData.link.path}");
      Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://flutterfiretests.page.link',
      longDynamicLink: Uri.parse(
        'https://flutterfiretests.page.link?efr=0&ibi=io.flutter.plugins.firebase.dynamiclinksexample&apn=io.flutter.plugins.firebase.dynamiclinksexample&imv=0&amv=0&link=https%3A%2F%2Fexample%2Fhelloworld&ofl=https://ofl-example.com',
      ),
      link: Uri.parse(DynamicLink),
      androidParameters: const AndroidParameters(
        packageName: 'io.flutter.plugins.firebase.dynamiclinksexample',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'io.flutter.plugins.firebase.dynamiclinksexample',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Links Example'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          final PendingDynamicLinkData? data =
                          await dynamicLinks.getInitialLink();
                          final Uri? deepLink = data?.link;

                          if (deepLink != null) {
                            // ignore: unawaited_futures
                            Navigator.pushNamed(context, deepLink.path);
                          }
                        },
                        child: const Text('getInitialLink'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final PendingDynamicLinkData? data =
                          await dynamicLinks
                              .getDynamicLink(Uri.parse(Link));
                          final Uri? deepLink = data?.link;
                          print("Deep link order: ${deepLink!.path}");

                          if (deepLink != null) {
                            // ignore: unawaited_futures

                            Navigator.pushNamed(context, deepLink.path);
                          }
                        },
                        child: const Text('getDynamicLink'),
                      ),
                      ElevatedButton(
                        onPressed: !_isCreatingLink
                            ? () => _createDynamicLink(false)
                            : null,
                        child: const Text('Get Long Link'),
                      ),
                      ElevatedButton(
                        onPressed: !_isCreatingLink
                            ? () => _createDynamicLink(true)
                            : null,
                        child: const Text('Get Short Link'),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      if (_linkMessage != null) {
                      //  await launchUrl(Uri.parse(_linkMessage!));
                      }
                    },
                    onLongPress: () {
                      if (_linkMessage != null) {
                        Clipboard.setData(ClipboardData(text: _linkMessage!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied Link!')),
                        );
                      }
                    },
                    child: Text(
                      _linkMessage ?? '',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  Text(_linkMessage == null ? '' : _testString)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World DeepLink'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
