import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/widgets/calendar_client.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientAppointmentTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Appointments",
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: Colors.white,
                ),
          ),
          centerTitle: true,
          bottom: TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            labelStyle: Theme.of(context).textTheme.subtitle1,
            isScrollable: false,
            tabs: [
              Tab(
                child: Text(
                  "Upcoming",
                  // style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Tab(
                child: Text(
                  "Past",
                  // style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            PatientUpcomingAppointmentsPage(),
            PatientPastAppoitmentsPage(),
          ],
        ),
      ),
    );
  }
}

class PatientPastAppoitmentsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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
      default:
        return "April";
    }
  }

  String getPeriod(int hour) {
    return hour >= 12 ? "pm" : "am";
  }

  String getHour(int hour) {
    return hour > 12 ? (hour - 12).toString() : hour.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Patients")
              .doc(currentUserId)
              .collection("Appointments")
              .orderBy("appointment_time", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                List<QueryDocumentSnapshot> query = snapshot.data.docs;
                query.removeWhere(
                  (element) => element
                      .data()["appointment_time"]
                      .toDate()
                      .isAfter(DateTime.now()),
                );
                if (query.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _NoDataWidget(),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(10.0),
                  shrinkWrap: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: query.length,
                  separatorBuilder: (context, index) => SizedBox(
                    height: 9.0,
                  ),
                  itemBuilder: (context, index) {
                    print(query[index]["event_Id"]);
                    return Card(
                      child: ListTile(
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => _AppointmentDetailPage(
                                      id: query[index].id,
                                    ))),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. " + query[index].data()["doctor_name"] ??
                                  "Doctor Name",
                              softWrap: true,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Text(
                              query[index]["doctor_clinic"] ?? "Clinic Name",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              query[index]
                                      .data()["appointment_time"]
                                      .toDate()
                                      .day
                                      .toString() +
                                  " " +
                                  getMonth(query[index]
                                      .data()["appointment_time"]
                                      .toDate()
                                      .month) +
                                  " " +
                                  query[index]
                                      .data()["appointment_time"]
                                      .toDate()
                                      .year
                                      .toString(),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              getHour(query[index]
                                      .data()["appointment_time"]
                                      .toDate()
                                      .hour) +
                                  ":" +
                                  query[index]
                                      .data()["appointment_time"]
                                      .toDate()
                                      .minute
                                      .toString() +
                                  " " +
                                  getPeriod(query[index]
                                      .data()["appointment_time"]
                                      .toDate()
                                      .hour),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class PatientUpcomingAppointmentsPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Patients")
              .doc(currentUserId)
              .collection("Appointments")
              .orderBy("appointment_time", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                List<QueryDocumentSnapshot> query = snapshot.data.docs;
                query.removeWhere(
                  (element) => element
                      .data()["appointment_time"]
                      .toDate()
                      .isBefore(DateTime.now()),
                );
                if (query.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _NoDataWidget(),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(10.0),
                  shrinkWrap: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: query.length,
                  separatorBuilder: (context, index) => SizedBox(
                    height: 9.0,
                  ),
                  itemBuilder: (context, index) {
                    print(query[index]["event_Id"]);
                    return Dismissible(
                      key: Key(query[index].id),
                      onDismissed: (direction) async {
                        CalendarClient calendar = CalendarClient();
                        await calendar.delete(query[index]["event_Id"], false);
                        await FirebaseFirestore.instance
                            .collection("Patients")
                            .doc(currentUserId)
                            .collection("Appointments")
                            .doc(query[index].id)
                            .delete();
                        await FirebaseFirestore.instance
                            .collection("Doctors")
                            .doc(query[index].data()["doctor_Id"])
                            .collection("Appointments")
                            .doc(query[index].id)
                            .delete();

                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text("Appointments Cancelled"),
                          ),
                        );
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red),
                      child: Card(
                        child: ListTile(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => _AppointmentDetailPage(
                                        id: query[index].id,
                                      ))),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dr. " + query[index].data()["doctor_name"] ??
                                    "Doctor Name",
                                softWrap: true,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Text(
                                query[index]["doctor_clinic"] ?? "Clinic Name",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                query[index]
                                        .data()["appointment_time"]
                                        .toDate()
                                        .day
                                        .toString() +
                                    " " +
                                    getMonth(query[index]
                                        .data()["appointment_time"]
                                        .toDate()
                                        .month) +
                                    " " +
                                    query[index]
                                        .data()["appointment_time"]
                                        .toDate()
                                        .year
                                        .toString(),
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Text(
                                getHour(query[index]
                                        .data()["appointment_time"]
                                        .toDate()
                                        .hour) +
                                    ":" +
                                    query[index]
                                        .data()["appointment_time"]
                                        .toDate()
                                        .minute
                                        .toString() +
                                    " " +
                                    getPeriod(query[index]
                                        .data()["appointment_time"]
                                        .toDate()
                                        .hour),
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );

              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
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
      default:
        return "April";
    }
  }

  String getPeriod(int hour) {
    return hour >= 12 ? "pm" : "am";
  }

  String getHour(int hour) {
    return hour > 12 ? (hour - 12).toString() : hour.toString();
  }
}

class _NoDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          "https://cdn.dribbble.com/users/214055/screenshots/3046673/planner-illustration.png?compress=1&resize=800x600",
          filterQuality: FilterQuality.high,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          "You don't have any appointments",
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AppointmentDetailPage extends StatelessWidget {
  final String id;

  _AppointmentDetailPage({this.id});

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
            .collection("Patients")
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
                  "Doctor Name:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  "Dr. " + snapshot.data.data()["doctor_name"],
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Clinic:",
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  snapshot.data.data()["doctor_clinic"] ?? "Clinic Name",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              snapshot.data.data()["typeOfVisit"] == "In-clinic Visit"
                  ? ListTile(
                      title: Text(
                        "Clinic Location:",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Text(
                        snapshot.data.data()["clinic_location"].isNotEmpty
                            ? snapshot.data.data()["clinic_location"]
                            : "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    )
                  : Container(),
              snapshot.data.data()["typeOfVisit"] == "In-clinic Visit"
                  ? Divider(
                      thickness: 1.0,
                    )
                  : Container(),
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
                        snapshot.data.data()["appointment_time"].toDate().day,
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
              snapshot.data.data()["note"] != null
                  ? ListTile(
                      title: Text(
                        "Note:",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Text(
                        snapshot.data.data()["note"].toString(),
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    )
                  : Container(),
              snapshot.data.data()["note"] != null
                  ? Divider(
                      thickness: 1.0,
                    )
                  : Container(),
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
      default:
        return "April";
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
