import 'package:flutter/material.dart';

class NeutronTextHeader extends StatelessWidget {
  final String message;

  const NeutronTextHeader({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.normal,
        // fontFamily: FontManagement.fontFamily
      ),
    );
  }
}
