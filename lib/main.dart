
import 'dart:io';

import 'package:active_ecommerce_flutter/firebase_options.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/presenter/currency_presenter.dart';
import 'package:active_ecommerce_flutter/providers/deep_link_provider.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/address.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/screens/digital_product/digital_products.dart';
import 'package:active_ecommerce_flutter/screens/handler/deep_link_handler.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_value/shared_value.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'app_config.dart';
import 'package:one_context/one_context.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:active_ecommerce_flutter/providers/locale_provider.dart';
import 'helpers/addons_helper.dart';
import 'helpers/auth_helper.dart';
import 'helpers/business_setting_helper.dart';
import 'helpers/shared_value_helper.dart';
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;

  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          subtitle: notification.title
        ),
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
  print("PushNoti mess: ${notification!.title}");
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  runApp(
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}
class _MainScreenState extends State<MyApp> {
  String? initialMessage;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int ver = 1;
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
          initialMessage = value?.data.toString();
          print('PushNoti: $initialMessage');

            },
      ),
    );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('PushNoti onMessageOpened: $message');

    });

  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (context) => CartCounter()),
          ChangeNotifierProvider(create: (context) => CurrencyPresenter()),
          ChangeNotifierProvider(create: (context) => DeepLinkProvider()),
        ],
        child: DeepLinkHandler(
          child: Consumer<DeepLinkProvider>(
              builder: (context, provider, snapshot) {
            print("Deeplink route provider: ${provider.deepLinkRoute}");
            if (provider.deepLinkRoute == "/purchase-history") {

              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (context) {
                  return OrderList(from_checkout: true);
                },
              ));

            }else if(provider.deepLinkRoute == "/wallet-recharge"){
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (context) {
                  return Wallet();
                },
              ));
            }
            return MaterialApp(
              navigatorKey: navigatorKey,
              initialRoute: provider.deepLinkRoute ?? '/',
              routes: {
                '/': (BuildContext context) => SplashScreen(),
                "/purchase-history": (BuildContext context) => OrderList(from_checkout: true),
                "/classified_ads": (context) => ClassifiedAds(),
                "/classified_ads_details": (context) =>
                    ClassifiedAdsDetails(id: 0),
                "/my_classified_ads": (context) => MyClassifiedAds(),
                "/digital_product_details": (context) => DigitalProductDetails(
                      id: 0,
                    ),
                "/digital_products": (context) => DigitalProducts(),
                "/purchased_digital_products": (context) =>
                    PurchasedDigitalProducts(),
                "/update_package": (context) => UpdatePackage(),
                "/address": (context) => Address(),
                "/auction_products": (context) => AuctionProducts(),
                "/auction_products_details": (context) =>
                    AuctionProductsDetails(id: 0),
                "/brand_products": (context) =>
                    BrandProducts(id: 0, brand_name: ""),
                "/cart": (context) => CartScreen(),
                "/category_list": (context) => CategoryList(
                    parent_category_id: 0,
                    is_base_category: true,
                    parent_category_name: "",
                    is_top_category: false),
                "/category_products": (context) =>
                    CategoryProducts(category_id: 0, category_name: ""),
                "/chat": (context) => Chat(),
                "/checkout": (context) => Checkout(),
                "/clubpoint": (context) => Clubpoint(),
                "/flash_deal_list": (context) => FlashDealList(),
                "/flash_deal_products": (context) => FlashDealProducts(),
                "/home": (context) => Home(),
                "/login": (context) => Login(),
                "/main": (context) => Main(),
                "/map_location": (context) => MapLocation(),
                "/messenger_list": (context) => MessengerList(),
                "/order_details": (context) => OrderDetails(),
                "/order_list": (context) => OrderList(),
                "/product_details": (context) => ProductDetails(
                      id: 0,
                    ),
                "/product_reviews": (context) => ProductReviews(
                      id: 0,
                    ),
                "/profile": (context) => Profile(),
                "/refund_request": (context) => RefundRequest(),
                "/seller_details": (context) => SellerDetails(
                      id: 0,
                    ),
                "/seller_products": (context) => SellerProducts(),
                "/todays_deal_products": (context) => TodaysDealProducts(),
                "/top_selling_products": (context) => TopSellingProducts(),
                "/wallet": (context) => Wallet(),
              },
              builder: OneContext().builder,
              // navigatorKey: OneContext().navigator.key,
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
                  bodyLarge:
                      GoogleFonts.publicSans(textStyle: textTheme.bodyLarge),
                  bodyMedium: GoogleFonts.publicSans(
                      textStyle: textTheme.bodyMedium, fontSize: 12),
                ),
              ),
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
              ],
              //locale: provider.locale,
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
          }),
        ));
  }
}



