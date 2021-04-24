import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/doctor/profile_page/doctor_professional_detail_edit_page.dart';
import 'package:homedoctor/views/doctor/profile_page/hospital_profile_edit_page.dart';

import 'doctor_personal_detail_edit_page.dart';

class DoctorProfileEditPage extends StatelessWidget {
  final String currentUserId;
  final DocumentSnapshot documentSnapshot;

  const DoctorProfileEditPage(
      {Key key, this.currentUserId, this.documentSnapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit Profile",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white),
          ),
          centerTitle: true,
          bottom: TabBar(
            physics: BouncingScrollPhysics(),
            tabs: [
              Tab(
                child: Text(
                  "Personal",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  "Professional",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  "Hospital/Clinic",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DoctorPersonalDetails(
              currentUserId: currentUserId,
              data: documentSnapshot,
            ),
            DoctorProfessionalDetails(
              currentUserId: currentUserId,
              data: documentSnapshot,
            ),
            DoctorHospitalDetails(
              currentUserId: currentUserId,
              data: documentSnapshot,
            ),
          ],
        ),
      ),
    );
  }
}
