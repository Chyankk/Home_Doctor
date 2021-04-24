import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class ForgortPasswordPage extends StatefulWidget {
  @override
  _ForgortPasswordPageState createState() => _ForgortPasswordPageState();
}

class _ForgortPasswordPageState extends State<ForgortPasswordPage> {
  _updateState(String value) {
    setState(() {});
  }

  final TextEditingController _emailController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();

  String get _email => _emailController.text;

  Future<void> _submit() async {
    try {
      showLoading(context);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      Navigator.pop(context);
      showAlertDialog(context,
          title: "Forgot Password Successful",
          content: "Password Reset link is sent on your email.", onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    } on FirebaseException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Login Error", content: E.message);
    } on PlatformException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Login Error", content: E.message);
    } catch (e) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Login Error", content: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                "Forgot Password",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 50.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: [AutofillHints.email],
                controller: _emailController,
                focusNode: _emailFocusNode,
                onChanged: _updateState,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  enabledBorder: OutlineInputBorder(),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  hintText: "email",
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20.0),
              CustomButton(
                desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
                buttonHeight: 65.0,
                buttonTitle: "Send the link on Email",
                buttonColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                buttonRadius: 3.0,
                onPressed: _submit,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
