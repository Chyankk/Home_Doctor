import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homedoctor/views/patient/doctor_detail_page/patient_doctor_detail_page.dart';

class DoctorCustomTileWidget extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;

  const DoctorCustomTileWidget({this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: CircleAvatar(
        radius: 35.0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: FaIcon(
          FontAwesomeIcons.userMd,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Dr. " +
                documentSnapshot.data()["first_name"] +
                " " +
                documentSnapshot.data()["last_name"],
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 3.0),
          Text(
            documentSnapshot.data()["speciality"] ?? "Speciality",
            style: Theme.of(context).textTheme.subtitle2.copyWith(
                  fontSize: 17.0,
                  color: Colors.black54,
                ),
          ),
        ],
      ),
      subtitle: Text(
        documentSnapshot.data()["location"] ?? "location",
        style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.black54,
            ),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PatientDoctorDetailPage(
            documentSnapshot: documentSnapshot,
          ),
        ),
      ),
    );
  }
}
