import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homedoctor/views/patient/all_doctos_pages/search_all_doctors_page.dart';
import 'package:homedoctor/views/patient/home_page/widget/app_drawer.dart';
import 'package:homedoctor/views/patient/home_page/widget/doctor_custom_tile_widget.dart';
import 'package:homedoctor/widgets/custom_outline_button.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final TextEditingController textEditingController = TextEditingController();

  Future<void> getCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        var address = await GeocodingPlatform.instance
            .placemarkFromCoordinates(position.latitude, position.longitude);

        print(address.first.locality);
        textEditingController.text = address.first.locality;
        setState(() {});
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Error"),
            content: Text("Location Permission Denied"),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1.0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          "Home Doctor",
          style: Theme.of(context).textTheme.headline6.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: ListTile(
            title: TextField(
              controller: textEditingController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "location",
                prefixIcon: Icon(Icons.location_on_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: () async {
                    await getCurrentLocation();
                  },
                ),
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
        ),
      ),
      drawer: PatientAppDrawer(),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 10),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: [1, 2, 3].map(
              (i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                              image: AssetImage(
                                "assets/carousel/${i}.jpeg",
                                //  scale: 1,
                              ),
                              fit: BoxFit.cover)),
                    );
                  },
                );
              },
            ).toList(),
          ),
          SizedBox(height: 20.0),
          Text(
            "Find Doctors Available Near You",
            style: Theme.of(context).textTheme.headline6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 5.0),
          Text(
            "Book assured appointment even during the COVID-19 pandemic",
            style: Theme.of(context).textTheme.subtitle2,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Doctors")
                  .where("location", isEqualTo: textEditingController.text)
                  .limit(6)
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
                    return SizedBox(
                      height: 300,
                      child: GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: snapshot.data.docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 300,
                        ),
                        itemBuilder: (context, index) => Container(
                          width: 300,
                          padding: EdgeInsets.all(10.0),
                          child: DoctorCustomTileWidget(
                            documentSnapshot: snapshot.data.docs[index],
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
          CustomOutlineButton(
            desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
            buttonHeight: 60.0,
            textColor: Colors.black,
            buttonTitle: "See All Doctors",
            borderColor: Colors.black,
            textWeight: FontWeight.w500,
            buttonBorderWidth: 1.5,
            buttonRadius: 3.0,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SellAllDoctorsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
