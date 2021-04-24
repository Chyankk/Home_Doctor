import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';
import 'package:uuid/uuid.dart' show Uuid;

class PrescriptionLists extends StatelessWidget {
  final String id;

  const PrescriptionLists({this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctors")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("Patients")
            .doc(id)
            .collection("Prescriptions")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data.docs.isEmpty) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: Text(
                      "No Prescriptions provided",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.all(7.0),
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0)),
                  tileColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Text(
                    snapshot.data.docs[index].data()["prescription_Title"],
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: Text(
                    snapshot.data.docs[index]
                            .data()["timestamp"]
                            .toDate()
                            .day
                            .toString() +
                        " " +
                        _getMonth(
                          snapshot.data.docs[index]
                              .data()["timestamp"]
                              .toDate()
                              .month,
                        ) +
                        " " +
                        snapshot.data.docs[index]
                            .data()["timestamp"]
                            .toDate()
                            .year
                            .toString() +
                        " " +
                        (snapshot.data.docs[index]
                                        .data()["timestamp"]
                                        .toDate()
                                        .hour >
                                    12
                                ? (snapshot.data.docs[index]
                                        .data()["timestamp"]
                                        .toDate()
                                        .hour -
                                    12)
                                : snapshot.data.docs[index]
                                    .data()["timestamp"]
                                    .toDate()
                                    .hour)
                            .toString() +
                        ":" +
                        snapshot.data.docs[index]
                            .data()["timestamp"]
                            .toDate()
                            .minute
                            .toString() +
                        " " +
                        _getPeriod(snapshot.data.docs[index]
                            .data()["timestamp"]
                            .toDate()
                            .hour),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _PrescriptionDetail(
                        id: snapshot.data.docs[index].id,
                        patient_Id: id,
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(
                  height: 15.0,
                ),
                itemCount: snapshot.data.docs.length,
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddPrescriptionPage(
                  id: id,
                ))),
      ),
    );
  }
}

class _PrescriptionDetail extends StatelessWidget {
  final String id;
  final String patient_Id;

