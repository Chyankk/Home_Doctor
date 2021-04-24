import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homedoctor/views/patient/doctor_detail_page/patient_feedback_page.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:share/share.dart';

import 'appointment_page.dart';

class PatientDoctorDetailPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  PatientDoctorDetailPage({this.documentSnapshot});

  @override
  _PatientDoctorDetailPageState createState() =>
      _PatientDoctorDetailPageState();
}

class _PatientDoctorDetailPageState extends State<PatientDoctorDetailPage> {
  DateTime selectedDate = DateTime.now();
  int available = 10;

  @override
  void initState() {
    available = widget.documentSnapshot.data()["maxPatientsPerDay"];
    dynamic data = _addDates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("Patients")
              .doc(currentUserId)
              .collection("Favorite Doctors")
              .doc(widget.documentSnapshot.id)
              .get(),
          builder: (context, future) {
            switch (future.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                        onPressed: () async {
                          final String currentUserId =
                              FirebaseAuth.instance.currentUser.uid;
                          future.data.exists
                              ? await FirebaseFirestore.instance
                                  .collection("Patients")
                                  .doc(currentUserId)
                                  .collection("Favorite Doctors")
                                  .doc(widget.documentSnapshot.id)
                                  .delete()
                              : await FirebaseFirestore.instance
                                  .collection("Patients")
                                  .doc(currentUserId)
                                  .collection("Favorite Doctors")
                                  .doc(widget.documentSnapshot.id)
                                  .set({
                                  "timestamp": DateTime.now(),
                                  "id": widget.documentSnapshot.id,
                                });
                          setState(() {});
                        },
                        icon: future.data.exists
                            ? Icon(
                                Icons.star,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.star_border_sharp,
                                color: Colors.white,
                              ),
                      ),
                      IconButton(
                        onPressed: () => Share.share(
                            "I found out this amazing doctor Dr. ${widget.documentSnapshot.data()["first_name"]} ${widget.documentSnapshot.data()["last_name"]} near ${widget.documentSnapshot.data()["location"]} on Home Doctor App. I think you should check him out too. You can also book an appointment with him on Home Doctor App"),
                        icon: Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: 90,
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    child: Row(
                      children: [
                        isAvailable(context),
                        Expanded(child: SizedBox.shrink()),
                        CustomButton(
                          desktopMaxWidth:
                              MediaQuery.of(context).size.width / 2.7,
                          buttonHeight: 30.0,
                          buttonTitle: "Book Appointment",
                          textSize: 13.0,
                          buttonColor: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          buttonRadius: 3.0,
                          onPressed: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AppointmentPage(
                                  documentSnapshot: widget.documentSnapshot,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  body: ListView(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    children: [
                      new Container(
                        color: Colors.white,
                        child: new Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  widget.documentSnapshot
                                              .data()["profile_image"] ==
                                          null
                                      ? CircleAvatar(
                                          radius: 70.0,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: FaIcon(
                                            FontAwesomeIcons.user,
                                            size: 50.0,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 100.0,
                                          backgroundImage: NetworkImage(widget
                                                  .documentSnapshot
                                                  .data()["profile_image"] ??
                                              ""),
                                        ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Dr. " +
                            widget.documentSnapshot.data()["first_name"] +
                            " " +
                            widget.documentSnapshot.data()["last_name"],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        widget.documentSnapshot.data()["speciality"] ?? "--",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        widget.documentSnapshot.data()["eduQual"] ?? "--",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                      SizedBox(height: 5.0),
                      Divider(thickness: 3),
                      SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            color: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  "In - clinic Appointment",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Expanded(child: SizedBox.shrink()),
                                Text(
                                  "₹ " +
                                      (widget.documentSnapshot.data()["rate"] ==
                                                      null ||
                                                  widget.documentSnapshot
                                                      .data()["rate"]
                                                      .toString()
                                                      .isEmpty
                                              ? "400"
                                              : widget.documentSnapshot
                                                  .data()["rate"]
                                                  .toString())
                                          .toString() +
                                      "/hr",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 20.0, top: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.documentSnapshot
                                          .data()["clinic_name"] ??
                                      "Clinic Name",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  widget.documentSnapshot
                                                  .data()["clinic_location"] ==
                                              null ||
                                          widget.documentSnapshot
                                              .data()["clinic_location"]
                                              .isEmpty
                                      ? "Location not available"
                                      : "Clinic Location",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Verified details",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      widget.documentSnapshot.data()["available_days"] ==
                                  null ||
                              widget.documentSnapshot
                                  .data()["available_days"]
                                  .isEmpty
                          ? Container()
                          : getAvailableDays(widget.documentSnapshot),
                      SizedBox(height: 20.0),
                      OutlineIconButtonWidget(
                        documentSnapshot: widget.documentSnapshot,
                      ),
                    ],
                  ),
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Column getAvailableDays(DocumentSnapshot snapshot) {
    List<dynamic> avaialbelDays = snapshot.data()["available_days"];

    avaialbelDays.sort();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            "Available Days",
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: avaialbelDays.length,
          itemBuilder: (context, index) => ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text(
              getWeekDay(avaialbelDays[index]),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ),
      ],
    );
  }

  getWeekDay(int i) {
    switch (i) {
      case 7:
        return "Sunday";
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      default:
        return "Monday";
    }
  }

  Column isAvailable(BuildContext context) {
    return widget.documentSnapshot.data()["start_time"] != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<Text>(
                future: getTodayAvailiable(context),
                builder: (context, future1) {
                  if (future1.hasData) {
                    return future1.data;
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              Text(
                widget.documentSnapshot
                        .data()["start_time"]
                        .toDate()
                        .hour
                        .toString() +
                    " : " +
                    ((widget.documentSnapshot
                                        .data()["start_time"]
                                        .toDate()
                                        .minute <
                                    10) ==
                                true
                            ? "0${widget.documentSnapshot.data()["start_time"].toDate().minute}"
                            : widget.documentSnapshot
                                .data()["start_time"]
                                .toDate()
                                .minute
                                .toString())
                        .toString() +
                    " " +
                    getPeriod(
                      widget.documentSnapshot
                          .data()["start_time"]
                          .toDate()
                          .hour,
                    ) +
                    " - " +
                    widget.documentSnapshot
                        .data()["end_time"]
                        .toDate()
                        .hour
                        .toString() +
                    " : " +
                    ((widget.documentSnapshot
                                        .data()["end_time"]
                                        .toDate()
                                        .minute <
                                    10) ==
                                true
                            ? "0${widget.documentSnapshot.data()["end_time"].toDate().minute}"
                            : widget.documentSnapshot
                                .data()["end_time"]
                                .toDate()
                                .minute
                                .toString())
                        .toString() +
                    " " +
                    getPeriod(
                      widget.documentSnapshot.data()["end_time"].toDate().hour,
                    ),
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Colors.green,
                    ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AVAILABLE",
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                "Whole Day",
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Colors.green,
                    ),
              ),
            ],
          );
  }

  // Future<dynamic> _addDates() async {
  //   List<QueryDocumentSnapshot> querySnapshots1;
  //
  //   final QuerySnapshot querys1 = await FirebaseFirestore.instance
  //       .collection("Doctors")
  //       .doc(widget.documentSnapshot.id)
  //       .collection("Appointments")
  //       .get();
  //   querySnapshots1 = querys1.docs;
  //   querySnapshots1.removeWhere(
  //     (element) =>
  //         element.data()["appointment_time"].toDate().year !=
  //             selectedDate.year ||
  //         element.data()["appointment_time"].toDate().month !=
  //             selectedDate.month ||
  //         element.data()["appointment_time"].toDate().day != selectedDate.day,
  //   );
  //    print(querySnapshots1.length);
  //
  //   if (querySnapshots1.isNotEmpty) {
  //     List<dynamic> query12 = widget.documentSnapshot.data()["available_days"];
  //     while (widget.documentSnapshot.data()["maxPatientsPerDay"] -
  //                 querySnapshots1.length <
  //             1 ||
  //         query12.contains(selectedDate.weekday) != true) {
  //       setState(() {
  //         selectedDate = selectedDate.add(Duration(days: 1));
  //         querySnapshots1 = querys1.docs;
  //       });
  //       print(selectedDate);
  //       querySnapshots1.removeWhere(
  //         (element) =>
  //             element.data()["appointment_time"].toDate().year !=
  //                 selectedDate.year ||
  //             element.data()["appointment_time"].toDate().month !=
  //                 selectedDate.month ||
  //             element.data()["appointment_time"].toDate().day !=
  //                 selectedDate.day,
  //       );
  //     }
  //     setState(() {
  //       available = widget.documentSnapshot.data()["maxPatientsPerDay"] -
  //           querySnapshots1.length;
  //     });
  //   }
  //
  //   return true;
  // }

  Future<dynamic> _addDates() async {
    List<QueryDocumentSnapshot> querySnapshots1;
    print(widget.documentSnapshot.data());
    final List<dynamic> availableDays =
        widget.documentSnapshot.data()["available_days"];
    while (availableDays.contains(selectedDate.weekday) != true) {
      print(selectedDate);
      setState(() {
        selectedDate = selectedDate.add(Duration(days: 1));
      });
    }
    final QuerySnapshot querys1 = await FirebaseFirestore.instance
        .collection("Doctors")
        .doc(widget.documentSnapshot.id)
        .collection("Appointments")
        .get();
    querySnapshots1 = querys1.docs;
    querySnapshots1.removeWhere(
      (element) =>
          element.data()["appointment_time"].toDate().year !=
              selectedDate.year ||
          element.data()["appointment_time"].toDate().month !=
              selectedDate.month ||
          element.data()["appointment_time"].toDate().day != selectedDate.day,
    );
    print(querySnapshots1.length);

    if (querySnapshots1.isNotEmpty) {
      setState(() {
        available = widget.documentSnapshot.data()["maxPatientsPerDay"] -
            querySnapshots1.length;
      });
      while (availableDays.contains(selectedDate.weekday) != true ||
          widget.documentSnapshot.data()["maxPatientsPerDay"] -
                  querySnapshots1.length <
              1) {
        setState(() {
          selectedDate = selectedDate.add(Duration(days: 1));
          querySnapshots1 = querys1.docs;
        });
        print(selectedDate);
        querySnapshots1.removeWhere(
          (element) =>
              element.data()["appointment_time"].toDate().year !=
                  selectedDate.year ||
              element.data()["appointment_time"].toDate().month !=
                  selectedDate.month ||
              element.data()["appointment_time"].toDate().day !=
                  selectedDate.day,
        );
        setState(() {
          available = widget.documentSnapshot.data()["maxPatientsPerDay"] -
              querySnapshots1.length;
        });
      }
    } else {
      while (availableDays.contains(selectedDate.weekday) != true) {
        print(selectedDate);
        setState(() {
          selectedDate = selectedDate.add(Duration(days: 1));
        });
      }
    }

    return true;
  }

  Future<Text> getTodayAvailiable(
    BuildContext context,
  ) async {
    return Text(
      "${selectedDate.day} - ${selectedDate.month} - ${selectedDate.year} : ${available} Available",
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  String getPeriod(int hour) {
    return hour >= 12 ? "pm" : "am";
  }
}

class OutlineIconButtonWidget extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  const OutlineIconButtonWidget({Key key, this.documentSnapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PatientFeedbackPage(documentSnapshot: documentSnapshot),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            Text(
              "Send Feedback",
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Expanded(child: SizedBox.shrink()),
            Icon(
              Icons.feedback,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
