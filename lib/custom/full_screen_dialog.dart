import 'dart:async';

import 'package:flutter/material.dart';

class TutorialOverlay extends ModalRoute<void> {
  TutorialOverlay() {
   //Schedule the overlay to automatically disappear after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(navigator!.overlay!.context).pop();
    });
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  Null get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }


  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/full_dialog.jpg'), // Replace with your image asset or network image
          fit: BoxFit.cover, // You can adjust the fit as needed
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Add your content here
          Center(),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 70,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey,

                borderRadius: BorderRadius.circular(25)
              ),

              child: Center(
                child: Text(
                  'Skip 3',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
