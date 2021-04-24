import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class PatientLifeStyleEditPage extends StatefulWidget {
  final String smoking_Habits;
  final String alcohol_consumption;
  final String activity_level;
  final String food_pref;
  final String occupation;

  const PatientLifeStyleEditPage({
    this.smoking_Habits,
    this.alcohol_consumption,
    this.activity_level,
    this.food_pref,
    this.occupation,
  });

  @override
  _PatientLifeStyleEditPageState createState() =>
      _PatientLifeStyleEditPageState();
}

class _PatientLifeStyleEditPageState extends State<PatientLifeStyleEditPage> {
  String smoking_Habits = "I don't smoke";
  String alcohol_consumption = "Non-drinker";
  String activity_level = "Sedentary (low)";
  String food_pref = "Vegeterian";
  String occupation = "Other";

  getData() {
    smoking_Habits = widget.smoking_Habits ?? "I don't smoke";
    alcohol_consumption = widget.alcohol_consumption ?? "Non-drinker";
    activity_level = widget.activity_level ?? "Sedentary (low)";
    food_pref = widget.food_pref ?? "Vegeterian";
    occupation = widget.occupation ?? "Other";
  }

  void _submit() {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser.uid;
      showLoading(context);
      FirebaseFirestore.instance
          .collection("Patients")
          .doc(currentUserId)
          .update({
        "patient_smoking": smoking_Habits,
        "patient_alcohol": alcohol_consumption,
        "patient_activity_level": activity_level,
        "patient_food": food_pref,
        "patient_occupation": occupation,
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
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(15.0),
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Smoking Habits:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: smoking_Habits,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(
                        () {
                          smoking_Habits = newValue;
                        },
                      );
                    },
                    items: <String>[
                      "I don't smoke",
                      "I used to, but I've quit",
                      "1-2/day",
                      "3-5/day",
                      "5-10/day",
                      ">10/day",
                    ]
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          ),
                        )
                        .toList(),
                  ),
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
                "Alcohol Consumption:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: alcohol_consumption,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(
                        () {
                          alcohol_consumption = newValue;
                        },
                      );
                    },
                    items: <String>[
                      "Non-drinker",
                      "Rare",
                      "Suicidal",
                      "Regular",
                      "Heavy",
                    ]
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          ),
                        )
                        .toList(),
                  ),
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
                "Activity Level:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activity_level,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(
                        () {
                          activity_level = newValue;
                        },
                      );
                    },
                    items: <String>[
                      "Sedentary (low)",
                      "Moderately active (medium)",
                      "Active (high)",
                      "Athletic (very high)",
                    ]
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          ),
                        )
                        .toList(),
                  ),
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
                "Food Preferences:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: food_pref,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(() {
                        food_pref = newValue;
                      });
                    },
                    items: <String>[
                      "Vegeterian",
                      "Non-Vegeterian",
                      "Eggeterian",
                      "Vegan",
                    ]
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          ),
                        )
                        .toList(),
                  ),
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
                "Occupation:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  border: Border.all(),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: occupation,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(() {
                        occupation = newValue;
                      });
                    },
                    items: <String>[
                      "IT Professional",
                      "Medical professional",
                      "Banking professional",
                      "Education",
                      "Student",
                      "Home-maker",
                      "Other",
                    ]
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        CustomButton(
          desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
          buttonHeight: 65.0,
          buttonTitle: "Update Lifestyle",
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          buttonRadius: 3.0,
          onPressed: _submit,
        ),
      ],
    );
  }
}
