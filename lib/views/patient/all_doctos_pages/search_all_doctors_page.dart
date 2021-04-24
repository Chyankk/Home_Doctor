import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/views/patient/home_page/widget/doctor_custom_tile_widget.dart';

class SellAllDoctorsPage extends StatefulWidget {
  @override
  _SellAllDoctorsPageState createState() => _SellAllDoctorsPageState();
}

class _SellAllDoctorsPageState extends State<SellAllDoctorsPage> {
  TextEditingController _searchController = TextEditingController();
  Future resultsLoaded;
  List<QueryDocumentSnapshot> _allResults = [];
  List _resultsList = [];

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    searchResultsList();
    print(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.clear();
    super.dispose();
  }

  getAllDoctorsList() async {
    var data = await FirebaseFirestore.instance
        .collection("Doctors")
        .orderBy(
          "first_name",
          descending: false,
        )
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
    return "complete";
  }

  @override
  void didChangeDependencies() {
    resultsLoaded = getAllDoctorsList();
    super.didChangeDependencies();
  }

  searchResultsList() {
    var showResults = [];
    if (_searchController.text != "") {
      //We have search params
      for (var search in _allResults) {
        var title = search.data()["first_name"].toString().toLowerCase() +
            search.data()["last_name"].toString().toLowerCase() +
            (search.data()["speciality"] ?? "").toString().toLowerCase();
        if (title.contains(_searchController.text.toLowerCase())) {
          showResults.add(search);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 65.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      hintText: "Search Doctors",
                      hintStyle: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  scrollDirection: Axis.vertical,
                  itemCount: _resultsList.length,
                  itemBuilder: (context, index) => DoctorCustomTileWidget(
                    documentSnapshot: _resultsList[index],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
