import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/patient/profile_page/patient_lifestyle_profile_edit_page.dart';

import 'patient_medical_profile_edit_page.dart';
import 'patient_personal_profile_edit_page.dart';

class PatientProfileEditPage extends StatefulWidget {
  final String patientName;

  PatientProfileEditPage({this.patientName = "--"});

  @override
  _PatientProfileEditPageState createState() => _PatientProfileEditPageState();
}

class _PatientProfileEditPageState extends State<PatientProfileEditPage> {
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
                    title: Text(
                      widget.patientName,
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
                  body: TabBarView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      PatientPersonalEditPage(
                        profile_image: snapshot.data.data()["profile_image"],
                        contactNumber: snapshot.data.data()["patient_phone"],
                        gender: snapshot.data.data()["patient_gender"],
                        dob: snapshot.data.data()["patient_dob"] != null
                            ? snapshot.data.data()["patient_dob"].toDate()
                            : DateTime.now(),
                        bg: snapshot.data.data()["patient_bg"],
                        marital_status: snapshot.data.data()["patient_marital"],
                        height: snapshot.data.data()["patient_height"],
                        weight: snapshot.data.data()["patient_weight"],
                        emergencyContactName:
                            snapshot.data.data()["patient_emergency_name"],
                        emergencyContactNumber:
                            snapshot.data.data()["patient_emergency_number"],
                        location: snapshot.data.data()["patient_location"],
                      ),
                      PatientMedicalEditProfile(
                        allergies: snapshot.data.data()["patient_allergies"],
                        current_Medications:
                            snapshot.data.data()["patient_current_medications"],
                        past_Medications:
                            snapshot.data.data()["patient_past_medications"],
                        chronic_disease:
                            snapshot.data.data()["patient_chronic_diseases"],
                        injuries: snapshot.data.data()["patient_injuries"],
                        surgeries: snapshot.data.data()["patient_surgeries"],
                      ),
                      PatientLifeStyleEditPage(),
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
