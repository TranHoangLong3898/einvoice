import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';

class ChartIndicator extends StatelessWidget {
  const ChartIndicator({
    Key? key,
    required this.color,
    required this.text,
  }) : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            color: color,
          ),
          NeutronTextContent(
            message: text,
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}
