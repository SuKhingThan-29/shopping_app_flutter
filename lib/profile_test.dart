import 'package:flutter/material.dart';

class ProfileTest extends StatelessWidget {
  const ProfileTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text("Profile Screen")),
          body: Center(
            child: Container(
              child: Text('Profile Screen'),
            ),
          ),
        )
    );
  }
}