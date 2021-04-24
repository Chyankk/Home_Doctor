import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/patient/doctor_detail_page/patient_doctor_detail_page.dart';

class PatientFavoriteDoctorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "My Doctors",
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Patients")
              .doc(currentUserId)
              .collection("Favorite Doctors")
              .snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                final List<QueryDocumentSnapshot> query = snapshot.data.docs;
                if (query.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _NoDataWidget(),
                  );
                }
                return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(7.0),
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("Doctors")
                            .doc(query[index].id)
                            .get(),
                        builder: (context, future) {
                          switch (future.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(child: CircularProgressIndicator());
                            case ConnectionState.active:
                            case ConnectionState.done:
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    "Dr. " +
                                        future.data["first_name"] +
                                        " " +
                                        future.data["last_name"],
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                  subtitle: Text(
                                    future.data["location"] ?? "---",
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PatientDoctorDetailPage(
                                                documentSnapshot: future.data,
                                              ))),
                                ),
                              );
                            default:
                              return Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: query.length);

              default:
                return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class _NoDataWidget extends StatelessWidget {
  const _NoDataWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          "https://cdn.dribbble.com/users/1355613/screenshots/6637974/attachments/1418349/doctor.jpg?compress=1&resize=800x600",
          filterQuality: FilterQuality.high,
        ),
        Text(
          "You have no bookmarked doctors",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5.copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 5.0),
        Text(
          "Favourite a doctor for having an easy access to them whenever in need",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }
}
