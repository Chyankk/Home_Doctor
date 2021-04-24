import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';
import 'package:image_picker/image_picker.dart';

class PatientPersonalEditPage extends StatefulWidget {
  final String contactNumber;
  final String gender;
  final DateTime dob;
  final String bg;
  final String marital_status;
  final double height;
  final double weight;
  final String emergencyContactName;
  final String emergencyContactNumber;
  final String location;
  final String profile_image;

  const PatientPersonalEditPage({
    this.contactNumber,
    this.gender,
    this.dob,
    this.bg,
    this.marital_status,
    this.height,
    this.weight,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.location,
    this.profile_image,
  });

  @override
  _PatientPersonalEditPageState createState() =>
      _PatientPersonalEditPageState();
}

class _PatientPersonalEditPageState extends State<PatientPersonalEditPage> {
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emergencyContactNumberController =
      TextEditingController();
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String gender = "Male";
  String bg = "O-positive";
  String marital_status = "Single";
  double height = 275.0;
  double weight = 120.0;
  DateTime selectedDate = DateTime.now();
  File _image;

  Future _getImage() async {
    return Platform.isAndroid
        ? showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Container(
                  child: new Wrap(
                    children: <Widget>[
                      new ListTile(
                          leading: new Icon(Icons.photo_library),
                          title: new Text('Photo Library'),
                          onTap: () {
                            _getImageFromGallery();
                            Navigator.of(context).pop();
                          }),
                      new ListTile(
                        leading: new Icon(Icons.photo_camera),
                        title: new Text('Camera'),
                        onTap: () {
                          _getImageFromCamer();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    child: new Text('Photo Library'),
                    onPressed: () async {
                      await _getImageFromGallery();
                      Navigator.of(context).pop();
                    },
                    isDefaultAction: true,
                  ),
                  CupertinoActionSheetAction(
                    child: new Text('Camera'),
                    onPressed: () {
                      _getImageFromCamer();
                      Navigator.of(context).pop();
                    },
                    isDefaultAction: true,
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(),
                  isDestructiveAction: true,
                  child: Text(
                    "Cancel",
                  ),
                ),
              );
            },
          );
  }

  Future _getImageFromCamer() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future _getImageFromGallery() async {
    final _pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (_pickedFile != null) {
        _image = new File(_pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    _contactNumberController.text = widget.contactNumber ?? "";
    gender = widget.gender ?? "Male";
    selectedDate = widget.dob ?? DateTime.now();
    bg = widget.bg ?? "O-positive";
    marital_status = widget.marital_status ?? "Single";
    height = widget.height ?? 275.0;
    weight = widget.weight ?? 120.0;
    _emergencyContactNameController.text = widget.emergencyContactName ?? "";
    _emergencyContactNumberController.text =
        widget.emergencyContactNumber ?? "";
    _locationController.text = widget.location ?? "";
  }

  Future<String> _uploadDataToStorage(String currentUserId) async {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child("Patients/$currentUserId/profile/profile.png")
        .putFile(_image);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submit() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser.uid;
      showLoading(context);
      String uploadUrl;
      if (_image != null) {
        uploadUrl =
            await _uploadDataToStorage(FirebaseAuth.instance.currentUser.uid);
      } else {
        uploadUrl = widget.profile_image;
      }
      FirebaseFirestore.instance
          .collection("Patients")
          .doc(currentUserId)
          .update({
        "patient_phone": _contactNumberController.text,
        "patient_gender": gender,
        "patient_dob": selectedDate,
        "patient_bg": bg,
        "patient_marital": marital_status,
        "patient_height": height,
        "patient_weight": weight,
        "patient_emergency_name": _emergencyContactNameController.text,
        "patient_emergency_number": _emergencyContactNumberController.text,
        "patient_location": _locationController.text,
        "profile_image": uploadUrl ?? "",
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
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(15.0),
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 100.0,
                child: _image == null
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.profile_image ?? ""),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(_image),
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 140.0, left: 143.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    //  borderRadius: BorderRadius.circular(90),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.camera_alt),
                    onPressed: _getImage,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Contact Number:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 5.0),
              TextFormField(
                controller: _contactNumberController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.call),
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
                "Gender:",
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
                    value: gender,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(
                        () {
                          gender = newValue;
                        },
                      );
                    },
                    items: <String>[
                      "Male",
                      "Female",
                      "Not prefer to say",
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
                "Date of Birth:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              InkWell(
                onTap: () => _selectDate(context),
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
                        selectedDate.day.toString() +
                            " " +
                            getMonth(selectedDate.month) +
                            " " +
                            selectedDate.year.toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Expanded(child: SizedBox.shrink()),
                      Icon(
                        Icons.event,
                      ),
                    ],
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
                "Blood Group:",
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
                    value: bg,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(
                        () {
                          bg = newValue;
                        },
                      );
                    },
                    items: <String>[
                      "O-positive",
                      "O-negative",
                      "A-positive",
                      "A-negative",
                      "B-positive",
                      "B-negative",
                      "AB-positive",
                      "AB-negative",
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
        SizedBox(height: 7.0),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Marital Status:",
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
                    value: marital_status,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: Theme.of(context).textTheme.headline6,
                    isExpanded: true,
                    onChanged: (String newValue) {
                      setState(
                        () {
                          marital_status = newValue;
                        },
                      );
                    },
                    items: <String>[
                      "Single",
                      "Married",
                      "Committed",
                      "Divorced",
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
        SizedBox(height: 7.0),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Height:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getHeight(context),
                      Slider(
                        value: height,
                        max: 550,
                        min: 20,
                        onChanged: (value) {
                          setState(() {
                            height = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(7.0),
          ),
          padding: EdgeInsets.all(20.0),
        ),
        SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(7.0),
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Weight:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              Center(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${weight.toStringAsFixed(0)} kg",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Slider(
                        value: weight,
                        max: 500,
                        min: 20,
                        onChanged: (value) {
                          setState(() {
                            weight = value;
                          });
                        },
                      ),
                    ],
                  ),
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
                "Emergency Contact Name:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _emergencyContactNameController,
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
                "Emergency Contact Number:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _emergencyContactNumberController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
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
                "Location:",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 7.0),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => getCurrentLocation(),
                    icon: Icon(Icons.my_location_outlined),
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
          buttonTitle: "Update Personal Profile",
          buttonColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          buttonRadius: 3.0,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        var address = await GeocodingPlatform.instance
            .placemarkFromCoordinates(position.latitude, position.longitude);

        print(address.first.locality);
        _locationController.text = address.first.locality;
        setState(() {});
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("Location Permission Denied"),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Text getHeight(BuildContext context) {
    print(height);
    final double ft = height / 30.48;
    print(ft);
    print(ft.floor());
    final double inch = (ft - ft.floor()) * 12;
    return Text(
      "${ft.floor()} ft ${inch.toStringAsFixed(2)} inch",
      style: Theme.of(context).textTheme.headline6,
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1945),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData(
                backgroundColor: Theme.of(context).colorScheme.primary,
                primaryColor: Colors.orangeAccent,
                disabledColor: Colors.brown,
                textTheme: TextTheme(
                  headline1: TextStyle(color: Colors.black),
                  headline2: TextStyle(color: Colors.black),
                  headline3: TextStyle(color: Colors.black),
                  headline4: TextStyle(color: Colors.black),
                  headline5: TextStyle(color: Colors.black),
                  headline6: TextStyle(color: Colors.black),
                  subtitle1: TextStyle(fontSize: 18, color: Colors.black),
                  subtitle2: TextStyle(color: Colors.black),
                  bodyText1: TextStyle(color: Colors.black),
                  bodyText2: TextStyle(color: Colors.black),
                ),
                accentColor: Colors.yellow),
            child: child,
          );
        });
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  String getMonth(int month) {
    switch (month) {
      case 1:
        return "Januaury";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June ";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }
}
