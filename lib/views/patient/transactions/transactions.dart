import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Transactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      appBar: AppBar(
        title: Text(
          "Transactions",
          style: Theme
              .of(context)
              .textTheme
              .headline6
              .copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Patients")
            .doc(currentUserId)
            .collection("Appointments")
            .orderBy("appointment_time", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data.docs.isEmpty) {
            return Center(
              child: Text("You have not made any transactions yet"),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(7.0),
            itemBuilder: (context, index) =>
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    onTap: () =>
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TransactionDetail(
                                  id: snapshot.data.docs[index].id,
                                ),
                          ),
                        ),
                    title: Text(
                      "Dr. " + snapshot.data.docs[index].data()["doctor_name"],
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline6
                          .copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data.docs[index]
                              .data()["appointment_time"]
                              .toDate()
                              .toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle1,
                        ),
                        SizedBox(
                          height: 1.0,
                        ),
                        Text(
                          "₹ " +
                              snapshot.data.docs[index]
                                  .data()["payment_amount"]
                                  .toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline6
                              .copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
            separatorBuilder: (context, index) => Divider(),
            itemCount: snapshot.data.size,
          );
        },
      ),
    );
  }
}

class TransactionDetail extends StatelessWidget {
  final String id;

  TransactionDetail({this.id});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Transaction Detail",
          style: Theme
              .of(context)
              .textTheme
              .headline6
              .copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Patients")
            .doc(currentUserId)
            .collection("Appointments")
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          return ListView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            children: [
              ListTile(
                title: Text(
                  "Doctor Name:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  snapshot.data.data()["doctor_name"],
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Clinic:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  snapshot.data.data()["doctor_clinic"] ?? "Clinic Name",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Date:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  snapshot.data
                      .data()["appointment_time"]
                      .toDate()
                      .day
                      .toString() +
                      " " +
                      getMonth(
                        snapshot.data.data()["appointment_time"]
                            .toDate()
                            .month,
                      ) +
                      " " +
                      snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .year
                          .toString(),
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Time:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  getHour(snapshot.data
                      .data()["appointment_time"]
                      .toDate()
                      .hour) +
                      " : " +
                      ((snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .minute < 10) == true ?"0${snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .minute}" : snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .minute).toString()
                      +
                      " " +
                      getPeriod(snapshot.data
                          .data()["appointment_time"]
                          .toDate()
                          .hour),
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Purpose of Visit:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  snapshot.data.data()["purpose"],
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Type of Visit:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  snapshot.data.data()["typeOfVisit"],
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Payment Method:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: _paymentMethod(
                    snapshot.data.data()["payment_method"], context),
              ),
              Divider(
                thickness: 1.0,
              ),
              ListTile(
                title: Text(
                  "Payment Amount:",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "₹" + snapshot.data.data()["payment_amount"].toString(),
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
              ),
              Divider(
                thickness: 1.0,
              ),
            ],
          );
        },
      ),
    );
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

  Text _paymentMethod(bool value, BuildContext context) {
    if (value == true) {
      return Text(
        "Online",
        style: Theme
            .of(context)
            .textTheme
            .headline6,
      );
    } else {
      return Text(
        "In-Clinic",
        style: Theme
            .of(context)
            .textTheme
            .headline6,
      );
    }
  }

  String getPeriod(int hour) {
    return hour >= 12 ? "pm" : "am";
  }

  String getHour(int hour) {
    return hour > 12 ? 0.toString() + (hour - 12).toString() : hour.toString();
  }
}
