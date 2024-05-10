import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool? readOnly;
  final TextAlign? textAlign;
  final bool isDecor;
  final Color? textColor;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final int maxLine;
  final Color? backgroundColor;
  final Color? borderColor;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;
  final String? label;
  final bool? labelRequired;
  final bool isPhoneNumber;
  final Widget? suffixIcon;
  final void Function(String)? onSubmitted;

  const NeutronTextFormField({
    Key? key,
    this.controller,
    this.validator,
    this.hint,
    this.onChanged,
    this.textAlign,
    this.readOnly,
    this.isDecor = false,
    this.textColor,
    this.maxLine = 1,
    this.paddingHorizontal,
    this.paddingVertical,
    this.backgroundColor,
    this.borderColor,
    this.onEditingComplete,
    this.focusNode,
    this.label,
    this.isPhoneNumber = false,
    this.labelRequired,
    this.onSubmitted,
    this.suffixIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: isPhoneNumber
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*'))
            ]
          : null,
      style: TextStyle(
        color: textColor ?? ColorManagement.lightColorText,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      readOnly: readOnly ?? false,
      textAlign: textAlign ?? TextAlign.left,
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLine,
      decoration: !isDecor
          ? InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: hint,
              label: label == null
                  ? null
                  : NeutronTextTitle(
                      message: label!,
                      messageUppercase: false,
                      fontSize: 14,
                      color: ColorManagement.lightColorText,
                      isPadding: false,
                      isRequired: labelRequired ?? false,
                    ),
            )
          : InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              hintText: hint,
              fillColor: backgroundColor ?? ColorManagement.mainBackground,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal:
                      paddingHorizontal ?? SizeManagement.dropdownLeftPadding,
                  vertical: paddingVertical ?? 8),
              label: label == null
                  ? null
                  : NeutronTextTitle(
                      message: label!,
                      messageUppercase: false,
                      fontSize: 14,
                      color: ColorManagement.lightColorText,
                      isPadding: false,
                      isRequired: labelRequired ?? false,
                    ),
              suffixIcon: suffixIcon,
            ),
      cursorColor: ColorManagement.greenColor,
      cursorHeight: 20,
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
    );
  }
}

class NeutronNumberInputForDailyAllotment extends StatelessWidget {
  final TextEditingController? controller;

  const NeutronNumberInputForDailyAllotment({Key? key, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
      ],
      style: const TextStyle(
        color: ColorManagement.positiveText,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      textAlign: TextAlign.end,
      controller: controller,
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        isDense: true,
      ),
      cursorColor: ColorManagement.greenColor,
      cursorHeight: 20,
    );
  }
}

class NeutronInputNumberController {
  TextEditingController controller;
  String oldValue = '';

  NeutronInputNumberController(this.controller) {
    if (!controller.text.contains(',')) {
      formatString();
    }
  }

  void disposeTextController() {
    controller.dispose();
  }

  void formatString() {
    String value = controller.text;
    String negativeChar = '';
    if (value.contains('-')) {
      negativeChar = '-';
      value = value.substring(1, controller.text.length);
    }
    if (value.length <= 3) {
      oldValue = controller.text;
      return;
    }
    String firstString = ''; //left of dot character
    String secondString = ''; //right of dot character

    if (value.contains('.')) {
      int indexOfDotCharacter = value.indexOf(".");
      firstString = value.substring(0, indexOfDotCharacter);
      secondString = value.substring(indexOfDotCharacter);
      List<String> oldValueArray = oldValue.split('.');

      //this mean: user is editing SecondString and the firstString not change
      if (firstString == oldValueArray.first.replaceAll(',', '')) {
        String result = negativeChar + oldValueArray.first + secondString;
        int position = getTextPosition(result);
        controller.text = result;
        controller.selection =
            TextSelection.fromPosition(TextPosition(offset: position));
        oldValue = result;
        return;
      }
    } else {
      firstString = value;
    }
    String result = '';
    int count = 0;
    for (int i = firstString.length - 1; i >= 0; i--) {
      count++;
      if (count % 3 == 0 && i != 0) {
        result = ',${firstString[i]}$result';
      } else {
        result = firstString[i] + result;
      }
    }
    int position = getTextPosition(negativeChar + result + secondString);
    controller.text = negativeChar + result + secondString;
    controller.selection =
        TextSelection.fromPosition(TextPosition(offset: position));
    oldValue = result + secondString;
  }

  num? getNumber() => num.tryParse(controller.text.replaceAll(',', ''));

  int getTextPosition(String newString) {
    int position = controller.selection.baseOffset;
    int index = 0;
    for (int count = 1; count <= position; count++) {
      if (newString[index] == ',') {
        position++;
      }
      index++;
    }
    return position;
  }

  String getRawString() => controller.text.replaceAll(',', '').trim();

  TextInputType getInputType(bool isNegative, bool isDouble) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return TextInputType.text;
    }
    return TextInputType.numberWithOptions(
        decimal: isDouble, signed: isNegative);
  }

  Widget buildWidget(
      {String? Function(String?)? validator,
      String? hint,
      void Function(String)? onChanged,
      Color? color,
      Color? borderColor,
      Color? textColor,
      bool isDecor = true,
      bool? readOnly = false,
      bool isDouble = false,
      bool isNegative = false,
      TextAlign? textAlign,
      double? padding,
      String? label,
      String? suffixText,
      Widget? suffix,
      FocusNode? focusNode}) {
    return TextFormField(
      keyboardType: getInputType(isNegative, isDouble),
      inputFormatters: [
        FilteringTextInputFormatter.allow(isNegative
            ? (isDouble ? RegExp(r'\-?\d*\.?\d*') : RegExp(r'^\-?[0-9]*$'))
            : (isDouble ? RegExp(r'\d*\.?\d*') : RegExp(r'[0-9]'))),
        FilteringTextInputFormatter.deny(RegExp(','))
      ],
      style: TextStyle(
        color: textColor ?? ColorManagement.lightColorText,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      readOnly: readOnly ?? false,
      textAlign: textAlign ?? TextAlign.left,
      validator: validator,
      controller: controller,
      onChanged: (String value) {
        if (onChanged != null) {
          onChanged(value);
        }
        formatString();
      },
      decoration: !isDecor
          ? InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: hint,
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              label: label == null ? null : NeutronTextContent(message: label),
              suffix: suffixText == null ? suffix : const Text('%'))
          : InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: borderColor ?? ColorManagement.borderCell, width: 1),
              ),
              hintText: hint,
              fillColor: color ?? ColorManagement.mainBackground,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: padding ?? SizeManagement.dropdownLeftPadding,
                  vertical: 0),
              label: label == null ? null : NeutronTextContent(message: label),
              suffix: suffixText == null ? suffix : const Text('%')),
      cursorColor: ColorManagement.greenColor,
      cursorHeight: 20,
      focusNode: focusNode,
    );
  }
}
