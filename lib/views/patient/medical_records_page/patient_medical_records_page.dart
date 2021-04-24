import 'package:flutter/material.dart';

class PatientMedicalRecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Medical Records",
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _NoDataWidget(),
      ),
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
          "https://cdn.dribbble.com/users/429131/screenshots/4901308/amazondynamodb.png?compress=1&resize=800x600",
          filterQuality: FilterQuality.high,
        ),
        Text(
          "Add a medical records.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5.copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 10.0),
        Text(
          "A detail health history helps a doctors diagnose you better",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Colors.black38,
              ),
        ),
      ],
    );
  }
}
