import 'package:flutter/material.dart';

class DeepLinkProvider with ChangeNotifier {
  String _deepLink = "";

  String get deepLink => _deepLink;

  String? get deepLinkRoute {

    // Implement logic to determine the route based on the deep link.
    // For example, parse the deep link URL and return the corresponding route.
    // if (_deepLink == "https://ethicaldigit.page.link/gap") {
    //   return '/gap';
    // } else if (_deepLink == "https://ethicaldigit.page.link/gap") {
    //   return '/home';
    // }
    // // Default route when no deep link is available
    // return '/';
    return deepLink;
  }

  set deepLink(String link) {
    _deepLink = link;
    notifyListeners();
  }
}
