import 'package:active_ecommerce_flutter/providers/deep_link_provider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  DeepLinkHandler({required this.child});

  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    getDynamicLinks();
  }
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final String Link = 'https://ethicaldigit.page.link/gap';

  Future<void> initDynamicLinks() async {

    dynamicLinks.onLink.listen((dynamicLinkData) {
      print('onLink ${dynamicLinkData.link.path}');

      Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }
  Future<void> getDynamicLinks() async {

    final PendingDynamicLinkData? data =
    await dynamicLinks
        .getDynamicLink(Uri.parse(Link));
    final Uri? deepLink = data?.link;
    print("Deep link data ${deepLink.toString()}");

    if (deepLink != null) {
      // ignore: unawaited_futures
        Provider.of<DeepLinkProvider>(context, listen: false).deepLink = deepLink.toString();
    }
    // final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    // final Uri? deepLink = data?.link;
    //
    // if (deepLink != null) {
    //   // Handle the deep link here.
    //   Provider.of<DeepLinkProvider>(context, listen: false).deepLink = deepLink.toString();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
