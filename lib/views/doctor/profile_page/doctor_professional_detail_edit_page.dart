import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class DoctorProfessionalDetails extends StatefulWidget {
  final String currentUserId;
  final DocumentSnapshot data;

  const DoctorProfessionalDetails({Key key, this.currentUserId, this.data});

  @override
  _DoctorProfessionalDetailsState createState() =>
      _DoctorProfessionalDetailsState();
}

class _DoctorProfessionalDetailsState extends State<DoctorProfessionalDetails> {
  TextEditingController noOfYearsExperience = TextEditingController();

  TextEditingController educationQualification = TextEditingController();

  String speciality;

  Future<void> _submit() async {
    if (speciality == null || speciality.isEmpty) {
      showAlertDialog(
        context,
        title: "Error",
        content: "Require Speciality",
      );
    } else {
      try {
        showLoading(context);
        await FirebaseFirestore.instance
            .collection("Doctors")
            .doc(widget.currentUserId)
            .update({
          "speciality": speciality,
          "noOfExp": int.parse(noOfYearsExperience.text),
          "eduQual": educationQualification.text,
        });
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } on FirebaseException catch (e) {
        Navigator.of(context).pop();

        showAlertDialog(
          context,
          title: "Error",
          content: e.message,
        );
      } catch (e) {
        Navigator.of(context).pop();

        showAlertDialog(
          context,
          title: "Error",
          content: e.toString(),
        );
      }
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    setState(() {
      speciality = widget.data.data()["speciality"] ?? null;
    });
    noOfYearsExperience.text = widget.data.data()["noOfExp"] == null
        ? "0"
        : widget.data.data()["noOfExp"].toString();

    educationQualification.text = widget.data.data()["eduQual"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(10.0),
      children: [
        SizedBox(height: 25.0),
        _specialityWidget(),
        SizedBox(height: 25),
        TextField(
          controller: noOfYearsExperience,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            enabledBorder: OutlineInputBorder(),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            hintText: "Years of Experience",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 25.0),
        TextField(
          controller: educationQualification,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            enabledBorder: OutlineInputBorder(),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(),
            ),
            hintText: "Education Qualification eg: MD",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(
          height: 25,
        ),
        CustomButton(
          desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
          buttonHeight: 65.0,
          buttonTitle: "Save",
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          buttonRadius: 3.0,
          onPressed: () => _submit(),
        ),
      ],
    );
  }

  Container _specialityWidget() {
    return Container(
      //constraints: BoxConstraints(maxWidth: 500.0),
      //padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Speciality",
          //   style: Theme.of(context).textTheme.headline5.copyWith(
          //         fontSize: 18.0,
          //       ),
          // ),
          SizedBox(height: 10.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(),
            ),
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: speciality,
                elevation: 16,
                style: Theme.of(context).textTheme.headline6,
                hint: Text("Speciality"),
                onChanged: (String newValue) {
                  setState(() {
                    speciality = newValue;
                  });
                },
                items: <String>[
                  "Allergists/Immunologists",
                  "Anesthesiologists",
                  "Cardiologists",
                  "Colon and Rectal Surgeons",
                  "Critical Care Medicine Specialists",
                  "Endocrinologists",
                  "Dermatologists",
                  "Emergency Medicine Specialists",
                  "Emergency Medicine Specialists",
                  "Gastroenterologists",
                  "Geriatric Medicine Specialists",
                  "Hematologists",
                  "Hospice and Palliative Medicine Specialists",
                  "Infectious Disease Specialists",
                  "Internists",
                  "Medical Geneticists",
                  "Nephrologists",
                  "Neurologists",
                  "Obstetricians and Gynecologists",
                  "Oncologists",
                  "Ophthalmologists",
                  "Osteopaths",
                  "Otolaryngologists",
                  "Pathologists",
                  "Pediatricians",
                  "Physiatrists",
                  "Plastic Surgeons",
                  "Podiatrists",
                  "Psychiatrists",
                  "Preventive Medicine Specialists",
                  "Urologists",
                  "General Surgeons",
                  "Sports Medicine Specialists",
                  "Sleep Medicine Specialists",
                  "Radiologists",
                  "Pulmonologists",
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
