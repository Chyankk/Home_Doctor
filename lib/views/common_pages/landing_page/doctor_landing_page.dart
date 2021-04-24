import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/common_pages/login_page/doctor_login_page.dart';
import 'package:homedoctor/views/common_pages/widgets/login_exceptions.dart';
import 'package:homedoctor/views/doctor/home_page/doctor_home_page.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';

class DoctorLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:

              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                User user = snapshot.data;
                if (user == null) {
                  return DoctorLoginPage();
                }
                _checkUserEmail(context, email: user.email);
                return DoctorHomePage();

              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

void _checkUserEmail(BuildContext context, {final String email}) async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Patients").get();
    final List<QueryDocumentSnapshot> query = querySnapshot.docs;
    query.forEach(
      (element) {
        if (element.data()["patient_email"] == email) {
          throw UserLoginException(
              message:
                  "Email is present in Patient Section. Please Login using another email");
        }
      },
    );
  } on UserLoginException catch (e) {
    await showAlertDialog(
      context,
      title: "Login Exception",
      content: e.message,
    );
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    showAlertDialog(
      context,
      title: "Login Exception",
      content: e.toString(),
    );
  }
}
