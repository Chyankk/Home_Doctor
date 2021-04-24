import 'package:flutter/material.dart';
import 'package:homedoctor/views/common_pages/landing_page/doctor_landing_page.dart';
import 'package:homedoctor/views/common_pages/landing_page/patient_landing_page.dart';
import 'package:homedoctor/views/common_pages/signup_page/signup_page.dart';
import 'package:homedoctor/widgets/custom_button.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome \nHome Doctor",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 50.0),
              Text(
                "Login",
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 30.0),
              CustomButton(
                desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
                buttonHeight: 65.0,
                buttonTitle: "Doctor",
                buttonColor: Theme.of(context).colorScheme.primary,
                textSize: 20.0,
                textColor: Colors.white,
                buttonRadius: 3.0,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DoctorLandingPage(),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              CustomButton(
                desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
                buttonHeight: 65.0,
                buttonTitle: "Patient",
                buttonColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                buttonRadius: 3.0,
                textSize: 20.0,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PatientLandingPage(),
                  ),
                ),
              ),
              SizedBox(height: 40.0),
              Text(
                "Don't have an account?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignupPage(),
                  ),
                ),
                child: Text(
                  "Create one now",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
