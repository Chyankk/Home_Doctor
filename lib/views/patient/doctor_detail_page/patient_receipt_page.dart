import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/patient/home_page/patient_home_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientReceiptPage extends StatelessWidget {
  final String id;

  const PatientReceiptPage({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => PatientHomePage(),
              ),
              (route) => false),
          icon: Icon(Icons.home),
        ),
      ),
      body: WillPopScope(
        onWillPop: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PatientHomePage(),
          ),
          (route) => false,
        ),
        child: Container(
          child: ListView(
            padding: EdgeInsets.all(15.0),
            physics: BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Center(
                child: Image.network(
                  "https://cdn.dribbble.com/users/2483932/screenshots/5710253/loading.gif",
                  scale: 2,
                ),
              ),
              Text(
                "Congratulations!!!\nAppointment Booked\n",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Patients")
                    .doc(currentUserId)
                    .collection("Appointments")
                    .doc(id)
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: Text(""),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor Name :",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Dr. " + snapshot.data.data()["doctor_name"],
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Clinic :",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            snapshot.data.data()["doctor_clinic"] ??
                                "Clinic Name",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 7.0,
                          ),
                          snapshot.data.data()["typeOfVisit"] == "Online Visit"
                              ? Container()
                              : Text(
                                  "Clinic Location:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                          snapshot.data.data()["typeOfVisit"] == "Online Visit"
                              ? Container()
                              : SizedBox(
                                  height: 7.0,
                                ),
                          snapshot.data.data()["typeOfVisit"] == "Online Visit"
                              ? Container()
                              : Text(
                                  snapshot.data.data()["clinic_location"] ==
                                              null ||
                                          snapshot.data
                                              .data()["clinic_location"]
                                              .isEmpty
                                      ? "Not Available"
                                      : snapshot.data.data()["clinic_location"],
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                          snapshot.data.data()["typeOfVisit"] == "Online Visit"
                              ? Container()
                              : SizedBox(
                                  height: 7.0,
                                ),
                          Text(
                            "Date :",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            snapshot.data
                                    .data()["appointment_time"]
                                    .toDate()
                                    .day
                                    .toString() +
                                " " +
                                getMonth(
                                  snapshot.data
                                      .data()["appointment_time"]
                                      .toDate()
                                      .day,
                                ) +
                                " " +
                                snapshot.data
                                    .data()["appointment_time"]
                                    .toDate()
                                    .year
                                    .toString(),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Time :",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            getHour(snapshot.data) +
                                " : " +
                                snapshot.data
                                    .data()["appointment_time"]
                                    .toDate()
                                    .minute
                                    .toString() +
                                " " +
                                getPeriod(snapshot.data),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          snapshot.data
                                  .data()["meet_link"]
                                  .toString()
                                  .isNotEmpty
                              ? SizedBox(
                                  height: 7,
                                )
                              : Container(),
                          snapshot.data
                                  .data()["meet_link"]
                                  .toString()
                                  .isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Meet link :",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    InkWell(
                                      onTap: () => launch(
                                          snapshot.data.data()["meet_link"]),
                                      child: Text(
                                        snapshot.data.data()["meet_link"],
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                        softWrap: true,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Patient Name :",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            snapshot.data.data()["patient_name"],
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Patient Email :",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            snapshot.data.data()["patient_email"],
                            style: Theme.of(context).textTheme.headline6,
                            softWrap: true,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Purpose of Visit:",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            snapshot.data.data()["purpose"],
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Type of Visit:",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            snapshot.data.data()["typeOfVisit"],
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Payment Method:",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          _paymentMethod(snapshot, context),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            "Amount:",
                            style:
                                Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "₹ " +
                                snapshot.data
                                    .data()["payment_amount"]
                                    .toString(),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      );
                    default:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text _paymentMethod(
      AsyncSnapshot<DocumentSnapshot> snapshot, BuildContext context) {
    if (snapshot.data.data()["payment_method"] == true) {
      return Text(
        "Online",
        style: Theme.of(context).textTheme.headline6,
      );
    } else {
      return Text(
        "In-Clinic",
        style: Theme.of(context).textTheme.headline6,
      );
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
      default:
        return "April";
    }
  }

  String getPeriod(DocumentSnapshot data) {
    return data.data()["appointment_time"].toDate().hour >= 12 ? "pm" : "am";
  }

  String getHour(DocumentSnapshot data) {
    return data.data()["appointment_time"].toDate().hour > 12
        ? (data.data()["appointment_time"].toDate().hour - 12).toString()
        : data.data()["appointment_time"].toDate().hour.toString();
  }
}
