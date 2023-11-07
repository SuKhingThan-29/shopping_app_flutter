import 'dart:convert';
import 'dart:io';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/google_recaptcha.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/common_webview_screen.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/otp.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';

import '../repositories/address_repository.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "email"; //phone or email
  String initialCountry = 'MM';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";
  bool? _isAgree = false;
  bool _isSignupClick=false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";

  List genders = ["Male", "Female", "Other"];
  String selectedGender = "Male";

  var countries = [];
  var states = [];
  var cities = [];

  bool countryDataLoad = false;
  String selectedCountryId = "";
  String selectedStateId = "";
  String selectedCityId = "";
  String postalCode = "";

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  TextEditingController _postalcodeController = TextEditingController();
  bool _obscureText = true;
  bool _obscureTextC = true;

  bool _isName = false;
  bool _isPhNo = false;
  bool _isPassword = false;
  bool _isConfirmPassword = false;

  @override
  void initState() {
    //check dev1
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  String? get _errorNameText {
    final text = _nameController.value.text;
    if (text.isEmpty) {
      return 'your name is empty';
    }
    _isName = false;
    return null;
  }

  String? get _errorPhoneNo {
    final text = _phoneNumberController.value.text;
    if (text.isEmpty) {
      return 'your phone number is empty';
    }
    _isPhNo = false;
    return null;
  }

  String? get _errorPassword {
    final text = _passwordController.value.text;
    final text1 = _passwordConfirmController.value.text;
    if (text.isEmpty) {
      return 'your password is empty';
    }
    if (text != text1) {
      return 'password does not match';
    }
    _isPassword = false;
    return null;
  }

  String? get _errorConfirmPassword {
    final text = _passwordConfirmController.value.text;
    final text1 = _passwordController.value.text;
    if (text.isEmpty) {
      return 'your confirm password is empty';
    }
    if (text != text1) {
      return 'password does not match';
    }
    _isConfirmPassword = false;
    return null;
  }

  void _submit() {
    setState(() {
      if (_nameController.text.toString().isEmpty) {
        _isName = true;
      } else {
        if (_phoneNumberController.text.toString().isEmpty) {
          _isPhNo = true;
        } else {
          if (_passwordController.text.toString().isEmpty) {
            _isPassword = true;
          }
          if (_passwordConfirmController.text.toString().isEmpty) {
            _isConfirmPassword = true;
          }
        }
      }
    });
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
    print("Country code: $countries_code");

    countryDataLoad = true;
    var res = await AddressRepository().getCountryList();
    res.countries.forEach((c) {
      countries.add(c);
    });
    selectedCountryId = res.countries[0].id.toString();
    fetch_state(res.countries[0].id.toString());

    setState(() {});
  }

  fetch_state(String countryId) async {
    var res =
        await AddressRepository().getStateListByCountry(country_id: countryId);
    states.clear();

    res.states.forEach((s) {
      states.add(s);
    });
    selectedStateId = res.states[0].id.toString();
    fetch_city(res.states[0].id.toString());

    setState(() {});
  }

  fetch_city(String stateId) async {
    var res = await AddressRepository().getCityListByState(state_id: stateId);
    cities.clear();
    res.cities.forEach((c) {
      cities.add(c);
    });
    selectedCityId = res.cities[0].id.toString();
    fetch_postalCode(selectedCityId);

    countryDataLoad = false;
    setState(() {});
  }

  fetch_postalCode(String cityId) async {
    var res = await AddressRepository().getPostalCodeByCidty(cityId);
    postalCode = res.data.toString();
    _postalcodeController.text = postalCode;
    setState(() {});
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  onPressedFacebookLogin() async {
    try {
      final facebookLogin = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.webOnly);

      if (facebookLogin.status == LoginStatus.success) {
        // get the user data
        // by default we get the userId, email,name and picture
        final userData = await FacebookAuth.instance.getUserData();
        print(
            "fb login..........................${userData['name'].toString()}");

        // var loginResponse = await AuthRepository().getSocialLoginResponse(
        //     "facebook",
        //     userData['name'].toString(),
        //     userData['email'].toString(),
        //     userData['id'].toString(),
        //     access_token: facebookLogin.accessToken!.token);
        //  print("..........................${loginResponse.toString()}");
        // if (loginResponse.result == false) {
        //   ToastComponent.showDialog(loginResponse.message!,
        //       gravity: Toast.center, duration: Toast.lengthLong);
        // } else {
        //   ToastComponent.showDialog(loginResponse.message!,
        //       gravity: Toast.center, duration: Toast.lengthLong);
        //
        //   AuthHelper().setUserData(loginResponse);
        //   Navigator.push(context, MaterialPageRoute(builder: (context) {
        //     return Main();
        //   }));
        //   FacebookAuth.instance.logOut();
        // }
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

      print(googleUser.toString());

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      String? accessToken = googleSignInAuthentication.accessToken;

      print("Google displayName ${googleUser.displayName}");
      print("Google email ${googleUser.email}");
      print("Google googleUser.id ${googleUser.id}");

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
        ToastComponent.showSnackBar(context, loginResponse.message!);
      } else {
        ToastComponent.showSnackBar(context, loginResponse.message!);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the ancestor widget using dependOnInheritedWidgetOfExactType.
  }

  onPressSignUp() async {
    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var passwordConfirm = _passwordConfirmController.text.toString();
    _submit();
    if (_phoneNumberController.text.isEmpty) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    } else if (postalCode == "") {
      ToastComponent.showSnackBar(
        context,
        "Please fill postal code",
      );
      return;
    } else if (password == "") {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_password,
      );
      return;
    } else if (passwordConfirm == "") {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.confirm_your_password,
      );
      return;
    } else if (password.length < 6) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!
            .password_must_contain_at_least_6_characters,
      );
      return;
    } else if (password != passwordConfirm) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.passwords_do_not_match,
      );
      return;
    }
    setState(() {
      _isSignupClick=true;
    });
    var signupResponse = await AuthRepository().getSignupResponse(
        name,
        email,
        _phone,
        password,
        passwordConfirm,
        _register_by,
        selectedGender,
        int.parse(selectedCountryId),
        int.parse(selectedStateId),
        int.parse(selectedCityId),
        int.parse(postalCode),
        googleRecaptchaKey);
    var message = signupResponse.message.toString();
    setState(() {
      _isSignupClick=false;
    });
    if (signupResponse.result == false) {
      ToastComponent.showSnackBar(
        context,
        message,
      );
    } else {
      ToastComponent.showSnackBar(
        context,
        message,
      );
      // ToastComponent.showDialog(signupResponse.message.toString(),
      //     gravity: Toast.center, duration: Toast.lengthLong);
      AuthHelper().setUserData(signupResponse);
      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;
        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return Otp(
          phnum: email.isEmpty ? _phone : email,
        );
      }), (newRoute) => false);
    }
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
                "${AppLocalizations.of(context)!.join_ucf} " +
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

  Column buildBody(BuildContext context, double _screen_width) {
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
                  AppLocalizations.of(context)!.name_ucf,
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  child: Container(
                    child: TextField(
                      controller: _nameController,
                      autofocus: false,
                      decoration: InputDecorations.buildInputDecoration_1(
                          error_text: _isName ? _errorNameText : null),
                      onChanged: (_) => setState(() {
                        _submit();
                      }),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _register_by == "email"
                      ? AppLocalizations.of(context)!.email_ucf
                      : AppLocalizations.of(context)!.phone_ucf,
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
                        controller: _emailController,
                        autofocus: false,
                        decoration: InputDecorations.buildInputDecoration_1(
                            hint_text: "johndoe@example.com"),
                      ),
                    ),
                    // GestureDetector(
                    //         onTap: () {
                    //           setState(() {
                    //             _register_by = "phone";
                    //           });
                    //         },
                    //         child: Text(
                    //           AppLocalizations.of(context)!
                    //               .or_register_with_a_phone,
                    //           style: TextStyle(
                    //               color: MyTheme.accent_color,
                    //               fontStyle: FontStyle.italic,
                    //               decoration: TextDecoration.underline),
                    //         ),
                    //       )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0, top: 10),
                child: Text(
                  AppLocalizations.of(context)!.phone_ucf,
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: MyTheme.accent_color, width: 0.5),
                        borderRadius: BorderRadius.all(
                          Radius.circular(6.0),
                        ),
                      ),
                      child: CustomInternationalPhoneNumberInput(
                        countries: countries_code,
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                          setState(() {
                            _submit();
                            _phone =
                                number.phoneNumber?.replaceFirst("+95", "");

                            print("phone : $_phone");
                          });
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                        initialValue: PhoneNumber(isoCode: "MM"),
                        textFieldController: _phoneNumberController,
                        formatInput: true,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputDecoration:
                            InputDecorations.buildInputDecoration_phone(
                          hint_text: "09 XXX XXX",
                          error_text: _isPhNo ? _errorPhoneNo : null,
                        ),
                        onSaved: (PhoneNumber number) {
                          //print('On Saved: $number');
                        },
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text:  _isPhNo ? _errorPhoneNo : null,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.red),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       _register_by = "email";
                    //     });
                    //   },
                    //   child: Text(
                    //     AppLocalizations.of(context)!
                    //         .or_register_with_an_email,
                    //     style: TextStyle(
                    //         color: MyTheme.accent_color,
                    //         fontStyle: FontStyle.italic,
                    //         decoration: TextDecoration.underline),
                    //   ),
                    // )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0, top: 10),
                child: Text(
                  "Gender",
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Row(children: [
                for (var gen in genders)
                  Row(
                    children: [
                      Radio(
                          value: gen,
                          groupValue: selectedGender,
                          onChanged: (_) {
                            selectedGender = gen;
                            setState(() {});
                          }),
                      InkWell(
                          onTap: () {
                            selectedGender = gen;
                            setState(() {});
                          },
                          child: Text(gen))
                    ],
                  )
              ]),
              SizedBox(
                height: 8,
              ),
              if (!countryDataLoad) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    "Country",
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedCountryId,
                        onChanged: (id) {
                          setState(() {
                            selectedCountryId = id!;
                            fetch_state(id);
                          });
                        },
                        items: countries.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value.id.toString(),
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    "State",
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedStateId,
                        onChanged: (id) {
                          setState(() {
                            postalCode = "";
                            selectedStateId = id!;
                            fetch_city(id);
                          });
                        },
                        items: states.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value.id.toString(),
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    "City",
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedCityId,
                        onChanged: (id) {
                          setState(() {
                            selectedCityId = id!;
                            fetch_postalCode(id);
                          });
                        },
                        items: cities.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value.id.toString(),
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: CircularProgressIndicator(),
                )
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "Postal Code",
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 36,
                  child: TextFormField(
                      //controller: TextEditingController(text: postalCode),
                      controller: _postalcodeController,
                      autofocus: false,
                      onChanged: (_) {
                        setState(() {
                          _submit();
                        });
                      },
                      decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red),
                          enabled: false,
                          hintText: "Select city")),
                ),
              ),
              SizedBox(
                height: 8,
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
                        onChanged: (_) {
                          setState(() {
                            _submit();
                          });
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red),
                          errorText: _isPassword ? _errorPassword : null,
                          hintText: _isPassword ? null : "Enter Password",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                          ),
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
                    Text(
                      AppLocalizations.of(context)!
                          .password_must_contain_at_least_6_characters,
                      style: TextStyle(
                          color: MyTheme.textfield_grey,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.retype_password_ucf,
                  style: TextStyle(
                      color: MyTheme.accent_color, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  child: TextField(
                    controller: _passwordConfirmController,
                    autofocus: false,
                    obscureText: _obscureTextC,
                    enableSuggestions: false,
                    autocorrect: false,
                    onChanged: (_) {
                      setState(() {
                        _submit();
                      });
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      errorText:
                          _isConfirmPassword ? _errorConfirmPassword : null,
                      hintText:
                          _isConfirmPassword ? null : "Enter Retype Password",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextC
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          print(_obscureTextC);
                          setState(() {
                            _obscureTextC = !_obscureTextC;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (google_recaptcha.$)
                Container(
                  height: _isCaptchaShowing ? 350 : 50,
                  width: 300,
                  child: Captcha(
                    (keyValue) {
                      googleRecaptchaKey = keyValue;
                      setState(() {});
                    },
                    handleCaptcha: (data) {
                      if (_isCaptchaShowing.toString() != data) {
                        _isCaptchaShowing = data;
                        setState(() {});
                      }
                    },
                    isIOS: Platform.isIOS,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          value: _isAgree,
                          onChanged: (newValue) {
                            _isAgree = newValue;
                            setState(() {});
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: DeviceInfo(context).width! - 140,
                        child: RichText(
                            maxLines: 2,
                            text: TextSpan(
                                style: TextStyle(
                                    color: MyTheme.font_grey, fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: "I agree to the",
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommonWebviewScreen(
                                                      page_name:
                                                          "Terms Conditions",
                                                      url:
                                                          "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                    )));
                                      },
                                    style:
                                        TextStyle(color: MyTheme.accent_color),
                                    text: " Terms Conditions",
                                  ),
                                  TextSpan(
                                    text: " &",
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommonWebviewScreen(
                                                      page_name:
                                                          "Privacy Policy",
                                                      url:
                                                          "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                    )));
                                      },
                                    text: " Privacy Policy",
                                    style:
                                        TextStyle(color: MyTheme.accent_color),
                                  )
                                ])),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  height: 45,
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6.0))),
                    child: Text(
                      AppLocalizations.of(context)!.sign_up_ucf,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isAgree! && _isSignupClick==false
                        ? () {
                            onPressSignUp();
                          }
                        : null,
                  ),
                ),
              ),
              Visibility(
                visible: allow_google_login.$ || allow_facebook_login.$,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                      child: Text(
                    "or join with",
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: allow_google_login.$,
                          child: InkWell(
                            onTap: () {
                              onPressedGoogleLogin();
                            },
                            child: Container(
                              width: 28,
                              child: Image.asset("assets/google_logo.png"),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Visibility(
                            // visible: allow_facebook_login.$,
                            visible: true,
                            child: InkWell(
                              onTap: () {
                                onPressedFacebookLogin();
                              },
                              child: Container(
                                width: 28,
                                child: Image.asset("assets/facebook_logo.png"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      AppLocalizations.of(context)!.already_have_an_account,
                      style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                    )),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Text(
                        AppLocalizations.of(context)!.log_in,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Login();
                        }));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
