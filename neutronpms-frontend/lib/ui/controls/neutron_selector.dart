import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronSelector extends StatefulWidget {
  const NeutronSelector({
    Key? key,
    @required this.items,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInCubic,
    this.itemExtent = kMobileWidth,
    this.height = SizeManagement.cardHeight,
    this.indicatorColor = ColorManagement.orangeColor,
    this.backgroundColor = ColorManagement.mainBackground,
    this.radius = 12,
    this.itemPadding,
    this.mainAxisSize,
    this.onChanged,
    this.animation = true,
    this.itemAlign,
    this.initIndex,
  }) : super(key: key);

  /// The items to be used in the selection are entered here.
  final List<Widget>? items;

  /// Use this to set the animation duration.
  final Duration duration;

  /// Use this to change the animation curve type.
  final Curve curve;

  /// Use this to specify the width of the items.
  final double itemExtent;

  /// Use this to specify the height of the items.
  final double height;

  /// Use this to change the indicator color.
  final Color indicatorColor;

  /// Use this to change the background color.
  final Color backgroundColor;

  /// Use this to change the radius.
  final double radius;

  /// Use this to give padding to each of the items. This way you can leave space between items.
  final EdgeInsets? itemPadding;

  /// Use this to organize the space occupied by items horizontally.
  final MainAxisSize? mainAxisSize;

  /// Use this to eliminate the animation transition altogether.
  final bool animation;

  /// If you want to change where the items are aligned use this.
  final Alignment? itemAlign;

  /// initial index of current value in items.
  final int? initIndex;

  /// This function is used to see the selected index.
  final Function(int index)? onChanged;

  @override
  State<NeutronSelector> createState() => _MyaAckageState();
}

class _MyaAckageState extends State<NeutronSelector>
    with TickerProviderStateMixin {
  Offset? offset;

  @override
  void initState() {
    offset = Offset(0, widget.initIndex?.toDouble() ?? 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.itemExtent,
      height: widget.height * widget.items!.length,
      constraints: const BoxConstraints(maxHeight: kHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        color: widget.backgroundColor,
      ),
      child: Stack(
        children: [
          if (widget.items!.isNotEmpty)
            AnimatedSlide(
              offset: offset!,
              duration: widget.animation ? widget.duration : Duration.zero,
              curve: widget.curve,
              child: AnimatedContainer(
                duration: widget.animation ? widget.duration : Duration.zero,
                width: widget.itemExtent,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  color: widget.indicatorColor,
                ),
              ),
            ),
          Column(
            mainAxisSize: widget.mainAxisSize ?? MainAxisSize.max,
            children: widget.items!
                .asMap()
                .entries
                .map(
                  (kv) => Stack(
                    children: [
                      Container(
                        alignment: widget.itemAlign ?? Alignment.centerLeft,
                        padding: widget.itemPadding ?? EdgeInsets.zero,
                        width: widget.itemExtent,
                        height: widget.height,
                        child: AnimatedAlign(
                            duration: widget.duration,
                            curve: widget.curve,
                            alignment: offset!.dy == kv.key.toDouble()
                                ? Alignment.center
                                : Alignment.centerLeft,
                            child: kv.value),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(widget.radius),
                            onTap: () => _onTap(kv),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _onTap(MapEntry<int, Widget> kv) {
    if (offset!.dy == kv.key.toDouble()) {
      return;
    }
    setState(() {
      offset = Offset(0, kv.key.toDouble());
    });
    if (widget.onChanged != null) {
      widget.onChanged!(kv.key);
    }
  }
}
