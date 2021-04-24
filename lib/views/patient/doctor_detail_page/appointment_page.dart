import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' hide Colors;
import 'package:homedoctor/widgets/calendar_client.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';
import 'package:uuid/uuid.dart';

import 'patient_receipt_page.dart';

class AppointmentPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  AppointmentPage({Key key, this.documentSnapshot}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String purpose = "Consultation";
  String typeOfVisit = "Online Visit";
  bool online = true;

  @override
  void initState() {
    List<dynamic> query = widget.documentSnapshot.data()["available_days"];
    if (widget.documentSnapshot.data()["start_time"] != null) {
      if (selectedTime.hour <
          widget.documentSnapshot.data()["start_time"].toDate().hour) {
        selectedTime = TimeOfDay.fromDateTime(
          widget.documentSnapshot.data()["start_time"].toDate(),
        );
      }
      while (query.contains(selectedDate.weekday) != true) {
        selectedDate = selectedDate.add(Duration(days: 1));
        print(selectedDate);
      }
      dynamic data = _addDates();
    }
    super.initState();
  }

  Future<dynamic> _addDates() async {
    List<QueryDocumentSnapshot> querySnapshots1;
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
      List<dynamic> query12 = widget.documentSnapshot.data()["available_days"];
      while (widget.documentSnapshot.data()["maxPatientsPerDay"] -
                  querySnapshots1.length <
              1 ||
          query12.contains(selectedDate.weekday) != true) {
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
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.documentSnapshot.data()["profile_image"] ?? ""),
            ),
            title: Text(
              "Dr. " +
                  widget.documentSnapshot.data()["first_name"] +
                  " " +
                  widget.documentSnapshot.data()["last_name"],
              style: Theme.of(context).textTheme.headline5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: Text(
              widget.documentSnapshot.data()["clinic_name"] ??
                  "Clinic Name" +
                      ", " +
                      widget.documentSnapshot.data()["location"],
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Divider(
            thickness: 1.0,
          ),
          Text(
            "Choose Date: ",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 5.0),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 7.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Text(
                    selectedDate.day.toString() +
                        " " +
                        getMonth(selectedDate.month) +
                        " " +
                        selectedDate.year.toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Expanded(child: SizedBox.shrink()),
                  Icon(
                    Icons.event,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Choose Time: ",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 5.0),
          InkWell(
            onTap: () => _selectTime(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 7.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Text(
                    (selectedTime.hour > 12
                                ? selectedTime.hour - 12
                                : selectedTime.hour)
                            .toString() +
                        " : " +
                        ((selectedTime.minute < 10) == true
                                ? "0${selectedTime.minute}"
                                : selectedTime.minute.toString())
                            .toString() +
                        " " +
                        getPeriod(selectedTime.period),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Expanded(child: SizedBox.shrink()),
                  Icon(
                    Icons.alarm,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          _purposeWidget(),
          SizedBox(height: 10.0),
          _typeWidget(),
          SizedBox(height: 10.0),
          paymentMethod(),
          SizedBox(height: 10.0),
          CustomButton(
            desktopMaxWidth: MediaQuery.of(context).size.width / 2.7,
            buttonHeight: 50.0,
            buttonTitle: "Proceed and Pay",
            buttonColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            buttonRadius: 3.0,
            onPressed: () async {
              try {
                showLoading(context);

                final DateTime dateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                print(dateTime.weekday);
                final uid = Uuid().v4();
                CalendarClient client = CalendarClient();
                EventAttendee eventAttendee = EventAttendee();
                eventAttendee.email = widget.documentSnapshot.data()["email"];
                List<EventAttendee> attendeeEmails = [eventAttendee];
                int startTimeInEpoch = dateTime.millisecondsSinceEpoch;
                int endTimeInEpoch =
                    dateTime.add(Duration(minutes: 60)).millisecondsSinceEpoch;

                client
                    .insert(
                  title: purpose,
                  description: "",
                  location: typeOfVisit == "Online Visit"
                      ? "Online"
                      : widget.documentSnapshot.data()["clinic_location"],
                  attendeeEmailList: attendeeEmails,
                  shouldNotifyAttendees: false,
                  hasConferenceSupport:
                      typeOfVisit == "Online Visit" ? true : false,
                  startTime:
                      DateTime.fromMillisecondsSinceEpoch(startTimeInEpoch),
                  endTime: DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch),
                )
                    .then(
                  (eventData) async {
                    print(eventData);
                    print(eventData["id"]);
                    final String currentUserId =
                        FirebaseAuth.instance.currentUser.uid;
                    final DocumentSnapshot patientDoc = await FirebaseFirestore
                        .instance
                        .collection("Patients")
                        .doc(currentUserId)
                        .get();
                    await FirebaseFirestore.instance
                        .collection("Doctors")
                        .doc(widget.documentSnapshot.id)
                        .collection("Appointments")
                        .doc(uid)
                        .set({
                      "doctor_Id": widget.documentSnapshot.id,
                      "doctor_name":
                          widget.documentSnapshot.data()["first_name"] +
                              " " +
                              widget.documentSnapshot.data()["last_name"],
                      "purpose": purpose,
                      "typeOfVisit": typeOfVisit,
                      "payment_method": online,
                      "payment_amount":
                          widget.documentSnapshot.data()["rate"] ?? 400,
                      "doctor_clinic":
                          widget.documentSnapshot.data()["clinic_name"],
                      "patient_name": patientDoc.data()["patient_name"],
                      "patient_Id": patientDoc.id,
                      "patient_email": patientDoc.data()["patient_email"],
                      "appointment_time": dateTime,
                      "meet_link": eventData["link"] ?? "",
                      "clinic_location":
                          widget.documentSnapshot.data()["clinic_location"] ??
                              "Not Available",
                      "event_Id": eventData["id"] ?? "",
                    });
                    FirebaseFirestore.instance
                        .collection("Doctors")
                        .doc(widget.documentSnapshot.id)
                        .collection("Patients")
                        .doc(currentUserId)
                        .set({
                      "timestamp": DateTime.now(),
                      "id": currentUserId,
                    });
                    await FirebaseFirestore.instance
                        .collection("Patients")
                        .doc(currentUserId)
                        .collection("Appointments")
                        .doc(uid)
                        .set({
                      "doctor_Id": widget.documentSnapshot.id,
                      "doctor_name":
                          widget.documentSnapshot.data()["first_name"] +
                              " " +
                              widget.documentSnapshot.data()["last_name"],
                      "clinic_location":
                          widget.documentSnapshot.data()["clinic_location"] ??
                              "Not Available",
                      "purpose": purpose,
                      "typeOfVisit": typeOfVisit,
                      "payment_method": online,
                      "payment_amount":
                          widget.documentSnapshot.data()["rate"] ?? 400,
                      "doctor_clinic":
                          widget.documentSnapshot.data()["clinic_name"],
                      "patient_name": patientDoc.data()["patient_name"],
                      "patient_Id": patientDoc.id,
                      "patient_email": patientDoc.data()["patient_email"],
                      "appointment_time": dateTime,
                      "meet_link": eventData["link"] ?? "",
                      "event_Id": eventData["id"] ?? "",
                    });
                    await FirebaseFirestore.instance
                        .collection("Patients")
                        .doc(currentUserId)
                        .collection("Doctors")
                        .doc(widget.documentSnapshot.id)
                        .set(
                      {
                        "doctor_Id": widget.documentSnapshot.id,
                        "doctor_name":
                            widget.documentSnapshot.data()["first_name"] +
                                " " +
                                widget.documentSnapshot.data()["last_name"],
                        "location": widget.documentSnapshot.data()["location"],
                        "clinic_location":
                            widget.documentSnapshot.data()["clinic_location"] ??
                                "Not Available",
                      },
                    );
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => PatientReceiptPage(
                        id: uid,
                      ),
                    ));
                  },
                );
              } on PlatformException catch (e) {
                Navigator.pop(context);
                showAlertDialog(context, title: "Error", content: e.message);
              } on FirebaseException catch (e) {
                Navigator.pop(context);
                showAlertDialog(context, title: "Error", content: e.message);
              } catch (e) {
                Navigator.pop(context);
                showAlertDialog(context, title: "Error", content: e.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked_s = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    if (widget.documentSnapshot.data()["start_time"] != null) {
      TimeOfDay startTime = TimeOfDay.fromDateTime(
          widget.documentSnapshot.data()["start_time"].toDate());
      TimeOfDay endTime = TimeOfDay.fromDateTime(
          widget.documentSnapshot.data()["end_time"].toDate());
      if ((picked_s.hour + picked_s.minute / 60) <=
              (startTime.hour + startTime.minute / 60) ||
          (picked_s.hour + picked_s.minute / 60) >=
              (endTime.hour + endTime.minute / 60)) {
        showAlertDialog(context,
            title: "Error",
            content:
                "Time should be between ${startTime.hour} : ${startTime.minute} ${getPeriod(startTime.period)} and ${endTime.hour} : ${endTime.minute} ${getPeriod(endTime.period)}");
      } else if (picked_s != null && picked_s != selectedTime) {
        setState(() {
          selectedTime = picked_s;
        });
      }
    } else if (picked_s != null && picked_s != selectedTime) {
      setState(() {
        selectedTime = picked_s;
      });
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 25)),
        selectableDayPredicate: _predicate,
        builder: (context, child) {
          return Theme(
            data: ThemeData(
                backgroundColor: Theme.of(context).colorScheme.primary,
                primaryColor: Colors.orangeAccent,
                disabledColor: Colors.brown,
                textTheme: TextTheme(
                  headline1: TextStyle(color: Colors.black),
                  headline2: TextStyle(color: Colors.black),
                  headline3: TextStyle(color: Colors.black),
                  headline4: TextStyle(color: Colors.black),
                  headline5: TextStyle(color: Colors.black),
                  headline6: TextStyle(color: Colors.black),
                  subtitle1: TextStyle(fontSize: 18, color: Colors.black),
                  subtitle2: TextStyle(color: Colors.black),
                  bodyText1: TextStyle(color: Colors.black),
                  bodyText2: TextStyle(color: Colors.black),
                ),
                accentColor: Colors.yellow),
            child: child,
          );
        });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Doctors")
        .doc(widget.documentSnapshot.id)
        .collection("Appointments")
        .get();
    List<QueryDocumentSnapshot> querySnapshots = querySnapshot.docs;
    querySnapshots.removeWhere(
      (element) =>
          element.data()["appointment_time"].toDate().year != picked.year ||
          element.data()["appointment_time"].toDate().month != picked.month ||
          element.data()["appointment_time"].toDate().day != picked.day,
    );
    if (widget.documentSnapshot.data()["maxPatientsPerDay"] -
            querySnapshots.length <
        1) {
      print(widget.documentSnapshot.data()["maxPatientsPerDay"] -
          querySnapshots.length);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(
              "Doctor is unavailable on selected Date ${picked.day}/${picked.month}/${picked.year}"),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  bool _predicate(DateTime date) {
    if (widget.documentSnapshot.data()["available_days"] == null) {
      return true;
    } else {
      List<dynamic> query = widget.documentSnapshot.data()["available_days"];
      if (query.contains(date.weekday) != true) {
        return false;
      }

      return true;
    }
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

  String getPeriod(DayPeriod dayPeriod) {
    switch (dayPeriod.index) {
      case 0:
        return "am";
      case 1:
        return "pm";
      default:
        return "pm";
    }
  }

  Container _purposeWidget() {
    return Container(
      //constraints: BoxConstraints(maxWidth: 500.0),
      //padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Purpose of visit",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(),
            ),
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: purpose,
                elevation: 16,
                style: Theme.of(context).textTheme.headline6,
                hint: Text("Speciality"),
                onChanged: (String newValue) {
                  setState(() {
                    purpose = newValue;
                  });
                },
                items: <String>[
                  "Consultation",
                  "Treatment",
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container paymentMethod() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
            onTap: () => setState(() => online = true),
            leading: online == true
                ? Icon(
                    Icons.radio_button_checked,
                    color: Colors.blue,
                  )
                : Icon(
                    Icons.radio_button_off,
                    color: Colors.blue,
                  ),
            subtitle: Text(
              "Pay Online",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            title: Text(
              "₹ " + (widget.documentSnapshot.data()["rate"] ?? 400).toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          typeOfVisit == "Online Visit"
              ? Container()
              : ListTile(
                  onTap: () => setState(() => online = false),
                  leading: online == false
                      ? Icon(
                          Icons.radio_button_checked,
                          color: Colors.blue,
                        )
                      : Icon(
                          Icons.radio_button_off,
                          color: Colors.blue,
                        ),
                  subtitle: Text(
                    "Pay later at clinic",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  title: Text(
                    "₹ " +
                        (widget.documentSnapshot.data()["rate"] ?? 400)
                            .toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
        ],
      ),
    );
  }

  Container _typeWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Type of visit",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(),
            ),
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: typeOfVisit,
                elevation: 16,
                style: Theme.of(context).textTheme.headline6,
                //hint: Text("Type of Visit"),
                onChanged: (String newValue) {
                  if (newValue == "Online Visit") {
                    setState(() {
                      typeOfVisit = newValue;
                      online = true;
                    });
                  } else {
                    setState(() {
                      typeOfVisit = newValue;
                    });
                  }
                },
                items: <String>[
                  "Online Visit",
                  "In-clinic Visit",
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Text(
            widget.documentSnapshot.data()["clinic_location"] == null ||
                    widget.documentSnapshot.data()["clinic_location"].isEmpty
                ? "Location is not available. Book In-clinic visit at your own risk."
                : "",
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: Colors.red,
                ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
