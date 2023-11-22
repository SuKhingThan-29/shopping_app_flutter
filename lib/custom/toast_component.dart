import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:one_context/one_context.dart';

class ToastComponent {

  static showDialog(String msg, {duration = 0, gravity = 0}) {
    ToastContext().init(OneContext().context!);
    Toast.show(msg,
        duration: duration != 0 ? duration : Toast.lengthShort,
        gravity: gravity != 0 ? gravity : Toast.bottom,
        backgroundColor: Colors.black,
        textStyle: TextStyle(color: Colors.white),
        border: Border(
            top: BorderSide(
              color: Color.fromRGBO(203, 209, 209, 1),
            ),
            bottom: BorderSide(
              color: Color.fromRGBO(203, 209, 209, 1),
            ),
            right: BorderSide(
              color: Color.fromRGBO(203, 209, 209, 1),
            ),
            left: BorderSide(
              color: Color.fromRGBO(203, 209, 209, 1),
            )),
        backgroundRadius: 6);
  }

  static showSnackBar(BuildContext context, String msg) {
    return  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
      content: Container(
        child: Text("$msg"),
      ),
          behavior: SnackBarBehavior.floating,
        //  margin: EdgeInsets.all(10),
          elevation: 5,
        )
    );
  }
}
