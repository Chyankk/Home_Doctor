import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homedoctor/views/doctor/appointment_rates/history_rates.dart';
import 'package:homedoctor/views/doctor/appointment_rates/latest_rates.dart';
import 'package:homedoctor/views/doctor/calender_page/doctor_calender_page.dart';
import 'package:homedoctor/views/doctor/feedback_page/doctor_feedback_page.dart';
import 'package:homedoctor/views/doctor/home_page/widget/app_bar_widget.dart';
import 'package:homedoctor/views/doctor/patient_page/doctor_patient_page.dart';
import 'package:homedoctor/views/doctor/profile_page/profile_page.dart';

class DoctorHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Home Doctor",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      drawer: DoctorAppBar(),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(15.0),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: <Widget>[
          CustomCardWidget(
            tileIcon: FaIcon(
              FontAwesomeIcons.addressCard,
              size: 50.0,
            ),
            tileTitle: "Profile",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DoctorProfilePage(),
              ),
            ),
          ),
          // CustomCardWidget(
          //   tileIcon: FaIcon(
          //     FontAwesomeIcons.rocketchat,
          //     size: 50.0,
          //   ),
          //   tileTitle: "Conversation",
          //   onPressed: () => Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => Doctor_Chat_List()),
          //   ),
          // ),
          CustomCardWidget(
            tileIcon: FaIcon(
              FontAwesomeIcons.users,
              size: 50.0,
            ),
            tileTitle: "Patients",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DoctorPatientPage(),
              ),
            ),
          ),
          CustomCardWidget(
            tileIcon: FaIcon(
              FontAwesomeIcons.commentAlt,
              size: 50.0,
            ),
            tileTitle: "Feedback",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DoctorFeedbackPage()),
            ),
          ),
          CustomCardWidget(
            tileIcon: FaIcon(
              FontAwesomeIcons.calendar,
              size: 50.0,
            ),
            tileTitle: "Calender",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DoctorCalenderPage()),
            ),
          ),
          CustomCardWidget(
            tileIcon: FaIcon(
              FontAwesomeIcons.wallet,
              size: 50.0,
            ),
            tileTitle: "Appointment\nRates",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReportPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Appointment Rates",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white),
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Latest",
              ),
              Tab(
                text: "History",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LatestRates(),
            HistoryRates(),
          ],
        ),
      ),
    );
  }
}

class CustomCardWidget extends StatelessWidget {
  final Widget tileIcon;
  final String tileTitle;
  final VoidCallback onPressed;

  const CustomCardWidget({
    Key key,
    @required this.tileIcon,
    @required this.tileTitle,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        elevation: 3.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            tileIcon,
            SizedBox(height: 10.0),
            Text(
              tileTitle,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
