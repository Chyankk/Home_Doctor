import 'package:flutter/material.dart';
import 'package:homedoctor/views/common_pages/signup_page/doctor_signup_tab.dart';
import 'package:homedoctor/views/common_pages/signup_page/patient_signup_tab.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            "SIGN UP",
            style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Colors.white,
                ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            physics: BouncingScrollPhysics(),
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Text(
                  "Patient",
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              Tab(
                child: Text(
                  "Doctor",
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PatientSignupTab(),
            DoctorSignupTab(),
          ],
        ),
      ),
    );
  }
}
