import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryRates extends StatefulWidget {
  @override
  _HistoryRatesState createState() => _HistoryRatesState();
}

class _HistoryRatesState extends State<HistoryRates> {
  final String currentUserId = FirebaseAuth.instance.currentUser.uid;

  Future<void> onRefresh() async {
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Doctors")
              .doc(currentUserId)
              .collection("Rates")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.data.size == 0) {
                  return Center(
                    child: Text(
                      "You have not set any Transaction fee yet",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data.size,
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => Card(
                    elevation: 5.0,
                    margin: EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    child: ListTile(
                      trailing: Text(
                        "₹ " +
                            (snapshot.data.docs[index]
                                        .data()["rate"]
                                        .toString()
                                        .isEmpty
                                    ? "0"
                                    : snapshot.data.docs[index]
                                        .data()["rate"]
                                        .toString())
                                .toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      title: Text(
                        snapshot.data.docs[index]
                                .data()["timestamp"]
                                .toDate()
                                .day
                                .toString() +
                            " " +
                            getMonth(snapshot.data.docs[index]
                                .data()["timestamp"]
                                .toDate()
                                .month) +
                            " " +
                            snapshot.data.docs[index]
                                .data()["timestamp"]
                                .toDate()
                                .year
                                .toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          },
        ),
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
      default:
        return "April";
    }
  }
}
