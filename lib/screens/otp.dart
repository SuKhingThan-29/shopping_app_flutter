import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:pinput/pinput.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Otp extends StatefulWidget {
  String? title;
  Otp({Key? key, this.title}) : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  TextEditingController _verificationCodeController = TextEditingController();

  String otp = "";

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    otp = "";
    _verificationCodeController.text = "";
    setState(() {});
    var resendCodeResponse = await AuthRepository().getResendCodeResponse();

    if (resendCodeResponse.result == false) {
      ToastComponent.showDialog(resendCodeResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(resendCodeResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onPressConfirm() async {
    if (otp.isEmpty || otp.length != 6) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.enter_verification_code,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    // var code = _verificationCodeController.text.toString();

    // if (code == "") {
    //   ToastComponent.showDialog(
    //       AppLocalizations.of(context)!.enter_verification_code,
    //       gravity: Toast.center,
    //       duration: Toast.lengthLong);
    //   return;
    // }

    var confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(otp);

    if (!(confirmCodeResponse.result)) {
      ToastComponent.showDialog(confirmCodeResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(confirmCodeResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return Login();
      // }));
      if (SystemConfig.systemUser != null) {
        SystemConfig.systemUser!.emailVerified = true;
      }
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Main()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              width: _screen_width * (3 / 4),
              child: Image.asset(
                  "assets/splash_login_registration_background_image.png"),
            ),
            Container(
              padding: EdgeInsets.only(top: 30),
              width: double.infinity,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // if (widget.title != null)
                  //   Text(
                  //     widget.title!,
                  //     style: TextStyle(fontSize: 25, color: MyTheme.font_grey),
                  //   ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                    child: Container(
                      width: 75,
                      height: 75,
                      child: Image.asset(
                          'assets/login_registration_form_logo.png'),
                    ),
                  ),
                  /*Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "${AppLocalizations.of(context)!.verify_your} " +
                          (_verify_by == "email"
                              ? AppLocalizations.of(context)!.email_account_ucf
                              : AppLocalizations.of(context)!.phone_number_ucf),
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                        width: _screen_width * (3 / 4),
                        child: _verify_by == "email"
                            ? Text(
                            AppLocalizations.of(context)!.enter_the_verification_code_that_sent_to_your_email_recently,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: MyTheme.dark_grey, fontSize: 14))
                            : Text(
                            AppLocalizations.of(context)!.enter_the_verification_code_that_sent_to_your_phone_recently,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: MyTheme.dark_grey, fontSize: 14))),
                  ),*/
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "Verify your phone",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    "Verification code has been sent to +95 **********12 .",
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Please wait a few minutes.",
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 30),
                  Pinput(
                    autofocus: true,
                    controller: _verificationCodeController,
                    defaultPinTheme: PinTheme(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF2B2B2B),
                        fontWeight: FontWeight.w600,
                      ),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    length: 6,
                    onChanged: (pin) {
                      otp = pin;
                      setState(() {});
                    },
                  ),

                  Container(
                    width: _screen_width * (3 / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 8.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.end,
                        //     children: [
                        //       Container(
                        //         height: 36,
                        //         child: TextField(
                        //           controller: _verificationCodeController,
                        //           autofocus: false,
                        //           decoration:
                        //               InputDecorations.buildInputDecoration_1(
                        //                   hint_text: "A X B 4 J H"),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: MyTheme.textfield_grey, width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0))),
                            child: Btn.basic(
                              minWidth: MediaQuery.of(context).size.width,
                              color: MyTheme.golden,
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                              child: Text(
                                "Verify",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                onPressConfirm();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: InkWell(
                      onTap: () {
                        onTapResend();
                      },
                      child: Text(AppLocalizations.of(context)!.resend_code_ucf,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              // decoration: TextDecoration.underline,
                              fontSize: 14)),
                    ),
                  ),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}
