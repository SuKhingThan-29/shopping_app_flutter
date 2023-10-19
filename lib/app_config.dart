var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      "@ GMP " + this_year; //this shows in the splash screen
  static String app_name = "GMP"; //this shows in the splash screen
  static String purchase_code =
      "2b9ae9c0-51fb-43d3-b8b8-c08134d7bf20"; //enter your purchase code for the app from codecanyon
  //static String purchase_code = ""; //enter your purchase code for the app from codecanyon

  //Default language config
  static String default_language = "en";
  static String mobile_app_code = "en";
  static bool app_language_rtl = false;

  //configure this
  static const bool HTTPS = true;
  static const DOMAIN_PATH = "dev.gmpshopping.com";

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "$PROTOCOL$DOMAIN_PATH";
  static const String BASE_URL = "$RAW_BASE_URL/$API_ENDPATH";
  static const String ED_URL = "https://payment-backend.ethicaldigit.com";
  static const String deliver_info = '/delivery-info';
  static const String shipping_address = '/user/shipping/address';

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}
