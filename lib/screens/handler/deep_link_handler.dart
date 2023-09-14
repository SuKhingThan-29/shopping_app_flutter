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
  }
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<void> initDynamicLinks() async {

    dynamicLinks.onLink.listen((dynamicLinkData) {
      print('onLink ${dynamicLinkData.link.path}');
      print("Received dynamic link: ${dynamicLinkData.toString()}");

      Provider.of<DeepLinkProvider>(context, listen: false).deepLink = dynamicLinkData.link.path;
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
