import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

import '../../../widgets/showAlertDialog.dart';

class DoctorHospitalDetails extends StatefulWidget {
  final String currentUserId;
  final DocumentSnapshot data;

  DoctorHospitalDetails({@required this.currentUserId, @required this.data});

  @override
  _DoctorHospitalDetailsState createState() => _DoctorHospitalDetailsState();
}

class _DoctorHospitalDetailsState extends State<DoctorHospitalDetails> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _maxPatientsController = TextEditingController();
  TimeOfDay selectedTime1;

  TimeOfDay selectedTime2;

  List<dynamic> availableDays = [];

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      try {
        showLoading(context);

        final dateTime = DateTime(
          2021,
          1,
          1,
          selectedTime1.hour,
          selectedTime1.minute,
          0,
        );
        final dateTime1 = DateTime(
          2021,
          1,
          1,
          selectedTime2.hour,
          selectedTime2.minute,
          0,
        );
        if (dateTime1.isBefore(dateTime)) {
          Navigator.of(context).pop();
          showAlertDialog(
            context,
            title: "Error",
            content: "End Time should always be after the start time.",
          );
        } else if (availableDays.isEmpty) {
          Navigator.of(context).pop();
          showAlertDialog(
            context,
            title: "Error",
            content: "Doctor should be present atleast for a single day",
          );
        } else {
          await FirebaseFirestore.instance
              .collection("Doctors")
              .doc(widget.currentUserId)
              .update({
            "clinic_name": _nameController.text,
            "clinic_location": _addressController.text,
            "start_time": DateTime(
                2021, 10, 21, selectedTime1.hour, selectedTime1.minute),
            "end_time": DateTime(
                2021, 10, 21, selectedTime2.hour, selectedTime2.minute),
            "available_days": availableDays,
            "maxPatientsPerDay": int.parse(_maxPatientsController.text),
          });
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        Navigator.of(context).pop();

        showAlertDialog(
          context,
          title: "Error",
          content: e.toString(),
        );
      }
    }
  }

  getData() {
    _nameController.text = widget.data.data()["clinic_name"];
    _addressController.text = widget.data.data()["clinic_location"] ?? "";
    availableDays = widget.data.data()["available_days"] ?? [];
    selectedTime1 = widget.data.data()["start_time"] != null
        ? TimeOfDay.fromDateTime(widget.data.data()["start_time"].toDate())
        : TimeOfDay.now();
    selectedTime2 = widget.data.data()["end_time"] != null
        ? TimeOfDay.fromDateTime(widget.data.data()["end_time"].toDate())
        : TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));
    _maxPatientsController.text =
        widget.data.data()["maxPatientsPerDay"].toString() ?? 0;
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(11.0),
        scrollDirection: Axis.vertical,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Hospital Name",
            ),
            validator: (String text) {
              if (text.isEmpty) {
                return "Name should not be empty";
              }
            },
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _addressController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Hospital Address",
            ),
            maxLines: 3,
            validator: (String text) {
              if (text.isEmpty) {
                return "Address should not be empty";
              }
            },
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _maxPatientsController,
            keyboardType:
                TextInputType.numberWithOptions(signed: false, decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Max Patients per day",
            ),
            validator: (String text) {
              if (int.parse(text) < 1) {
                return "Patients number should not be less than 1";
              }
            },
          ),
          Divider(thickness: 1.0),
          SizedBox(
            height: 20.0,
          ),
          Text(
            "Start Time",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 10.0),
          InkWell(
            onTap: () => _selectTime1(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 7.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Text(
                    (selectedTime1.hour > 12
                                ? "0${selectedTime1.hour - 12}"
                                : selectedTime1.hour)
                            .toString() +
                        " : " +
                        ((selectedTime1.minute < 10) == true
                                ? "0${selectedTime1.minute}"
                                : selectedTime1.minute.toString())
                            .toString() +
                        " " +
                        getPeriod(selectedTime1.period),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Expanded(child: SizedBox.shrink()),
                  Icon(
                    Icons.alarm,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            "End Time",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 10.0),
          InkWell(
            onTap: () => _selectTime2(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 7.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Text(
                    (selectedTime2.hour > 12
                                ? "0${selectedTime2.hour - 12}"
                                : selectedTime2.hour)
                            .toString() +
                        " : " +
                        ((selectedTime2.minute < 10) == true
                            ? "0${selectedTime2.minute}"
                            : selectedTime2.minute.toString())
                            .toString() +
                        " " +
                        getPeriod(selectedTime2.period),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Expanded(child: SizedBox.shrink()),
                  Icon(
                    Icons.alarm,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            "Available Days",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 10.0),
          Container(
            height: 65.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                InkWell(
                  onTap: () {
                    if (availableDays.contains(7)) {
                      availableDays.remove(7);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(7);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(7)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(7)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Sun",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(7)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    if (availableDays.contains(1)) {
                      availableDays.remove(1);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(1);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(1)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(1)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Mon",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(1)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    if (availableDays.contains(2)) {
                      availableDays.remove(2);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(2);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(2)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(2)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Tue",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(2)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    if (availableDays.contains(3)) {
                      availableDays.remove(3);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(3);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(3)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(3)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Wed",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(3)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    if (availableDays.contains(4)) {
                      availableDays.remove(4);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(4);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(4)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(4)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Thu",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(4)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    if (availableDays.contains(5)) {
                      availableDays.remove(5);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(5);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(5)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(5)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Fri",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(5)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    if (availableDays.contains(6)) {
                      availableDays.remove(6);
                      setState(() {});
                    } else {
                      setState(() {
                        availableDays.add(6);
                      });
                    }
                  },
                  child: Container(
                    width: 55.0,
                    height: 55.0,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: availableDays.contains(6)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: availableDays.contains(6)
                            ? Colors.transparent
                            : Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Sat",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: availableDays.contains(6)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          CustomButton(
            desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
            buttonHeight: 65.0,
            buttonTitle: "Save",
            buttonColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            buttonRadius: 3.0,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime1(BuildContext context) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime1,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (picked_s != null && picked_s != selectedTime1)
      setState(() {
        selectedTime1 = picked_s;
      });
  }

  Future<void> _selectTime2(BuildContext context) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime2,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });

    if (picked_s != null && picked_s != selectedTime2)
      setState(() {
        selectedTime2 = picked_s;
      });
  }

  String getPeriod(DayPeriod dayPeriod) {
    switch (dayPeriod.index) {
      case 0:
        return "am";
      case 1:
        return "pm";
      default:
        return "pm";
    }
  }
}
