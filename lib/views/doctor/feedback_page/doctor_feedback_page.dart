import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/widgets/rating_stars.dart';

class DoctorFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Feedback",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Doctors")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection("Feedbacks")
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.data.size == 0) {
                  return Scaffold(
                    body: Center(
                      child: Image.network(
                        "https://cdn.dribbble.com/users/3247214/screenshots/11897244/media/87e8b350b49019a01a025a0809ef847e.jpg?compress=1&resize=800x600",
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => Card(
                    elevation: 2.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRating(
                            mainAxisAlignment: MainAxisAlignment.start,
                            size: 20.0,
                            onRatingChanged: null,
                            rating: snapshot.data.docs[index].data()["rating"],
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            snapshot.data.docs[index].data()["feedback"],
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  itemCount: snapshot.data.size,
                );
              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
