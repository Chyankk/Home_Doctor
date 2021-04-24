import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/rating_stars.dart';
import 'package:uuid/uuid.dart';

class PatientFeedbackPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  PatientFeedbackPage({@required this.documentSnapshot});

  @override
  _PatientFeedbackPageState createState() => _PatientFeedbackPageState();
}

class _PatientFeedbackPageState extends State<PatientFeedbackPage> {
  TextEditingController _feedbackController = TextEditingController();

  double rating = 3.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Transactions",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          primary: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(19.0),
          children: [
            Center(
              child: StarRating(
                rating: rating,
                onRatingChanged: (rating) =>
                    setState(() => this.rating = rating),
                starCount: 5,
                size: 45.0,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            TextField(
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              controller: _feedbackController,
              maxLines: 10,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "I visited to the doctor because ..."),
            ),
            SizedBox(
              height: 15.0,
            ),
            CustomButton(
              desktopMaxWidth: MediaQuery.of(context).size.width / 2.7,
              buttonHeight: 50.0,
              buttonTitle: "Give Feedback",
              textSize: 19.0,
              buttonColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              buttonRadius: 3.0,
              onPressed: () async {
                final id = Uuid().v4();
                final String patientId = FirebaseAuth.instance.currentUser.uid;
                final DocumentSnapshot currentUser = await FirebaseFirestore
                    .instance
                    .collection("Patients")
                    .doc(patientId)
                    .get();
                await FirebaseFirestore.instance
                    .collection("Doctors")
                    .doc(widget.documentSnapshot.id)
                    .collection("Feedbacks")
                    .doc(id)
                    .set({
                  "id": id,
                  "patient_Id": patientId,
                  "patient_name": currentUser.data()["patient_name"],
                  "rating": rating,
                  "feedback": _feedbackController.text ?? "",
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Thank you for the feedback")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
