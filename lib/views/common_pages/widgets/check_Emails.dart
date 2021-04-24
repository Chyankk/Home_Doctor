import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QueryDocumentSnapshot, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart' show BuildContext;
import 'package:homedoctor/widgets/showAlertDialog.dart' show showAlertDialog;

import 'login_exceptions.dart';

void checkUserEmail(BuildContext context, {final String email}) async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Patients").get();
    List<QueryDocumentSnapshot> _usersList = querySnapshot.docs;

    _usersList.forEach((QueryDocumentSnapshot element) async {
      if (element.data()["patient_email"] == email) {
        await FirebaseAuth.instance.signOut();
        throw UserLoginException(
            message: "Email is present in patient section");
      }
    });
  } catch (e) {
    rethrow;
  }
}

void checkDoctorEmail(BuildContext context, {final String email}) async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Doctors").get();
    List<QueryDocumentSnapshot> _doctorList = querySnapshot.docs;
    _doctorList.forEach(
      (QueryDocumentSnapshot element) async {
        if (element["email"] == email) {
          await FirebaseAuth.instance.signOut();
          throw DoctorLoginException(
              message: "Email is present in doctor section");
        }
      },
    );
  } on DoctorLoginException catch (e) {
    showAlertDialog(
      context,
      title: "Login Exception",
      content: e.message,
    );
  } catch (e) {
    showAlertDialog(
      context,
      title: "Login Exception",
      content: e.toString(),
    );
  }
}
