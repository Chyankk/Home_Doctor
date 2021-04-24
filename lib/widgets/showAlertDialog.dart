import 'package:flutter/material.dart';

Future<void> showAlertDialog(BuildContext context,
    {String title, String content, VoidCallback onPressed}) async {
  return await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text("Ok"),
          onPressed:
              onPressed != null ? onPressed : () => Navigator.of(context).pop(),
        )
      ],
    ),
  );
}
