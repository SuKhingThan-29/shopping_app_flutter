import 'dart:async';
import 'dart:io';

import 'package:active_ecommerce_flutter/custom/aiz_route.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/bottom_appbar_index.dart';
import 'package:active_ecommerce_flutter/presenter/cart_counter.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/screens/home.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/pointshop.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:one_context/one_context.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_config.dart';
import '../custom/full_screen_dialog.dart';
import '../helpers/addons_helper.dart';
import '../helpers/auth_helper.dart';
import '../helpers/business_setting_helper.dart';
import '../presenter/currency_presenter.dart';
import '../providers/locale_provider.dart';
import '../repositories/profile_repository.dart';

class Main extends StatefulWidget {
  Main({Key? key, go_back = true, this.init_splash = false}) : super(key: key);

  late bool go_back;
  late bool init_splash;


  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentIndex = 0;
  //int _cartCount = 0;

  BottomAppbarIndex bottomAppbarIndex = BottomAppbarIndex();

  CartCounter counter = CartCounter();

  var _children = [];
  int ver = 1;
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  fetchAll()async {
    getCartCount();

  }

  void onTapped(int i) {
    fetchAll();
    if (!is_logged_in.$ && (i == 2)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    // if (i == 4) {
    //   app_language_rtl.$!
    //       ? AIZRoute.slideLeft(context, Profile())
    //       : AIZRoute.slideRight(context, Profile());
    //   return;
    // }

    setState(() {
      _currentIndex = i;
      if(_currentIndex==0){
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return Main();
            }), (route) => false);
      }
    });
    //print("i$i");
  }

  getCartCount() async {
    Provider.of<CartCounter>(context, listen: false).getCount();
  }

  void initState() {
    _children = [
      Home(),
      CategoryList(
        is_base_category: true,
      ),
      CartScreen(
        has_bottomnav: true,
        from_navigation: true,
        counter: counter,
      ),
      PointShop(),
      Profile()
    ];
    fetchAll();
    // TODO: implement initState
    //re appear statusbar in case it was not there in the previous page
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    super.initState();
    getUserInfo();
    _initPackageInfo();
    if (ver != _packageInfo.version && widget.init_splash) {
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
                 _showEntertiment(context);

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
    }else{
      _showEntertiment(context);
    }



  }
  void _showEntertiment(BuildContext context){
    if(widget.init_splash){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialOverlay(context);
      });
    }
    widget.init_splash=false;

  }
  void _showTutorialOverlay(BuildContext context) {
   // Navigator.of(context).push(TutorialOverlay());
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> TutorialOverlay()));
  }

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
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        print(_currentIndex);
        if (_currentIndex != 0) {
          fetchAll();
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // CommonFunctions(context).appExitDialog();
          final shouldPop = (await OneContext().showDialog<bool>(
            builder: (BuildContext context) {
              return Directionality(
                textDirection:
                    app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
                child: AlertDialog(
                  content: Text(
                      AppLocalizations.of(context)!.do_you_want_close_the_app),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                        },
                        child: Text(AppLocalizations.of(context)!.yes_ucf)),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.no_ucf)),
                  ],
                ),
              );
            },
          ))!;
          return shouldPop;
        }
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBody: true,
          body: _children[_currentIndex],
          bottomNavigationBar: SizedBox(
            height: 90,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTapped,
              currentIndex: _currentIndex,
              backgroundColor: Colors.white.withOpacity(0.95),
              unselectedItemColor: Color.fromRGBO(168, 175, 179, 1),
              selectedItemColor: MyTheme.accent_color,
              selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: MyTheme.accent_color,
                  fontSize: 12),
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(168, 175, 179, 1),
                  fontSize: 12),
              items: [
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.asset(
                        "assets/home.png",
                        color: _currentIndex == 0
                            ? MyTheme.accent_color
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 16,
                      ),
                    ),
                    label: AppLocalizations.of(context)!.home_ucf),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.asset(
                        "assets/categories.png",
                        color: _currentIndex == 1
                            ? MyTheme.accent_color
                            : Color.fromRGBO(153, 153, 153, 1),
                        height: 16,
                      ),
                    ),
                    label: AppLocalizations.of(context)!.categories_ucf),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: badges.Badge(
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.circle,
                          badgeColor: MyTheme.accent_color,
                          borderRadius: BorderRadius.circular(10),
                          padding: EdgeInsets.all(5),
                        ),
                        badgeAnimation: badges.BadgeAnimation.slide(
                          toAnimate: false,
                        ),
                        child: Image.asset(
                          "assets/cart.png",
                          color: _currentIndex == 2
                              ? MyTheme.accent_color
                              : Color.fromRGBO(153, 153, 153, 1),
                          height: 16,
                        ),
                        badgeContent: Consumer<CartCounter>(
                          builder: (context, cart, child) {
                            return Text(
                              "${cart.cartCounter}",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                    label: AppLocalizations.of(context)!.cart_ucf),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.asset(
                      "assets/coupon.png",
                      color: _currentIndex == 3
                          ? MyTheme.accent_color
                          : Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                  label: 'Point Shop',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Image.asset(
                      "assets/profile.png",
                      color: _currentIndex == 4
                          ? MyTheme.accent_color
                          : Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.profile_ucf,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
