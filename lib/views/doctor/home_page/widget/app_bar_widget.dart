import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorAppBar extends StatefulWidget {
  @override
  _DoctorAppBarState createState() => _DoctorAppBarState();
}

class _DoctorAppBarState extends State<DoctorAppBar> {
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut() async {
    final bool didRequestSignOut = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you wish to Logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    );
    if (didRequestSignOut == true) {
      _signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          Center(
            child: ListTile(
              title: Text(
                "Home Doctor",
                style: Theme.of(context).textTheme.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          // _DrawerTileWidget(
          //   leadingIcon: Icon(
          //     Icons.settings,
          //   ),
          //   tileTitle: "Settings",
          //   onPressed: () {},
          // ),
          // _DrawerTileWidget(
          //   leadingIcon: Icon(
          //     Icons.star_border_sharp,
          //   ),
          //   tileTitle: "Like us?",
          //   onPressed: () {},
          // ),
          _DrawerTileWidget(
            leadingIcon: Icon(
              Icons.logout,
            ),
            tileTitle: "Logout",
            onPressed: _confirmSignOut,
          ),
        ],
      ),
    );
  }
}

class _DrawerTileWidget extends StatelessWidget {
  final Widget leadingIcon;
  final String tileTitle;
  final VoidCallback onPressed;

  const _DrawerTileWidget({
    Key key,
    @required this.leadingIcon,
    @required this.tileTitle,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon,
      title: Text(
        tileTitle,
        style: Theme.of(context).textTheme.headline6,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: onPressed,
    );
  }
}
