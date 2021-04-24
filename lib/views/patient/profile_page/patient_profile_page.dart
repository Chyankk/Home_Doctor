import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homedoctor/views/patient/profile_page/patient_profile_edit_page.dart';

class PatientProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return DefaultTabController(
      length: 3,
      child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Patients")
              .doc(currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientProfileEditPage(
                              patientName: snapshot.data.data()["patient_name"],
                            ),
                          ),
                        ),
                        color: Colors.white,
                      ),
                    ],
                    title: Text(
                      snapshot.data.data()["patient_name"],
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    centerTitle: true,
                    backwardsCompatibility: true,
                    bottom: TabBar(
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      labelStyle: Theme.of(context).textTheme.subtitle1,
                      isScrollable: false,
                      physics: BouncingScrollPhysics(),
                      tabs: [
                        Tab(
                          child: Text(
                            "Personal",
                            // style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Medical",
                            // style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Lifestyle",
                            // style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: TabBarView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      PatientPersonalProfile(),
                      PatientMedicalProfile(),
                      PatientLifeStyle(),
                    ],
                  ),
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class PatientPersonalProfile extends StatefulWidget {
  @override
  _PatientPersonalProfileState createState() => _PatientPersonalProfileState();
}

class _PatientPersonalProfileState extends State<PatientPersonalProfile> {
  Future<void> onRefresh() async {
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Patients")
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(15.0),
                children: [
                  new Container(
                    height: 200.0,
//                    color: Colors.white,
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
                                      radius: 70.0,
                                      child: FaIcon(
                                        FontAwesomeIcons.user,
                                        size: 70.0,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 70.0,
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
                  ListTile(
                    title: Text(
                      "Name:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_name"],
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Email Id:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_email"],
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Contact Number:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_phone"] ?? "--",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.black),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Gender:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_gender"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Date of Birth:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_dob"] != null
                          ? snapshot.data
                                  .data()["patient_dob"]
                                  .toDate()
                                  .year
                                  .toString() +
                              "-" +
                              snapshot.data
                                  .data()["patient_dob"]
                                  .toDate()
                                  .month
                                  .toString() +
                              "-" +
                              snapshot.data
                                  .data()["patient_dob"]
                                  .toDate()
                                  .day
                                  .toString()
                          : "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Blood Group:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_bg"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Marital Status:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_marital"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Height:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: snapshot.data.data()["patient_height"] != null
                        ? getHeight(snapshot, context)
                        : Text(
                            snapshot.data.data()["patient_height"] ?? "--",
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                  ),
                  ListTile(
                    title: Text(
                      "Weight:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: snapshot.data.data()["patient_weight"] == null
                        ? Text(
                            (snapshot.data.data()["patient_weight"] ?? "--")
                                    .toString() +
                                " kg",
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                          )
                        : Text(
                            (snapshot.data.data()["patient_weight"])
                                    .toStringAsFixed(0) +
                                " kg",
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                  ),
                  ListTile(
                    title: Text(
                      "Emergency Contact:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data.data()["patient_emergency_name"] ??
                              "--",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        Text(
                          snapshot.data.data()["patient_emergency_number"] ??
                              "--",
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Location:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_location"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ),
            );
          default:
            return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Text getHeight(
      AsyncSnapshot<DocumentSnapshot> snapshot, BuildContext context) {
    print(snapshot.data.data()["patient_height"]);
    final double ft = snapshot.data.data()["patient_height"] / 30.48;
    print(ft.floor());
    final double inch = (ft - ft.floor()) * 12;
    return Text(
      "${ft.floor()} ft ${inch.toStringAsFixed(0)} inch",
      style:
          Theme.of(context).textTheme.headline5.copyWith(color: Colors.black),
    );
  }
}

class PatientMedicalProfile extends StatefulWidget {
  @override
  _PatientMedicalProfileState createState() => _PatientMedicalProfileState();
}

class _PatientMedicalProfileState extends State<PatientMedicalProfile> {
  Future<void> onRefresh() async {
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Patients")
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(15.0),
                children: [
                  ListTile(
                    title: Text(
                      "Allergies:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_allergies"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Current Medications:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_current_medications"] ??
                          "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Past Medications:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_past_medications"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Chronic Diseases:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_chronic_diseases"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Injuries:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_injuries"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Surgeries:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_surgeries"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ),
            );
          default:
            return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class PatientLifeStyle extends StatefulWidget {
  @override
  _PatientLifeStyleState createState() => _PatientLifeStyleState();
}

class _PatientLifeStyleState extends State<PatientLifeStyle> {
  Future<void> onRefresh() async {
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Patients")
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(15.0),
                children: [
                  ListTile(
                    title: Text(
                      "Smoking Habits:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_smoking"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Alcohol Consumption:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_alcohol"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Activity Level:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_activity_level"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Food Preferences:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_food"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Occupation:",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapshot.data.data()["patient_occupation"] ?? "--",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ),
            );
          default:
            return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
