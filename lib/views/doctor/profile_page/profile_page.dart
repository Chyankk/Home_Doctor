import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homedoctor/views/doctor/profile_page/doctor_profile_edit_page.dart';

class DoctorProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctors")
            .doc(currentUser)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              print("Hello World");
              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  title: Text(
                    "Profile Page",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DoctorProfileEditPage(
                            currentUserId: currentUser,
                            documentSnapshot: snapshot.data,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(15.0),
                  children: [
                    new Container(
                      height: 250.0,
                      color: Colors.white,
                      child: new Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                snapshot.data.data()["profile_image"] == null
                                    ? CircleAvatar(
                                        radius: 100.0,
                                        child: FaIcon(
                                          FontAwesomeIcons.user,
                                          size: 100.0,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 100.0,
                                        backgroundImage: NetworkImage(snapshot
                                                .data
                                                .data()["profile_image"] ??
                                            ""),
                                      ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Text(
                      "Dr. " +
                          snapshot.data.data()["first_name"] +
                          " " +
                          snapshot.data.data()["last_name"],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 7.0),
                    Text(
                      snapshot.data.data()["eduQual"] == null ||
                              snapshot.data.data()["eduQual"].isEmpty
                          ? "Education Qualification"
                          : snapshot.data.data()["eduQual"],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    SizedBox(height: 7.0),
                    Text(
                      snapshot.data.data()["speciality"] ?? "Speciality",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    SizedBox(height: 7.0),
                    Text(
                      "${snapshot.data.data()["noOfExp"] ?? 0} Years of Experiance",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    SizedBox(height: 7.5),
                    Divider(thickness: 1),
                    ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text(
                        snapshot.data.data()["location"],
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    ListTile(
                      // leading: CircleAvatar(),
                      title: Text(
                        snapshot.data.data()["email"],
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      leading: Icon(Icons.email),
                    ),
                    ListTile(
                      title: Text(
                        snapshot.data.data()["phone"] == null ||
                                snapshot.data.data()["phone"].isEmpty
                            ? "Phone"
                            : snapshot.data.data()["phone"],
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      leading: Icon(Icons.phone),
                    ),
                    ListTile(
                      leading: Icon(Icons.business),
                      title: Text(
                        snapshot.data.data()["clinic_name"] ?? "Clinic Name",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["clinic_location"] ??
                            "Clinic Location",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Max Patients per day : " +
                            snapshot.data
                                .data()["maxPatientsPerDay"]
                                .toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    snapshot.data.data()["start_time"] != null
                        ? ListTile(
                            leading: Icon(Icons.timer),
                            title: Text(
                              (snapshot.data.data()["start_time"].toDate().hour > 12
                                              ? "0${snapshot.data.data()["start_time"].toDate().hour - 12}"
                                              : snapshot.data
                                                  .data()["start_time"]
                                                  .toDate()
                                                  .hour
                                                  .toString())
                                          .toString() +
                                      " : " +
                                      ((snapshot.data
                                                          .data()["start_time"]
                                                          .toDate()
                                                          .minute <
                                                      10) ==
                                                  true
                                              ? "0${snapshot.data.data()["start_time"].toDate().minute}"
                                              : snapshot.data
                                                  .data()["start_time"]
                                                  .toDate()
                                                  .minute)
                                          .toString() +
                                      " " +
                                      getPeriod(snapshot.data
                                          .data()["start_time"]
                                          .toDate()
                                          .hour) +
                                      " - " +
                                      (snapshot.data
                                                      .data()["end_time"]
                                                      .toDate()
                                                      .hour >
                                                  12
                                              ? "0${snapshot.data.data()["end_time"].toDate().hour - 12}"
                                              : snapshot.data
                                                  .data()["end_time"]
                                                  .toDate()
                                                  .hour
                                                  .toString())
                                          .toString() +
                                      " : " +
                                      ((snapshot.data
                                                          .data()["end_time"]
                                                          .toDate()
                                                          .minute <
                                                      10) ==
                                                  true
                                              ? "0${snapshot.data.data()["end_time"].toDate().minute}"
                                              : snapshot.data
                                                  .data()["end_time"]
                                                  .toDate()
                                                  .minute)
                                          .toString() +
                                      " " +
                                      getPeriod(snapshot.data.data()["end_time"].toDate().hour) ??
                                  "Start Time",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          )
                        : Container(),
                    snapshot.data.data()["available_days"] != null
                        ? ListTile(
                            title: Text(
                              "Available Days",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          )
                        : Container(),
                    snapshot.data.data()["available_days"] != null
                        ? getAvailableDays(snapshot)
                        : Container(),
                  ],
                ),
              );
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }

  ListView getAvailableDays(AsyncSnapshot<DocumentSnapshot> snapshot) {
    List<dynamic> avaialbelDays = snapshot.data.data()["available_days"];
    avaialbelDays.sort();
    print(avaialbelDays);
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: avaialbelDays.length,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text(
          getWeekDay(avaialbelDays[index]),
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  String getPeriod(int hour) {
    return hour >= 12 ? "pm" : "am";
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
}