  const _PrescriptionDetail({this.id, this.patient_Id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Prescription Detail"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctors")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("Patients")
            .doc(patient_Id)
            .collection("Prescriptions")
            .doc(id)
            .snapshots(),
        builder: (context, snapshots) {
          switch (snapshots.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              return ListView(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                shrinkWrap: true,
                padding: EdgeInsets.all(15.0),
                children: [
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Prescription Title:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      snapshots.data.data()["prescription_Title"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Problems/Issues:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      snapshots.data.data()["problems"] == null ||
                              snapshots.data.data()["problems"].isEmpty
                          ? "--"
                          : snapshots.data.data()["problems"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Medicines:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      snapshots.data.data()["medicine"] == null ||
                              snapshots.data.data()["medicine"].isEmpty
                          ? "--"
                          : snapshots.data.data()["medicine"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Tests:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      snapshots.data.data()["test"] == null ||
                              snapshots.data.data()["test"].isEmpty
                          ? "--"
                          : snapshots.data.data()["test"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Exercises:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      snapshots.data.data()["exercise"] == null ||
                              snapshots.data.data()["exercise"].isEmpty
                          ? "--"
                          : snapshots.data.data()["exercise"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Precautions:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      snapshots.data.data()["precaution"] == null ||
                              snapshots.data.data()["precaution"].isEmpty
                          ? "--"
                          : snapshots.data.data()["precaution"],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Suggested Visit Date:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      "${snapshots.data.data()["dateTime"].toDate().day}" +
                          " " +
                          "${_getMonth(snapshots.data.data()["dateTime"].toDate().month)}" +
                          " " +
                          "${snapshots.data.data()["dateTime"].toDate().year}",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  ListTile(
                    tileColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Text(
                      "Prescription Date/Time:",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      "${snapshots.data.data()["timestamp"].toDate().day}" +
                          " " +
                          "${_getMonth(snapshots.data.data()["timestamp"].toDate().month)}" +
                          " " +
                          "${snapshots.data.data()["timestamp"].toDate().year}" +
                          " " +
                          (snapshots.data.data()["timestamp"].toDate().hour > 12
                                  ? (snapshots.data
                                          .data()["timestamp"]
                                          .toDate()
                                          .hour -
                                      12)
                                  : snapshots.data
                                      .data()["timestamp"]
                                      .toDate()
                                      .hour)
                              .toString() +
                          ":" +
                          snapshots.data
                              .data()["timestamp"]
                              .toDate()
                              .minute
                              .toString() +
                          " " +
                          _getPeriod(
                              snapshots.data.data()["timestamp"].toDate().hour),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                ],
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class AddPrescriptionPage extends StatefulWidget {
  final String id;

  const AddPrescriptionPage({Key key, this.id}) : super(key: key);

  @override
  _AddPrescriptionPageState createState() => _AddPrescriptionPageState();
}

class _AddPrescriptionPageState extends State<AddPrescriptionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _testsController = TextEditingController();
  final TextEditingController _precautionController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(Duration(days: 7));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    try {
      showLoading(context);
      final String doctor_Id = FirebaseAuth.instance.currentUser.uid;
      final String uid = Uuid().v4();
      if (_formKey.currentState.validate()) {
        if (_medicineController.text.isNotEmpty ||
            _problemController.text.isNotEmpty ||
            _precautionController.text.isNotEmpty ||
            _testsController.text.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection("Doctors")
              .doc(doctor_Id)
              .collection("Patients")
              .doc(widget.id)
              .collection("Prescriptions")
              .doc(uid)
              .set({
            "prescription_Title": _titleController.text,
            "id": uid,
            "patient_Id": widget.id,
            "doctor_Id": doctor_Id,
            "problems": _problemController.text,
            "medicine": _medicineController.text,
            "test": _testsController.text,
            "precaution": _precautionController.text,
            "exercise": _exerciseController.text,
            "timestamp": DateTime.now(),
            "dateTime": selectedDate,
          });
          await FirebaseFirestore.instance
              .collection("Patients")
              .doc(widget.id)
              .collection("Doctors")
              .doc(doctor_Id)
              .collection("Prescriptions")
              .doc(uid)
              .set({
            "prescription_Title": _titleController.text,
            "id": uid,
            "patient_Id": widget.id,
            "doctor_Id": doctor_Id,
            "problems": _problemController.text,
            "medicine": _medicineController.text,
            "test": _testsController.text,
            "precaution": _precautionController.text,
            "exercise": _exerciseController.text,
            "timestamp": DateTime.now(),
          });
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Prescription Send to Patient"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      Navigator.of(context).pop();
      showAlertDialog(
        context,
        title: "Error",
        content: e.message,
      );
    } on PlatformException catch (e) {
      Navigator.of(context).pop();
      showAlertDialog(
        context,
        title: "Error",
        content: e.message,
      );
    } on Exception catch (e) {
      Navigator.of(context).pop();

      showAlertDialog(
        context,
        title: "Error",
        content: e.toString(),
      );
    }
  }

  Future<void> onRefresh() async {
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Prescription"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: _submit,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            padding: const EdgeInsets.all(15.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: BouncingScrollPhysics(),
            children: [
              Text(
                "Prescription Title:",
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                validator: (String text) {
                  if (text.isEmpty) {
                    return "Title should not be empty";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter Prescription title over here",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "Problems",
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _problemController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter Problems/Issues over here",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "Medicines:",
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _medicineController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter Medicines over here",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "Tests:",
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _testsController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Any suggested tests patients should perform",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "Exercise:",
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _exerciseController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Any suggested exercise patients should perform",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "Precautions:",
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _precautionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Any suggested precautions patients should perform",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
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
                            _getMonth(selectedDate.month) +
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
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 30)),
        initialEntryMode: DatePickerEntryMode.calendar,
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
}

String _getMonth(int month) {
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

String _getPeriod(int hour) {
  return hour >= 12 ? "pm" : "am";
}
