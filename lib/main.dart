import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:homedoctor/themes/themes.dart';
import 'package:homedoctor/views/common_pages/splash_screen/splash_screen.dart';
import 'package:homedoctor/widgets/calendar_api.dart';
import 'package:homedoctor/widgets/calendar_client.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    await Firebase.initializeApp();
    var _clientID = new ClientId(Secret.getId(), "");
    const _scopes = const [cal.CalendarApi.calendarScope];
    await clientViaUserConsent(_clientID, _scopes, prompt).then(
      (AuthClient client) async {
        CalendarClient.calendar = cal.CalendarApi(client);
      },
    );
    runApp(MyApp());
  });
}

void prompt(String url) async {
  // if (await canLaunch(url)) {
  //   await launch(url);
  // } else {
  //   throw 'Could not launch $url';
  // }
  await launch(url, forceSafariVC: true);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Home Doctor",
      theme: Themes.lightTheme,
      themeMode: ThemeMode.light,
      home: SplashPage(),
    );
  }
}
