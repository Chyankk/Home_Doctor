import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homedoctor/views/patient/appointment_page/patient_appointment_page.dart';
import 'package:homedoctor/views/patient/my_doctors/patient_my_doctor_page.dart';
import 'package:homedoctor/views/patient/profile_page/patient_profile_page.dart';
import 'package:homedoctor/views/patient/transactions/transactions.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientAppDrawer extends StatefulWidget {
  @override
  _PatientAppDrawerState createState() => _PatientAppDrawerState();
}

class _PatientAppDrawerState extends State<PatientAppDrawer> {
  String emergencyContact = "";
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut() async {
    final bool didRequestSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you wish to Logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    );
    if (didRequestSignOut == true) {
      _signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Patients")
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    print(snapshot.data.data()["patient_emergency_number"]);
                    emergencyContact =
                        snapshot.data.data()["patient_emergency_number"] ?? "";

                    print(emergencyContact);
                    return ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      leading: snapshot.data.data()["profile_image"] == null
                          ? FaIcon(
                              FontAwesomeIcons.user,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                snapshot.data.data()["profile_image"],
                              ),
                            ),
                      title: Text(
                        snapshot.data["patient_name"],
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      subtitle: Text(
                        "View and edit profile",
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PatientProfile(),
                        ),
                      ),
                    );
                  default:
                    return Center(child: CircularProgressIndicator());
                }
              }),
          Divider(thickness: 1.0),
          DrawerTileWidget(
            leadingIcon: Icon(
              Icons.today,
              color: Theme.of(context).colorScheme.primary,
            ),
            tileTitle: "Appointments",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PatientAppointmentTabs(),
              ),
            ),
          ),
          DrawerTileWidget(
            leadingIcon: FaIcon(
              FontAwesomeIcons.userMd,
              color: Theme.of(context).colorScheme.primary,
            ),
            tileTitle: "My Doctors",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PatientFavoriteDoctorPage(),
              ),
            ),
          ),
          DrawerTileWidget(
            leadingIcon: FaIcon(
              FontAwesomeIcons.receipt,
              color: Theme.of(context).colorScheme.primary,
            ),
            tileTitle: "Transactions",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Transactions(),
              ),
            ),
          ),
          DrawerTileWidget(
            leadingIcon: FaIcon(
              FontAwesomeIcons.filePrescription,
              color: Theme.of(context).colorScheme.primary,
            ),
            tileTitle: "Prescriptions",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyDoctors(),
              ),
            ),
          ),
          Divider(thickness: 3.0),
          DrawerTileWidget(
            leadingIcon: Icon(
              Icons.logout,
            ),
            tileTitle: "Logout",
            onPressed: _confirmSignOut,
          ),
          Divider(),
          SizedBox(
            height: 10.0,
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: CustomButton(
              desktopMaxWidth: MediaQuery.of(context).size.width / 1.1,
              buttonHeight: 65.0,
              buttonTitle: "Emergency",
              buttonColor: Colors.redAccent,
              textColor: Colors.white,
              buttonRadius: 3.0,
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.all(7.0),
                      children: [
                        emergencyContact.isNotEmpty
                            ? ListTile(
                                onTap: () async =>
                                    await launch("tel:$emergencyContact}"),
                                title: Text("Call Emergency Contact"),
                              )
                            : Container(),
                        ListTile(
                          onTap: () async => await launch("tel:102"),
                          title: Text("Call Emergency Services"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Prescriptions",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Patients")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection("Doctors")
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.data.docs.isEmpty) {
                  return Center(
                    child: Text("You have not contacted any Doctors yet."),
                  );
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 13.0,
                      crossAxisSpacing: 13.0),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(7.0),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) => FutureBuilder<
                          DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("Doctors")
                          .doc(snapshot.data.docs[index].id)
                          .get(),
                      builder: (context, future) {
                        switch (future.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          case ConnectionState.active:
                          case ConnectionState.done:
                            if (snapshot.data.docs.isEmpty) {
                              return Center(
                                child: Text("You have no Prescription"),
                              );
                            }
                            return InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => _PrescriptionLists(
                                    doctor_Id: snapshot.data.docs[index].id,
                                    doctor_Name: snapshot.data.docs[index]
                                        .data()["doctor_name"],
                                  ),
                                ),
                              ),
                              child: Container(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 45.0,
                                        backgroundImage: NetworkImage(future
                                                .data
                                                .data()["profile_image"] ??
                                            ""),
                                      ),
                                      SizedBox(
                                        height: 3.0,
                                      ),
                                      Center(
                                        child: Text(
                                          "Dr. " +
                                              snapshot.data.docs[index]
                                                  .data()["doctor_name"],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          default:
                            return Center(child: CircularProgressIndicator());
                        }
                      }),
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class _PrescriptionLists extends StatelessWidget {
  final String doctor_Id;
  final String doctor_Name;

  const _PrescriptionLists({this.doctor_Id, this.doctor_Name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Dr. ${doctor_Name}",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctors")
            .doc(doctor_Id)
            .collection("Patients")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("Prescriptions")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data.docs.isEmpty) {
            return Center(
              child: Text(
                "No Prescriptions Available",
                style: Theme.of(context).textTheme.headline6,
              ),
            );
          }
          return ListView.separated(
            itemCount: snapshot.data.docs.length,
            separatorBuilder: (context, index) => SizedBox(height: 7.0),
            padding: EdgeInsets.all(7.0),
            itemBuilder: (context, index) => ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => _PrescriptionDetail(
                    prescription_Id: snapshot.data.docs[index].id,
                    doctor_Id: doctor_Id,
                  ),
                ),
              ),
              tileColor: Theme.of(context).scaffoldBackgroundColor,
              title:
                  Text(snapshot.data.docs[index].data()["prescription_Title"]),
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
                    ((snapshot.data.docs[index]
                                        .data()["timestamp"]
                                        .toDate()
                                        .minute <
                                    10) ==
                                true
                            ? "0${snapshot.data.docs[index].data()["timestamp"].toDate().minute}"
                            : snapshot.data.docs[index]
                                .data()["timestamp"]
                                .toDate()
                                .minute
                                .toString())
                        .toString() +
                    " " +
                    _getPeriod(snapshot.data.docs[index]
                        .data()["timestamp"]
                        .toDate()
                        .hour),
              ),
            ),
          );
        },
      ),
    );
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
}

class _PrescriptionDetail extends StatelessWidget {
  final String prescription_Id;
  final String doctor_Id;

  const _PrescriptionDetail({this.prescription_Id, this.doctor_Id});

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
            .doc(doctor_Id)
            .collection("Patients")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("Prescriptions")
            .doc(prescription_Id)
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

class DrawerTileWidget extends StatelessWidget {
  final Widget leadingIcon;
  final String tileTitle;
  final VoidCallback onPressed;

  const DrawerTileWidget({
    Key key,
    @required this.leadingIcon,
    @required this.tileTitle,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon,
      title: Text(
        tileTitle,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: onPressed,
    );
  }
}
