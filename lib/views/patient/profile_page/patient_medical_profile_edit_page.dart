import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class PatientMedicalEditProfile extends StatefulWidget {
  final String allergies;
  final String current_Medications;
  final String past_Medications;
  final String chronic_disease;
  final String injuries;
  final String surgeries;

  const PatientMedicalEditProfile({
    this.allergies,
    this.current_Medications,
    this.past_Medications,
    this.chronic_disease,
    this.injuries,
    this.surgeries,
  });

  @override
  _PatientMedicalEditProfileState createState() =>
      _PatientMedicalEditProfileState();
}

class _PatientMedicalEditProfileState extends State<PatientMedicalEditProfile> {
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _currentMedicationsController =
      TextEditingController();
  final TextEditingController _pastMedicationsController =
      TextEditingController();
  final TextEditingController _chronicDiseasesController =
      TextEditingController();
  final TextEditingController _injuriesController = TextEditingController();
  final TextEditingController _surgeriesController = TextEditingController();

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    _allergyController.text = widget.allergies ?? "";
    _currentMedicationsController.text = widget.current_Medications ?? "";
    _pastMedicationsController.text = widget.past_Medications ?? "";
    _chronicDiseasesController.text = widget.chronic_disease ?? "";
    _injuriesController.text = widget.injuries ?? "";
    _surgeriesController.text = widget.surgeries ?? "";
  }

  void _submit() {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser.uid;
      showLoading(context);
      FirebaseFirestore.instance
          .collection("Patients")
          .doc(currentUserId)
          .update({
        "patient_allergies": _allergyController.text,
        "patient_current_medications": _currentMedicationsController.text,
        "patient_past_medications": _pastMedicationsController.text,
        "patient_chronic_diseases": _chronicDiseasesController.text,
        "patient_injuries": _injuriesController.text,
        "patient_surgeries": _surgeriesController.text,
      });
      Navigator.of(context).pop();
      Navigator.pop(context);
    } on FirebaseException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Error", content: E.message);
    } on PlatformException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Error", content: E.message);
    } catch (e) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Error", content: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.all(15.0),
      scrollDirection: Axis.vertical,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Allergies:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _allergyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 7.0),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Current Medications:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _currentMedicationsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 7.0,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Past Medications:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _pastMedicationsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 7.0),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Chronic Diseases:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _chronicDiseasesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 7.0,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Injuries:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _injuriesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 7.0,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Surgeries:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _surgeriesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        CustomButton(
          desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
          buttonHeight: 65.0,
          buttonTitle: "Update Medical Profile",
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          buttonRadius: 3.0,
          onPressed: _submit,
        ),
      ],
    );
  }
}
