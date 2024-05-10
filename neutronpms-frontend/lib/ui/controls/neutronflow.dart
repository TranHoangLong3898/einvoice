import 'package:flutter/material.dart';

import '../../util/designmanagement.dart';

class NeutronFlow extends StatelessWidget {
  const NeutronFlow({
    Key? key,
    required this.icons,
    required this.animationController,
    this.functions,
  }) : super(key: key);

  /// AnimationController is for controlling animation
  final AnimationController animationController;

  /// List icons, the first element is the icon of Flow when Flow is collapsed
  final List<IconData> icons;

  /// List functions. This parameter is corresponding to [icons]. The first icon has no functions and [functions] starts from the second icon
  /// For example: The first funtion is for the second icon.
  final List<Function>? functions;

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: FlowMenuDelegate(animationController),
      children: icons
          .map<Widget>((IconData icon) => buildItem(context, icon))
          .toList(),
    );
  }

  Widget buildItem(BuildContext context, IconData icon) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(icon == Icons.menu
            ? ColorManagement.lightMainBackground
            : ColorManagement.redColor),
        elevation: MaterialStateProperty.all(3),
        fixedSize: MaterialStateProperty.all(const Size(40, 40)),
        shadowColor: MaterialStateProperty.all(ColorManagement.lightColorText),
        shape: MaterialStateProperty.all(const CircleBorder()),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      onPressed: () async {
        int iconIndex = icons.indexOf(icon);
        int functionIndex = iconIndex - 1;
        if (functionIndex >= 0 && functionIndex <= (functions?.length ?? 0)) {
          functions![iconIndex - 1].call();
        }
        animationController.status == AnimationStatus.completed
            ? animationController.reverse()
            : animationController.forward();
      },
      child: Icon(icon, color: Colors.white, size: 30.0),
    );
  }
}

class FlowMenuDelegate extends FlowDelegate {
  const FlowMenuDelegate(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) {
    return animation != oldDelegate.animation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dy = 0.0;
    final size = context.size;
    final xStart = size.width - 60;
    final yStart = size.height - 100;
    for (int i = context.childCount - 1; i >= 0; i--) {
      dy = (context.getChildSize(i)!.width * i) * animation.value;
      final y = yStart - dy;
      context.paintChild(
        i,
        transform: Matrix4.translationValues(xStart, y, 0),
      );
    }
  }
}
