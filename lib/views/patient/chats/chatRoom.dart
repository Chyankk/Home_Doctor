import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/widgets/message_tile.dart';

class PatientChatRoom extends StatelessWidget {
  final String chatRoomId;
  final String patientId;
  final String doctorName;
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  PatientChatRoom({Key key, this.chatRoomId, this.patientId, this.doctorName})
      : super(key: key);

  Widget ChatMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("ChatRoom")
          .doc(chatRoomId)
          .collection("Chats")
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    snapshot.data.docs[index].data()["messsage"],
                    snapshot.data.docs[index].data()["sendBy"] == patientId
                        ? true
                        : false,
                  );
                })
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      final currentUserId = FirebaseAuth.instance.currentUser.uid;
      Map<String, dynamic> messageMap = {
        "messsage": messageController.text,
        "sendBy": currentUserId,
        "time": DateTime.now(),
      };
      addConversationMails(messageMap);
      messageController.clear();
    }
  }

  addConversationMails(messageMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Chats")
        .add(messageMap);
    FirebaseFirestore.instance
        .collection("Chats")
        .doc(chatRoomId)
        .update({"latest_time_message": DateTime.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          doctorName,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            ChatMessagesList(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 65.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    border: Border.all(
                      color: Colors.black54,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Center(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                          onPressed: () => sendMessage(),
                        ),
                        border: InputBorder.none,
                        hintText: "Hello Doctor",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
