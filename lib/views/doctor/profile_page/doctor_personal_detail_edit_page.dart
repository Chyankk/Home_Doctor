import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';
import 'package:image_picker/image_picker.dart';

class DoctorPersonalDetails extends StatefulWidget {
  final String currentUserId;
  final DocumentSnapshot data;

  const DoctorPersonalDetails({Key key, this.currentUserId, this.data})
      : super(key: key);

  @override
  _DoctorPersonalDetailsState createState() => _DoctorPersonalDetailsState();
}

class _DoctorPersonalDetailsState extends State<DoctorPersonalDetails> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();

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

  Future<void> _submit() async {
    try {
      showLoading(context);
      String uploadUrl;
      if (_image != null) {
        uploadUrl = await _uploadDataToStorage(widget.currentUserId);
      } else {
        uploadUrl = widget.data.data()["profile_image"];
      }
      await FirebaseFirestore.instance
          .collection("Doctors")
          .doc(widget.currentUserId)
          .update({
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "email": emailController.text,
        "phone": phoneNumberController.text,
        "profile_image": uploadUrl ?? "",
        "location": locationController.text,
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

  Future<String> _uploadDataToStorage(String currentUserId) async {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child("Doctors/$currentUserId/profile/profile.png")
        .putFile(_image);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() {
    firstNameController.text = widget.data.data()["first_name"] ?? "";
    lastNameController.text = widget.data.data()["last_name"] ?? "";
    emailController.text = widget.data.data()["email"] ?? "";
    phoneNumberController.text =
        widget.data.data()["phone"] == null ? "" : widget.data.data()["phone"];
    locationController.text = widget.data.data()["location"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(10.0),
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
                            image: NetworkImage(
                                widget.data.data()["profile_image"] ?? ""),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              _image,
                            ),
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
        TextField(
          controller: firstNameController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
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
            hintText: "First Name",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 15.0),
        TextField(
          controller: lastNameController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
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
            hintText: "Last Name",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 15.0),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
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
            hintText: "email",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 15.0),
        TextField(
          controller: phoneNumberController,
          keyboardType: TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.phone),
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
            hintText: "Phone No",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 15.0),
        TextField(
          controller: locationController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined),
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
            hintText: "Location",
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 15.0),
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
    );
  }
}
