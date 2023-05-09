import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final String buttonName;
  int eraStart = 0;
  int eraEnd = 0;

  Buttons({
    this.buttonName,
    this.eraStart,
    this.eraEnd,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Text(buttonName),
      onPressed: () {

      }
    );
  }
}