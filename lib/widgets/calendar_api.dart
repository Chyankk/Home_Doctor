import 'dart:io' show Platform;

class Secret {
  static const ANDROID_CLIENT_ID =
      "1055877063984-i57ufjf4ble0eco0ls4lni614616v3dm.apps.googleusercontent.com";
  static const IOS_CLIENT_ID =
      "1055877063984-298ph70pg09qkq1amv6pgenf5ci8hs39.apps.googleusercontent.com";
  static String getId() =>
      Platform.isAndroid ? Secret.ANDROID_CLIENT_ID : Secret.IOS_CLIENT_ID;
}
