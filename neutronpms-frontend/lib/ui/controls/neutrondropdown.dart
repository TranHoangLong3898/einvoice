import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/designmanagement.dart';

import '../../manager/generalmanager.dart';

class NeutronDropDown extends StatelessWidget {
  final String value;
  final Function? onChanged;
  final List<String?> items;
  final Color? focusColor;
  final bool isCenter;
  final bool isPadding;
  final TextStyle? textStyle;
  final bool isDropdownDarkColor;
  final bool isDisabled;
  final bool isTooltip;
  final Color? dropdownColor;
  const NeutronDropDown({
    Key? key,
    required this.value,
    this.onChanged,
    required this.items,
    this.focusColor,
    this.isCenter = false,
    this.isPadding = true,
    this.textStyle,
    this.isDropdownDarkColor = true,
    this.isDisabled = false,
    this.isTooltip = false,
    this.dropdownColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        focusColor: focusColor ?? ColorManagement.mainBackground,
        dropdownColor: isDropdownDarkColor
            ? ColorManagement.lightMainBackground
            : ColorManagement.lightColorText,
        iconEnabledColor: Colors.white,
        iconSize: 16,
        isExpanded: true,
        value: isDisabled ? null : value,
        style: textStyle ?? NeutronTextStyle.content,
        disabledHint:
            isDisabled ? Text(value, style: NeutronTextStyle.content) : null,
        onChanged: isDisabled
            ? null
            : (v) {
                onChanged!(v);
                GeneralManager().unfocus(context);
              },
        items: items.map<DropdownMenuItem<String>>((String? value) {
          return DropdownMenuItem<String>(
            alignment: isCenter ? Alignment.center : Alignment.centerLeft,
            value: value,
            child: Padding(
              padding: EdgeInsets.only(left: isPadding ? 10 : 0),
              child: isTooltip
                  ? Tooltip(
                      message: value, child: Text(value!, style: textStyle))
                  : Text(value!, style: textStyle),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NeutronDropDownCustom extends StatelessWidget {
  final Widget childWidget;
  final String? label;
  final bool isRequiredlabel;
  final Color? backgroundColor;
  final double? verticalContentPadding;
  final double? horizontalContentPadding;
  final Color? borderColors;

  const NeutronDropDownCustom(
      {Key? key,
      required this.childWidget,
      this.label,
      this.borderColors,
      this.isRequiredlabel = false,
      this.backgroundColor,
      this.verticalContentPadding,
      this.horizontalContentPadding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeManagement.cardHeight,
      child: InputDecorator(
        decoration: InputDecoration(
          label: label != null
              ? RichText(
                  text: TextSpan(
                      text: label,
                      style: NeutronTextStyle.content,
                      children: <TextSpan>[
                      if (isRequiredlabel)
                        const TextSpan(
                            text: ' *', style: TextStyle(color: Colors.red))
                    ]))
              : null,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: verticalContentPadding ?? 16,
              horizontal: horizontalContentPadding ??
                  SizeManagement.dropdownLeftPadding),
          fillColor: backgroundColor ?? ColorManagement.mainBackground,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: borderColors ?? ColorManagement.borderCell, width: 1),
          ),
        ),
        child: childWidget,
      ),
    );
  }
}

class NeutronStatusDropdown extends StatelessWidget {
  final String firstColorStatus, secondColorStatus, currentStatus;
  final List<String> items;
  final Function onChanged;
  final double? width, height;
  final EdgeInsetsGeometry? margin, padding;
  final bool isDisable;

  const NeutronStatusDropdown(
      {Key? key,
      this.firstColorStatus = 'open',
      this.secondColorStatus = 'passed',
      required this.currentStatus,
      required this.onChanged,
      required this.items,
      this.width,
      this.height,
      this.margin,
      this.padding,
      this.isDisable = false})
      : super(key: key);

  Color? get color => currentStatus == firstColorStatus
      ? null
      : currentStatus == secondColorStatus
          ? ColorManagement.cleanRoomCellBackground
          : ColorManagement.redColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      child: isDisable
          ? Text(currentStatus)
          : NeutronDropDown(
              isCenter: true,
              focusColor: color,
              value: currentStatus,
              onChanged: onChanged,
              items: items,
            ),
    );
  }
}

class NeutronDropDownAppar extends StatelessWidget {
  final String value;
  final Function(String) onChanged;
  final List<String> items;
  final Color? focusColor;
  final Color fillColorInPutDecoration;
  final Color borderColor;
  final bool isCenter;
  final bool isPadding;
  final TextStyle? textStyle;
  final bool isDisabled;
  final bool isDecor;
  final String? label;
  final bool isTooltip;
  final double? width;

  const NeutronDropDownAppar({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.focusColor,
    this.isCenter = false,
    this.isPadding = true,
    this.textStyle,
    this.isDisabled = false,
    this.isDecor = true,
    this.label,
    this.isTooltip = false,
    this.fillColorInPutDecoration = ColorManagement.mainBackground,
    this.borderColor = ColorManagement.borderCell,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: SizeManagement.cardHeight,
      child: InputDecorator(
        decoration: isDecor
            ? InputDecoration(
                labelText: label,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: SizeManagement.dropdownLeftPadding),
                fillColor: fillColorInPutDecoration,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
              )
            : InputDecoration(
                labelText: label, enabledBorder: InputBorder.none),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            focusColor: focusColor ?? ColorManagement.mainBackground,
            dropdownColor: ColorManagement.lightMainBackground,
            iconEnabledColor: Colors.white,
            iconSize: 16,
            isExpanded: true,
            value: isDisabled ? null : value,
            style: textStyle ??
                const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: ColorManagement.lightColorText),
            disabledHint: isDisabled
                ? Text(value,
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: ColorManagement.lightColorText))
                : null,
            onChanged: isDisabled
                ? null
                : (v) {
                    onChanged(v!);
                    //clear all focus of the textfield
                    GeneralManager().unfocus(context);
                  },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                alignment: isCenter ? Alignment.center : Alignment.centerLeft,
                value: value,
                child: Padding(
                  padding: EdgeInsets.only(left: isPadding ? 10 : 0),
                  child: isTooltip
                      ? Tooltip(
                          message: value, child: Text(value, style: textStyle))
                      : Text(value, style: textStyle),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
