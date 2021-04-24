import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/patient/chats/chatRoom.dart';

class Patient_Chat_List extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("ChatRoom")
              .orderBy("latest_time_message", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                final currentUserId = FirebaseAuth.instance.currentUser.uid;
                final List<QueryDocumentSnapshot> query = snapshot.data.docs;
                query.removeWhere(
                    (element) => element.data()["patient_Id"] != currentUserId);
                return ListView.separated(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  scrollDirection: Axis.vertical,
                  itemCount: query.length,
                  separatorBuilder: (context, index) => Divider(
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) => ListTile(
                    trailing: getMessageTiming(
                      context,
                      query[index].data()["latest_time_message"].toDate(),
                    ),
                    title: Text(
                      query[index].data()["doctor_name"],
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    subtitle: Text(
                      query[index].data()["doctor_email"],
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PatientChatRoom(
                          chatRoomId: query[index].id,
                          patientId: query[index].data()["patient_Id"],
                          doctorName: query[index].data()["doctor_name"],
                        ),
                      ),
                    ),
                  ),
                );
              default:
                return Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
    );
  }

  Text getMessageTiming(BuildContext context, DateTime latest_message_time) {
    DateTime date = latest_message_time;
    DateTime now = DateTime.now();
    Duration duration = now.difference(date);
    if (duration.inDays > 365) {
      return Text(
        (duration.inDays / 365).floor().toString() + " years ago",
        style: Theme.of(context).textTheme.subtitle2,
      );
    }
    if (duration.inDays > 31) {
      return Text(
        (duration.inDays / 31).floor().toString() + " months ago",
        style: Theme.of(context).textTheme.subtitle2,
      );
    }
    if (duration.inDays > 0) {
      return Text(
        duration.inDays.toString() + " days ago",
        style: Theme.of(context).textTheme.subtitle2,
      );
    }
    if (duration.inMinutes > 60) {
      return Text(
        duration.inHours.toString() + " hours ago",
        style: Theme.of(context).textTheme.subtitle2,
      );
    }

    return Text(
      duration.inMinutes.toString() + " minutes Ago",
      style: Theme.of(context).textTheme.subtitle2,
    );
  }
}
