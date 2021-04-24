abstract class StringValidator {
  bool isValid(String value);
}

class PasswordValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = EmailValidator();
  final StringValidator passwordValidator = PasswordValidator();
  final String invalidEmailErrorText = 'Email is badly formatted';
  final String invalidPasswordErrorText =
      'Password should me more than 6 characters';
}
