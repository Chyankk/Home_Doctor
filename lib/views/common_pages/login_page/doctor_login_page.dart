import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/views/common_pages/forgot_password/forgot_password_page.dart';
import 'package:homedoctor/views/common_pages/login_page/login_validations.dart';
import 'package:homedoctor/views/common_pages/widgets/login_exceptions.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class DoctorLoginPage extends StatefulWidget with EmailAndPasswordValidators {
  @override
  _DoctorLoginPageState createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;

  String get _password => _passwordController.text;
  bool isObscure = true;

  Future<void> _submit() async {
    try {
      showLoading(context);
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Patients").get();
      final List<QueryDocumentSnapshot> query = querySnapshot.docs;
      query.forEach(
        (element) {
          print(element.data()["patient_email"]);
          if (element.data()["patient_email"] == _email) {
            throw UserLoginException(
                message:
                    "Email is present in Patient Section. Please Login using another email");
          }
        },
      );
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      Navigator.pop(context);
    } on FirebaseException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Login Error", content: E.message);
    } on UserLoginException catch (E) {
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Center(
        child: ListView(
          physics: BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(15.0),
          children: [
            Text(
              "Doctor Login",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5.copyWith(
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
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_passwordFocusNode),
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
            SizedBox(height: 15.0),
            TextField(
              autocorrect: false,
              autofillHints: [AutofillHints.password],
              controller: _passwordController,
              onChanged: _updateState,
              focusNode: _passwordFocusNode,
              obscureText: isObscure,
              onEditingComplete: _submit,
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
                hintText: "password",
                hintStyle: TextStyle(color: Colors.black54),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => isObscure = !isObscure),
                  icon: isObscure
                      ? Icon(Icons.visibility_off_outlined)
                      : Icon(
                          Icons.visibility_outlined,
                        ),
                ),
              ),
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ForgortPasswordPage(),
                        ),
                      ),
                  child: Text(
                    "Forgot Password?",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  )),
            ),
            SizedBox(height: 20.0),
            CustomButton(
              desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
              buttonHeight: 65.0,
              buttonTitle: "Login",
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
    );
  }

  _updateState(String value) {
    setState(() {});
  }
}
