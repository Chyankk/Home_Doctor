import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/views/common_pages/forgot_password/forgot_password_page.dart';
import 'package:homedoctor/views/common_pages/widgets/login_exceptions.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class PatientLoginPage extends StatefulWidget {
  @override
  _PatientLoginPageState createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  bool isObscure = true;

  Future<void> _submit() async {
    try {
      showLoading(context);
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Doctors").get();
      final List<QueryDocumentSnapshot> query = querySnapshot.docs;
      query.forEach((element) {
        print(element.data()["email"]);
        if (element.data()["email"] == _emailController.text) {
          throw DoctorLoginException(
              message:
                  "Email is present in Patients Section. Please Login using another email");
        }
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Navigator.pop(context);
    } on FirebaseException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Login Error", content: E.message);
    } on DoctorLoginException catch (E) {
      Navigator.pop(context);
      showAlertDialog(context, title: "Login Error", content: E.message);
      _emailController.clear();
      _passwordController.clear();
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
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                "Patient Login",
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 50.0),
              TextField(
                autocorrect: false,
                enableSuggestions: true,
                enableInteractiveSelection: true,
                controller: _emailController,
                autofillHints: [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                focusNode: emailFocusNode,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(passwordFocusNode),
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
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              TextField(
                autocorrect: false,
                controller: _passwordController,
                focusNode: passwordFocusNode,
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
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.black54),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => isObscure = !isObscure,
                    ),
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
                  ),
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
