import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'add_prescription_page.dart';

class DoctorPatientPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Patients",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Doctors")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection("Patients")
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.data.docs.isEmpty) {
                  return Center(
                    child: Text("No Patients Contacted Yet"),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10.0),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) => Card(
                    margin: EdgeInsets.symmetric(vertical: 7.0),
                    child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Patients")
                            .doc(snapshot.data.docs[index].id)
                            .get(),
                        builder: (context, future) {
                          switch (future.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            case ConnectionState.active:
                            case ConnectionState.done:
                              return ListTile(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => _PatientProfilePage(
                                        id: snapshot.data.docs[index].id),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10.0),
                                leading: snapshot.data.docs[index]
                                            .data()["profile_image"] ==
                                        null
                                    ? CircleAvatar(
                                        radius: 30.0,
                                        child: FaIcon(
                                          FontAwesomeIcons.userAlt,
                                          size: 27.0,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: snapshot
                                            .data.docs[index]
                                            .data()["profile_image"],
                                      ),
                                title: Text(
                                  future.data["patient_name"],
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              );
                            default:
                              return Center(child: CircularProgressIndicator());
                          }
                        }),
                  ),
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class _PatientProfilePage extends StatelessWidget {
  final String id;

  const _PatientProfilePage({Key key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Patients")
            .doc(id)
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
                    labelStyle: Theme.of(context).textTheme.subtitle2,
                    isScrollable: false,
                    physics: BouncingScrollPhysics(),
                    tabs: [
                      Tab(
                        child: Text(
                          "Personal",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Medical",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Lifestyle",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Prescription",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).backgroundColor,
                body: TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    _PatientPersonalProfile(
                      id: id,
                    ),
                    _PatientMedicalProfile(
                      id: id,
                    ),
                    _PatientLifestyleProfile(
                      id: id,
                    ),
                    PrescriptionLists(id: id),
                  ],
                ),
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _PatientPersonalProfile extends StatefulWidget {
  final String id;

  const _PatientPersonalProfile({this.id});

  @override
  __PatientPersonalProfileState createState() =>
      __PatientPersonalProfileState();
}

class __PatientPersonalProfileState extends State<_PatientPersonalProfile> {
  Future<void> onRefresh() async {
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Patients")
          .doc(widget.id)
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
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Name:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_name"],
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Email Id:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_email"],
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Contact Number:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_phone"] ?? "--",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Gender:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_gender"] ?? "--",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
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
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Blood Group:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_bg"] ?? "--",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Marital Status:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_marital"] ?? "--",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Height:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: snapshot.data.data()["patient_height"] != null
                          ? getHeight(snapshot, context)
                          : Text(
                              snapshot.data.data()["patient_height"] ?? "--",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(color: Colors.black),
                            ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Weight:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_weight"] == null ||
                                snapshot.data
                                    .data()["patient_weight"]
                                    .toString()
                                    .isEmpty
                            ? "--"
                            : (snapshot.data.data()["patient_weight"])
                                    .toStringAsFixed(0) +
                                " kg",
                        // (snapshot.data.data()["patient_weight"] ?? "--")
                        //         .toStringAsFixed(0) +
                        //     " kg",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
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
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: Colors.black),
                          ),
                          Text(
                            snapshot.data.data()["patient_emergency_number"] ??
                                "--",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Location:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_location"] ?? "--",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Colors.black),
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

class _PatientMedicalProfile extends StatefulWidget {
  final String id;

  const _PatientMedicalProfile({Key key, this.id}) : super(key: key);

  @override
  __PatientMedicalProfileState createState() => __PatientMedicalProfileState();
}

class __PatientMedicalProfileState extends State<_PatientMedicalProfile> {
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
          .doc(widget.id)
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
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Allergies:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_allergies"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Current Medications:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_current_medications"] ??
                            "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Past Medications:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_past_medications"] ??
                            "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Chronic Diseases:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_chronic_diseases"] ??
                            "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Injuries:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_injuries"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Surgeries:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_surgeries"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
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

class _PatientLifestyleProfile extends StatefulWidget {
  final String id;

  _PatientLifestyleProfile({this.id});

  @override
  __PatientLifestyleProfileState createState() =>
      __PatientLifestyleProfileState();
}

class __PatientLifestyleProfileState extends State<_PatientLifestyleProfile> {
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
          .doc(widget.id)
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
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Smoking Habits:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_smoking"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Alcohol Consumption:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_alcohol"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Activity Level:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_activity_level"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Food Preferences:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_food"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text(
                        "Occupation:",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        snapshot.data.data()["patient_occupation"] ?? "--",
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.black,
                            ),
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
