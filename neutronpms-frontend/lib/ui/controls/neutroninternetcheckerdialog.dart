import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class NeutronInternetCheckerDialog extends StatefulWidget {
  const NeutronInternetCheckerDialog({Key? key}) : super(key: key);

  @override
  State<NeutronInternetCheckerDialog> createState() =>
      NeutronInternetCheckerDialogState();
}

class NeutronInternetCheckerDialogState
    extends State<NeutronInternetCheckerDialog> with TickerProviderStateMixin {
  final double alertContainerWidth = 80;
  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500),
    );
    animation = Tween<double>(begin: 24, end: 50).animate(animationController);
    animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: kMobileWidth,
        child: Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: alertContainerWidth / 2 + 15),
                NeutronTextTitle(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.INTERNET_ERROR_TITLE),
                  color: ColorManagement.redColor,
                  fontSize: 24,
                ),
                const SizedBox(height: 10),
                NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.INTERNET_ERROR_CONTENT),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  fontSize: 12,
                ),
                const SizedBox(height: 15),
              ],
            ),
            Positioned(
                top: -alertContainerWidth / 2,
                left: (kMobileWidth - alertContainerWidth) / 2,
                child: Container(
                  width: alertContainerWidth,
                  height: alertContainerWidth,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (_, __) => Icon(
                      Icons.warning_amber_rounded,
                      size: animation.value,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
