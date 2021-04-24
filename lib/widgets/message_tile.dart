import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message;

  final bool isSendByMe;

  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: isSendByMe ? 0 : 24,
        right: isSendByMe ? 24 : 0,
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe
                ? [
                    const Color(0xff007EF4),
                    const Color(0xff2A75BC),
                  ]
                : [
                    const Color(0x1A000000),
                    const Color(0x1A000000),
                  ],
          ),
          borderRadius: isSendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.headline6.copyWith(
                fontWeight: FontWeight.normal,
                color: isSendByMe ? Colors.white : Colors.blue,
                fontSize: 17,
              ),
        ),
      ),
    );
  }
}
