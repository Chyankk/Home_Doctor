import 'package:flutter/material.dart' show required;

class DoctorLoginException implements Exception {
  final String message;

  DoctorLoginException({@required this.message});
}

class UserLoginException implements Exception {
  final String message;

  UserLoginException({@required this.message});
}
