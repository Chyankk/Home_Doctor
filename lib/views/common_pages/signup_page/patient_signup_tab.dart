import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';

class PatientSignupTab extends StatefulWidget {
  @override
  _PatientSignupTabState createState() => _PatientSignupTabState();
}

class _PatientSignupTabState extends State<PatientSignupTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;

  Future<void> _submit() async {
    if (_formKey.currentState.validate() == true) {
      try {
        showLoading(context);
        print(_emailController.text);
        print(_passwordController.text);
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection("Patients")
            .doc(userCredential.user.uid)
            .set({
          "patient_Id": userCredential.user.uid,
          "patient_email": userCredential.user.email,
          "patient_name": _nameController.text,
        });
        await FirebaseAuth.instance.signOut();
        Navigator.pop(context);
        await showAlertDialog(
          context,
          title: "Sign up Successful",
          content: "Your Patient account has been created",
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        await showAlertDialog(
          context,
          title: "Sign up Error",
          content: e.message,
        );
      } on FirebaseException catch (e) {
        Navigator.pop(context);
        await showAlertDialog(
          context,
          title: "Sign up Error",
          content: e.message,
        );
      } catch (e) {
        Navigator.pop(context);
        await showAlertDialog(
          context,
          title: "Sign up Error",
          content: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 15.0),
            TextField(
              autocorrect: false,
              controller: _nameController,
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
                hintText: "Full Name",
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.black54),
              ),
              style: Theme.of(context).textTheme.headline6,
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofillHints: [AutofillHints.email],
              controller: _emailController,
              validator: (String text) {
                String pattern =
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                RegExp regExp = new RegExp(pattern);
                if (regExp.hasMatch(text) == false) {
                  return "Email is badly formatted";
                }
                return null;
              },
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
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.black54),
              ),
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _passwordController,
              obscureText: isObscure,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => isObscure = !isObscure),
                  icon: isObscure
                      ? Icon(Icons.visibility_off_outlined)
                      : Icon(
                          Icons.visibility_outlined,
                        ),
                ),
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
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.black54),
                helperText:
                    "It should contain 1 UpperCase, 1 Lowercase, 1 number and 1 symbol",
                helperMaxLines: 5,
              ),
              style: Theme.of(context).textTheme.headline6,
              validator: (String text) {
                String pattern =
                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                RegExp regExp = new RegExp(pattern);
                if (regExp.hasMatch(text) == false) {
                  return "Password should contain 1 UpperCase, 1 Lowercase, atleast 1 number and 1 special character";
                }
                return null;
              },
            ),
            SizedBox(height: 10.0),
            CustomButton(
              desktopMaxWidth: MediaQuery.of(context).size.width / 1.0,
              buttonHeight: 65.0,
              buttonTitle: "Create Account",
              textSize: 20.0,
              buttonColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              buttonRadius: 3.0,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
