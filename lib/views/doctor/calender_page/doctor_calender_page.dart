import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorCalenderPage extends StatefulWidget {
  @override
  _DoctorCalenderPageState createState() => _DoctorCalenderPageState();
}

class _DoctorCalenderPageState extends State<DoctorCalenderPage> {
  CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calender",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        //shrinkWrap: true,
        children: [
          TableCalendar(
            initialCalendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
                todayColor: Colors.blue,
                selectedColor: Theme.of(context).primaryColor,
                todayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.white)),
            headerStyle: HeaderStyle(
              centerHeaderTitle: true,
              formatButtonDecoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(22.0),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            builders: CalendarBuilders(
              selectedDayBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  )),
              todayDayBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(5.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            calendarController: _controller,
            onDaySelected:
                (DateTime date, List<dynamic> acb, List<dynamic> acd) =>
                    setState(() {}),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Doctors")
                  .doc(currentUserId)
                  .collection("Appointments")
                  .orderBy("appointment_time", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> query = snapshot.data.docs;
                  query.removeWhere(
                    (element) =>
                        element.data()["appointment_time"].toDate().day !=
                            _controller.selectedDay.day ||
                        element.data()["appointment_time"].toDate().month !=
                            _controller.selectedDay.month ||
                        element.data()["appointment_time"].toDate().year !=
                            _controller.selectedDay.year,
                  );
                  if (query.isEmpty) {
                    return Container();
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: query.length,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(
                      15.0,
                    ),
                    itemBuilder: (context, index) => ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DoctorAppointmentDetailPage(
                            id: snapshot.data.docs[index].id,
                          ),
                        ),
                      ),
                      title: Text(
                        query[index].data()["patient_name"],
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      subtitle: Text(
                        query[index]
                            .data()["appointment_time"]
                            .toDate()
                            .toLocal()
                            .toString(),
                      ),
                    ),
                    separatorBuilder: (context, index) => Divider(),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorAppointmentDetailPage extends StatelessWidget {
  final String id;

  const DoctorAppointmentDetailPage({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Appointment Details",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctors")
            .doc(currentUserId)
            .collection("Appointments")
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          return ListView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            shrinkWrap: true,
            padding: EdgeInsets.all(15.0),
            children: [
              ListTile(
                title: Text(
                  "Patient Name:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  snapshot.data.data()["patient_name"],
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Date:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .day
                          .toString() +
                      " " +
                      getMonth(
                        snapshot.data.data()["appointment_time"].toDate().month,
                      ) +
                      " " +
                      snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .year
                          .toString(),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Time:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  getHour(snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .hour) +
                      " : " +
                      snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .minute
                          .toString() +
                      " " +
                      getPeriod(snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .hour),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              snapshot.data.data()["meet_link"] != null &&
                      snapshot.data.data()["meet_link"].toString().isNotEmpty
                  ? ListTile(
                      onTap: () => launch(snapshot.data.data()["meet_link"]),
                      title: Text(
                        "Meet Link:",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Text(
                        snapshot.data.data()["meet_link"],
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    )
                  : Container(),
              snapshot.data.data()["meet_link"] != null &&
                      snapshot.data.data()["meet_link"].toString().isNotEmpty
                  ? Divider(
                      thickness: 1.0,
                    )
                  : Container(),
              ListTile(
                title: Text(
                  "Purpose of Visit:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  snapshot.data.data()["purpose"],
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Type of Visit:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  snapshot.data.data()["typeOfVisit"],
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Payment Method:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: _paymentMethod(
                    snapshot.data.data()["payment_method"], context),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Payment Amount:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  "₹" + snapshot.data.data()["payment_amount"].toString(),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
            ],
          );
        },
      ),
    );
  }

  String getMonth(int month) {
    switch (month) {
      case 1:
        return "Januaury";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June ";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }

  Text _paymentMethod(bool value, BuildContext context) {
    if (value == true) {
      return Text(
        "Online",
        style: Theme.of(context).textTheme.headline5,
      );
    } else {
      return Text(
        "In-Clinic",
        style: Theme.of(context).textTheme.headline5,
      );
    }
  }

  String getPeriod(int hour) {
    return hour >= 12 ? "pm" : "am";
  }

  String getHour(int hour) {
    return hour > 12 ? (hour - 12).toString() : hour.toString();
  }
}
