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

  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      // Handle the deep link here.
      Provider.of<DeepLinkProvider>(context, listen: false).deepLink = deepLink.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
