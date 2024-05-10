import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';

import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';

class NewBookingToday extends StatelessWidget {
  const NewBookingToday({Key? key}) : super(key: key);

  DailyDataHotelsController? get controller =>
      DailyDataHotelsController.instance;

  @override
  Widget build(BuildContext context) {
    Map<String, num>? data = controller?.getBookingAmountToday();

    return Container(
      alignment: Alignment.center,
      width: kMobileWidth,
      height: 120,
      margin: const EdgeInsets.only(
          right: SizeManagement.cardOutsideHorizontalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ColorManagement.dashboardComponent,
        borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
      ),
      child: (data == null)
          ? const Text(
              'No Data',
              style: TextStyle(color: ColorManagement.textBlack),
            )
          : bodyNewBooking(data),
    );
  }

  Row bodyNewBooking(Map<String, num> data) {
    double ratio = (data['today']! - data['yesterday']!) / data['yesterday']!;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: double.infinity,
                width: double.infinity,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: NewBookingPainter(),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      Text(
                        '${data["today"]}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text(
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.STATISTIC_NEW_BOOKING),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 18)
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: -15,
                child: Container(
                  width: 50,
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    '${data["yesterday"]}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Text(
          '${(ratio * 100).toStringAsFixed(1)}%',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15,
            color: ratio > 0
                ? ColorManagement.positiveText
                : ColorManagement.negativeText,
          ),
        )),
        const SizedBox(width: 4),
        ratio > 0 ? progressUpIcon : progressDownIcon,
      ],
    );
  }

  Widget get progressUpIcon => const Icon(
        FontAwesomeIcons.arrowTrendUp,
        color: ColorManagement.positiveText,
        size: 14,
      );

  Widget get progressDownIcon => const Icon(
        FontAwesomeIcons.arrowTrendDown,
        color: ColorManagement.negativeText,
        size: 14,
      );
}

class NewBookingPainter extends CustomPainter {
  // Method to convert degree to radians

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..shader =
          const LinearGradient(colors: [Color(0xffffa751), Color(0xffffe259)])
              .createShader(Offset.zero & size);
    Path path = Path()
      ..arcTo(
        Rect.fromCircle(
          center: Offset(w / 2, h * 0.85),
          radius: h * 0.75,
        ),
        pi,
        pi * 0.88,
        true,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
