import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class LatestRates extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   label: Text(
      //     "Update Rates",
      //     style: Theme.of(context)
      //         .textTheme
      //         .headline6
      //         .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      //   ),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   icon: Icon(Icons.edit, color: Colors.white),
      // ),
      body: Container(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Doctors")
              .doc(currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                return ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.all(10.0),
                  children: [
                    SizedBox(
                      height: 7.0,
                    ),
                    Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(
                          "Current Rate (₹/hr)",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        trailing: Text(
                          "₹" +
                              (snapshot.data.data()["rate"] == null ||
                                          snapshot.data.data()["rate"].isEmpty
                                      ? 0
                                      : snapshot.data.data()["rate"])
                                  .toString(),
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      controller: textEditingController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: false,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: "Updated Rate",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    CustomButton(
                      desktopMaxWidth: MediaQuery.of(context).size.width / 2.7,
                      buttonHeight: 50.0,
                      buttonTitle: "Update Rate",
                      textSize: 19.0,
                      buttonColor: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                      buttonRadius: 3.0,
                      onPressed: () async {
                        final String uid = Uuid().v4();

                        await FirebaseFirestore.instance
                            .collection("Doctors")
                            .doc(currentUserId)
                            .collection("Rates")
                            .doc(uid)
                            .set({
                          "id": uid,
                          "timestamp": DateTime.now(),
                          "rate": textEditingController.text,
                        });
                        await FirebaseFirestore.instance
                            .collection("Doctors")
                            .doc(currentUserId)
                            .update({
                          "rate": textEditingController.text ?? 0,
                          "latest_time": DateTime.now(),
                        });
                        textEditingController.clear();
                      },
                    ),
                  ],
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
