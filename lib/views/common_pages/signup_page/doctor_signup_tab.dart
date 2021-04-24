import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homedoctor/widgets/custom_button.dart';
import 'package:homedoctor/widgets/showAlertDialog.dart';
import 'package:homedoctor/widgets/showLoading.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class DoctorSignupTab extends StatefulWidget {
  @override
  _DoctorSignupTabState createState() => _DoctorSignupTabState();
}

class _DoctorSignupTabState extends State<DoctorSignupTab> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _prnController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool isObscure = true;
  String _verificationId;

  final FocusNode _prnFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _clinicNameFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passworFocusNode = FocusNode();

  final FocusNode _promotionFocusNode = FocusNode();
  bool isPromotion = false;

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      try {
        showLoading(context);

        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        await FirebaseFirestore.instance
            .collection("Doctors")
            .doc(userCredential.user.uid)
            .set(
          {
            "prn": _prnController.text,
            "first_name": _firstNameController.text,
            "last_name": _lastNameController.text,
            "location": _locationController.text,
            "email": _emailController.text,
            "isPromotion": isPromotion,
            "noOfExp": 0,
            "eduQual": "",
            "phone": "",
            "maxPatientsPerDay": 10,
          },
        );
        await FirebaseAuth.instance.signOut();
        Navigator.pop(context);
        await showAlertDialog(
          context,
          title: "Sign up Successful",
          content: "Your Doctor account has been created",
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
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _prnController,
                focusNode: _prnFocusNode,
                autofocus: true,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_firstNameFocusNode),
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  hintText: "PRN Number",
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: _firstNameController,
                focusNode: _firstNameFocusNode,
                autofocus: true,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_lastNameFocusNode),
                textCapitalization: TextCapitalization.words,
                autofillHints: [AutofillHints.givenName],
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
                  hintText: "First Name",
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: _lastNameController,
                autocorrect: false,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_clinicNameFocusNode),
                focusNode: _lastNameFocusNode,
                autofillHints: [AutofillHints.familyName],
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
                  hintText: "Last Name",
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: _locationController,
                autocorrect: false,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_emailFocusNode),
                focusNode: _locationFocusNode,
                textCapitalization: TextCapitalization.words,
                autofillHints: [AutofillHints.addressCity],
                autofocus: false,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
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
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_passworFocusNode),
                focusNode: _emailFocusNode,
                autofocus: false,
                controller: _emailController,
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
                validator: (String text) {
                  String pattern =
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                  RegExp regExp = new RegExp(pattern);
                  if (regExp.hasMatch(text) == false) {
                    return "Email is badly formatted";
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              TextFormField(
                controller: _passwordController,
                obscureText: isObscure,
                autocorrect: false,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_promotionFocusNode),
                focusNode: _passworFocusNode,
                autofocus: false,
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
                    onPressed: () => setState(() => isObscure = !isObscure),
                    icon: isObscure
                        ? Icon(Icons.visibility_off_outlined)
                        : Icon(
                            Icons.visibility_outlined,
                          ),
                  ),
                  helperText:
                      "It should contain 1 UpperCase, 1 Lowercase, 1 number and 1 symbol",
                  helperMaxLines: 5,
                ),
                validator: (String text) {
                  String pattern =
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                  RegExp regExp = new RegExp(pattern);
                  if (regExp.hasMatch(text) == false) {
                    return "Password should contain 1 UpperCase, 1 Lowercase, atleast 1 number and 1 special character";
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isPromotion,
                    onChanged: (bool value) {
                      setState(() {
                        isPromotion = value;
                      });
                    },
                    focusNode: _promotionFocusNode,

                  ),
                  Text(
                    "Agree with",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PDFView())),
                    child: Text(
                      "Terms and Services",
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            color: Colors.blue,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
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
      ),
    );
  }
}

class PDFView extends StatefulWidget {
  @override
  _PDFViewState createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  int _actualPageNumber = 0, _allPagesCount = 0;
  final pdfController = PdfController(
    document: PdfDocument.openAsset('assets/pdf/termsofservice.pdf'),
  );

  Widget pdfView() => PdfView(
        controller: pdfController,
        onDocumentLoaded: (document) {
          setState(() {
            _allPagesCount = document.pagesCount;
          });
        },
        onPageChanged: (page) {
          setState(() {
            _actualPageNumber = page;
          });
        },
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms and Services",
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: pdfView(),
      ),
    );
  }
}
