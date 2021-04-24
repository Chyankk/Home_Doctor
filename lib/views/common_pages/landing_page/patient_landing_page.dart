import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/views/common_pages/login_page/patient_login_page.dart';
import 'package:homedoctor/views/common_pages/widgets/login_exceptions.dart';
import 'package:homedoctor/views/patient/home_page/patient_home_page.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';

class PatientLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          case ConnectionState.active:
          case ConnectionState.done:
            User user = snapshot.data;

            if (user == null) {
              return PatientLoginPage();
            }
            _checkDoctorEmail(context, email: user.email);
            return PatientHomePage();
          default:
            return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  void _checkDoctorEmail(BuildContext context, {final String email}) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Doctors").get();
      List<QueryDocumentSnapshot> _doctorList = querySnapshot.docs;
      _doctorList.forEach(
        (QueryDocumentSnapshot element) async {
          if (element.data()["email"] == email) {
            await FirebaseAuth.instance.signOut();
            throw DoctorLoginException(
                message:
                    "Email is present in doctor section.Please use another email Id to Login");
          }
        },
      );
    } on DoctorLoginException catch (e) {
      await showAlertDialog(
        context,
        title: "Login Exception",
        content: e.message,
      );
      await FirebaseAuth.instance.signOut();
    } on FirebaseException catch (e) {
      showAlertDialog(
        context,
        title: "Login Exception",
        content: e.toString(),
      );
    } on PlatformException catch (e) {
      showAlertDialog(
        context,
        title: "Login Exception",
        content: e.toString(),
      );
    } catch (e) {
      showAlertDialog(
        context,
        title: "Login Exception",
        content: e.toString(),
      );
    }
  }
}
