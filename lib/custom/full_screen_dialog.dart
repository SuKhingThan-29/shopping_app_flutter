import 'dart:async';
import 'package:flutter/material.dart';

import '../screens/main.dart';

class TutorialOverlay extends StatefulWidget {
  VoidCallback onButtonPressed;
  TutorialOverlay({required this.onButtonPressed});

  @override
  TutorialOverlayState createState() => TutorialOverlayState();
}

class TutorialOverlayState extends State<TutorialOverlay> {
  int timerCount = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    const _duration = Duration(seconds: 3);

    _timer = Timer.periodic(_duration, (Timer timer) {
      setState(() {
        timerCount--;
      });

      if (timerCount == 0) {
        // final shouldDismiss = widget.onButtonPressed(); // Invoke the callback
        // Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Main(
                go_back: false,
                init_splash: false,
              );
            },
          ),
              (route) => true,
        );
      }
      print('Duration: $timerCount');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/full_dialog.jpg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Center(),
          Positioned(
            top: 10,
            right: 30,
            child: GestureDetector(
              onTap: widget.onButtonPressed,
              child:Container(
                width: 70,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Skip $timerCount',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// class TutorialOverlay extends ModalRoute<void> {
//   @override
//   Duration get transitionDuration => Duration(milliseconds: 500);
//
//   @override
//   bool get opaque => false;
//
//   @override
//   bool get barrierDismissible => false;
//
//   @override
//   Color get barrierColor => Colors.black.withOpacity(0.5);
//
//   @override
//   Null get barrierLabel => null;
//
//   @override
//   bool get maintainState => true;
//
//   int timerCount=3;
//   Timer? _timer;
//
//   TutorialOverlay() {
//     Duration _duration=Duration(seconds: 3);
//     //Schedule the overlay to automatically disappear after 3 seconds
//     _timer=Timer.periodic(_duration, (Timer timer) {
//       setState(() {
//         timerCount--;
//       });
//
//
//       if(timerCount==0){
//
//         Navigator.of(navigator!.overlay!.context).pop();
//
//       }
//       print('Duration: $timerCount');
//
//     });
//
//   }
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//   @override
//   Widget buildPage(
//       BuildContext context,
//       Animation<double> animation,
//       Animation<double> secondaryAnimation,
//       ) {
//     // This makes sure that text and other content follows the material style
//     return Material(
//       type: MaterialType.transparency,
//       // make sure that the overlay content is not cut off
//       child: SafeArea(
//         child: _buildOverlayContent(context),
//       ),
//     );
//   }
//
//
//   Widget _buildOverlayContent(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage(
//               'assets/full_dialog.jpg'), // Replace with your image asset or network image
//           fit: BoxFit.cover, // You can adjust the fit as needed
//         ),
//       ),
//       child: Stack(
//         children: <Widget>[
//           // Add your content here
//           Center(),
//           Positioned(
//             top: 10,
//             right: 10,
//             child: Container(
//               width: 70,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//
//                 borderRadius: BorderRadius.circular(25)
//               ),
//
//               child: Center(
//                 child: Text(
//                   'Skip $timerCount',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget buildTransitions(
//       BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
//     // You can add your own animations for the overlay content
//     return FadeTransition(
//       opacity: animation,
//       child: ScaleTransition(
//         scale: animation,
//         child: child,
//       ),
//     );
//   }
// }
