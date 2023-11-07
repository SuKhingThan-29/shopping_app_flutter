// To parse this JSON data, do
//
//     final version = versionFromJson(jsonString);

import 'dart:convert';

Version versionFromJson(String str) => Version.fromJson(json.decode(str));

String versionToJson(Version data) => json.encode(data.toJson());

class Version {
  bool success;
  Android ios;
  Android android;

  Version({
    required this.success,
    required this.ios,
    required this.android,
  });

  factory Version.fromJson(Map<String, dynamic> json) => Version(
        success: json["success"],
        ios: Android.fromJson(json["ios"]),
        android: Android.fromJson(json["android"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "ios": ios.toJson(),
        "android": android.toJson(),
      };
}

class Android {
  String title;
  String message;
  int mobileVersion;
  dynamic playStoreLink;
  dynamic appStoreLink;

  Android({
    required this.title,
    required this.message,
    required this.mobileVersion,
    this.playStoreLink,
    this.appStoreLink,
  });

  factory Android.fromJson(Map<String, dynamic> json) => Android(
        title: json["title"],
        message: json["message"],
        mobileVersion: json["mobile_version"],
        playStoreLink: json["play_store_link"],
        appStoreLink: json["app_store_link"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "message": message,
        "mobile_version": mobileVersion,
        "play_store_link": playStoreLink,
        "app_store_link": appStoreLink,
      };
}
