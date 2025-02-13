import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/otp.dart';
import 'package:active_ecommerce_flutter/screens/password_forget.dart';
import 'package:active_ecommerce_flutter/screens/registration.dart';
import 'package:active_ecommerce_flutter/social_config.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';
import 'package:twitter_login/twitter_login.dart';

import '../repositories/address_repository.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";
  bool isLoginClick = false;

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    _passwordController.dispose();
    super.dispose();
  }

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enter_email),
          duration: Duration(seconds: 3), // Set the duration as needed
          behavior: SnackBarBehavior
              .floating, // Use SnackBarBehavior.floating to center the snackbar
        ),
      );
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    } else if (password == "") {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_password,
      );
      return;
    }
    setState(() {
      isLoginClick = true;
    });
    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);

    if (loginResponse.result == true) {
      AuthHelper().setUserData(loginResponse);
      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {}

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return Main();
      }), (newRoute) => false);
    } else if (loginResponse.result == false &&
        loginResponse.message == 'Please verify your account') {
      AuthHelper().setUserData(loginResponse);
      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {}

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return Main();
      }), (newRoute) => false);
    } else {
      ToastComponent.showSnackBar(
        context,
        loginResponse.message.toString(),
      );
    }
    ToastComponent.showSnackBar(
      context,
      loginResponse.message.toString(),
    );
    setState(() {
      isLoginClick = false;
    });
  }

  onPressedFacebookLogin() async {
    try {
      final facebookLogin = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.webOnly);

      if (facebookLogin.status == LoginStatus.success) {
        // get the user data
        // by default we get the userId, email,name and picture
        final userData = await FacebookAuth.instance.getUserData();
        var loginResponse = await AuthRepository().getSocialLoginResponse(
            "facebook",
            userData['name'].toString(),
            userData['email'].toString(),
            userData['id'].toString(),
            access_token: facebookLogin.accessToken!.token);
        print("..........................${loginResponse.toString()}");
        if (loginResponse.result == false) {
          ToastComponent.showSnackBar(
            context,
            loginResponse.message!,
          );
        } else {
          ToastComponent.showSnackBar(
            context,
            loginResponse.message!,
          );

          AuthHelper().setUserData(loginResponse);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Main();
          }));
          FacebookAuth.instance.logOut();
        }
        // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      } else {
        print("....Facebook auth Failed.........");
        print(facebookLogin.status);
        print(facebookLogin.message);
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }
  }

  onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      String? accessToken = googleSignInAuthentication.accessToken;
      //
      // print("Google displayName ${googleUser.displayName}");
      // print("Google email ${googleUser.email}");
      // print("Google googleUser.id ${googleUser.id}");

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "google", googleUser.displayName, googleUser.email, googleUser.id,
          access_token: accessToken);

      if (loginResponse.result == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResponse.message!),
            duration: Duration(seconds: 3), // Set the duration as needed
            behavior: SnackBarBehavior
                .floating, // Use SnackBarBehavior.floating to center the snackbar
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResponse.message!),
            duration: Duration(seconds: 3), // Set the duration as needed
            behavior: SnackBarBehavior
                .floating, // Use SnackBarBehavior.floating to center the snackbar
          ),
        );
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("Google error is ....... $e");
      // TODO
    }
  }

  onPressedTwitterLogin() async {
    try {
      final twitterLogin = new TwitterLogin(
          apiKey: SocialConfig().twitter_consumer_key,
          apiSecretKey: SocialConfig().twitter_consumer_secret,
          redirectURI: 'activeecommerceflutterapp://');
      // Trigger the sign-in flow

      final authResult = await twitterLogin.login();

      print("authResult");

      // print(json.encode(authResult));

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "twitter",
          authResult.user!.name,
          authResult.user!.email,
          authResult.user!.id.toString(),
          access_token: authResult.authToken,
          secret_token: authResult.authTokenSecret);

      if (loginResponse.result == false) {
        ToastComponent.showSnackBar(
          context,
          loginResponse.message!,
        );
      } else {
        ToastComponent.showSnackBar(
          context,
          loginResponse.message!,
        );
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "apple",
          appleCredential.givenName,
          appleCredential.email,
          appleCredential.userIdentifier,
          access_token: appleCredential.identityToken);

      if (loginResponse.result == false) {
        ToastComponent.showSnackBar(
          context,
          loginResponse.message!,
        );
      } else {
        ToastComponent.showSnackBar(
          context,
          loginResponse.message!,
        );
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    // final oauthCredential = OAuthProvider("apple.com").credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //print(oauthCredential.accessToken);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return Main();
        }), (reute) => false);
        return Future<bool>.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            AuthScreen.buildScreen(
                context,
                "${AppLocalizations.of(context)!.login_to} " +
                    AppConfig.app_name,
                buildBody(context, _screen_width)),
            Positioned(
              top: 20, // Adjust the top position as needed
              left: 10, // Adjust the left position as needed
              child: Container(
                decoration: BoxDecoration(// Background color for the icon
                    ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white, // Icon color
                  ),
                  onPressed: () {
                    // Add your back button logic here
                    // Typically, you would use Navigator to pop the current screen.
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Main();
                    }));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _login_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.login_screen_phone,
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              if (_login_by == "email")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(
                              hint_text: "johndoe@example.com"),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _login_by = "phone";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.or_login_with_a_phone,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.accent_color, width: 0.5),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                        ),
                        child: CustomInternationalPhoneNumberInput(
                          countries: countries_code,
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            setState(() {
                              _phone = number.phoneNumber;
                            });
                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          // selectorConfig: SelectorConfig(
                          //   selectorType: PhoneInputSelectorType.DIALOG,
                          // ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle:
                              TextStyle(color: MyTheme.font_grey),
                          textStyle: TextStyle(color: MyTheme.font_grey),
                          // initialValue: PhoneNumber(
                          //     isoCode: countries_code[0].toString()),
                          textFieldController: _phoneNumberController,
                          formatInput: true,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputDecoration:
                              InputDecorations.buildInputDecoration_phone(
                                  hint_text: "09XXX XXX XXX"),
                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _login_by = "email";
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context)!.or_login_with_an_email,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.password_ucf,
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: TextField(
                        controller: _passwordController,
                        autofocus: false,
                        obscureText: _obscureText,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          // hintText: "• • • • • • • •",
                          hintText: "Enter Password",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyTheme.accent_color, width: 0.2),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(6.0),
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyTheme.accent_color, width: 0.5),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(6.0),
                            ),
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 14),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              print(_obscureText);
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return PasswordForget();
                        }));
                      },
                      child: Text(
                        AppLocalizations.of(context)!
                            .login_screen_forgot_password,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: MyTheme.textfield_grey, width: 1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0))),
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6.0))),
                    child: Text(
                      AppLocalizations.of(context)!.login_screen_log_in,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: isLoginClick == true
                        ? null
                        : () {
                            onPressedLogin();
                          },
                  ),
                ),
              ),
              if (Platform.isIOS)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SignInWithAppleButton(
                    onPressed: () async {
                      signInWithApple();
                    },
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              allow_google_login.$
                  ? Container(
                      height: 45,
                      child: Btn.minWidthFixHeight(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 50,
                        color: MyTheme.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6.0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: allow_google_login.$,
                              child: Container(
                                width: 28,
                                child: Image.asset("assets/google_logo.png"),
                              ),
                            ),
                            Visibility(
                              visible: allow_google_login.$ ||
                                  allow_facebook_login.$,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Center(
                                    child: Text(
                                  '  Sign in with Google',
                                  style: TextStyle(
                                      color: MyTheme.font_grey, fontSize: 12),
                                )),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          onPressedGoogleLogin();
                        },
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 10,
              ),
              allow_facebook_login.$
                  ? Container(
                      height: 45,
                      child: Btn.minWidthFixHeight(
                        minWidth: MediaQuery.of(context).size.width,
                        height: 50,
                        color: MyTheme.amber,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6.0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: allow_google_login.$,
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 28,
                                  child:
                                      Image.asset("assets/facebook_logo.png"),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: allow_facebook_login.$,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Center(
                                    child: Text(
                                  '  Sign in with Facebook',
                                  style: TextStyle(
                                      color: MyTheme.font_grey, fontSize: 12),
                                )),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          onPressedFacebookLogin();
                        },
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!
                      .login_screen_or_create_new_account,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                )),
              ),
              Container(
                height: 45,
                child: Btn.minWidthFixHeight(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 50,
                  color: MyTheme.amber,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(6.0))),
                  child: Text(
                    AppLocalizations.of(context)!.login_screen_sign_up,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Registration();
                    }));
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
