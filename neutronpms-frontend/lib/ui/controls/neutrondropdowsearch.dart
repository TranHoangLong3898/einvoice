import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../manager/generalmanager.dart';
import '../../util/designmanagement.dart';
import '../../util/messageulti.dart';
import 'neutrontextformfield.dart';

// ignore: must_be_immutable
class NeutronSearchDropDown extends StatelessWidget {
  String value;
  final String? label;
  final List<String>? items;
  final Function? onChange;
  final Color? backgroundColor;
  final double? width;
  final String? hint;
  final String valueFirst;
  final bool? restInput;

  NeutronSearchDropDown({
    Key? key,
    required this.value,
    this.label,
    required this.items,
    this.onChange,
    this.backgroundColor,
    this.width,
    this.hint,
    required this.valueFirst,
    this.restInput,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeManagement.cardHeight,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          List<String> listItems = items!;
          if (textEditingValue.text.isEmpty) {
            return listItems;
          }
          if (textEditingValue.text != valueFirst) {
            return listItems.where((String option) =>
                _isPartialMatch(option, textEditingValue.text.toLowerCase()));
          }
          return listItems;
        },
        onSelected: (option) {
          GeneralManager().unfocus(context);
          onChange!.call(option);
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: ColorManagement.lightMainBackground,
              elevation: 5,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 150,
                    maxWidth: kMobileWidth -
                        SizeManagement.cardOutsideHorizontalPadding * 2),
                child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) => Card(
                    color: ColorManagement.mainBackground,
                    child: ListTile(
                      onTap: () => onSelected(options.elementAt(index)),
                      title: Text(
                        options.elementAt(index),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      minVerticalPadding: 0,
                      hoverColor: Colors.white38,
                    ),
                  ),
                  itemCount: options.length,
                ),
              ),
            ),
          );
        },
        displayStringForOption: (option) => option,
        fieldViewBuilder:
            (context, textEditingController, focusNode, onEditingComplete) {
          return Focus(
            focusNode: focusNode,
            onFocusChange: (hasFocus) {
              if (textEditingController.text == valueFirst) {
                textEditingController.clear();
                textEditingController.text = "";
              }
              if (hasFocus) return;
              String? temp = items!
                      .where((e) => e == textEditingController.text)
                      .isNotEmpty
                  ? items?.firstWhere((e) => e == textEditingController.text)
                  : null;
              String content = "";
              if (temp == null) {
                if (textEditingController.text != "") {
                  content = textEditingController.text;
                } else {
                  textEditingController.clear();
                  textEditingController.text = valueFirst;
                  content = textEditingController.text;
                }
                onChange!.call(content);
              }
            },
            child: NeutronTextFormField(
              backgroundColor:
                  backgroundColor ?? ColorManagement.lightMainBackground,
              label: label,
              hint: hint ?? valueFirst,
              controller: textEditingController,
              onEditingComplete: onEditingComplete,
              isDecor: true,
              validator: (String? v) {
                if (v!.isEmpty) {
                  return MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_PLEASE_CHOOSE_UNIT);
                }
                return null;
              },
              onChanged: (v) {
                String? temp = items!.where((e) => e == v).isNotEmpty
                    ? items?.firstWhere((e) => e == v)
                    : null;
                if (temp == null) {
                  value = v != "" ? v : valueFirst;
                } else {
                  onChange!.call(v);
                }
              },
              onTap: () {
                if (restInput ?? false) {
                  textEditingController.text = '';
                } else {
                  if (textEditingController.text == valueFirst) {
                    textEditingController.text = '';
                  }
                }
              },
            ),
          );
        },
        initialValue: TextEditingValue(text: value),
      ),
    );
  }

  bool _isPartialMatch(String option, String searchText) {
    // Chia chuỗi tìm kiếm thành các từ
    List<String> searchWords = searchText.split(' ');

    // Kiểm tra xem mỗi từ trong chuỗi tìm kiếm có tồn tại trong tùy chọn hay không
    return searchWords.every((word) => option.toLowerCase().contains(word));
  }
}
