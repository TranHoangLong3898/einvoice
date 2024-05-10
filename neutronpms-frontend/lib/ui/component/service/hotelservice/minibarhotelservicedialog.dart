// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotelservice/minibarhotelservicecontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:provider/provider.dart';

import 'package:ihotel/constants.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';

import '../../../../manager/warehousemanager.dart';
import '../../../controls/neutrondropdown.dart';

class MinibarHotelServiceDialog extends StatefulWidget {
  final HotelItem? item;
  final String? type;

  const MinibarHotelServiceDialog({Key? key, this.item, this.type})
      : super(key: key);

  @override
  State<MinibarHotelServiceDialog> createState() =>
      _MinibarHotelServiceDialogState();
}

class _MinibarHotelServiceDialogState extends State<MinibarHotelServiceDialog> {
  late MinibarRestaurantHotelServiceController controller;
  late FocusNode rateNode;

  @override
  void initState() {
    rateNode = FocusNode();
    controller =
        MinibarRestaurantHotelServiceController(widget.item, widget.type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String header = UITitleUtil.getTitleByCode(
        controller.type == ItemType.minibar
            ? UITitleCode.MINIBAR_ITEM
            : UITitleCode.RESTAURANT_ITEM);

    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding),
        color: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider<
            MinibarRestaurantHotelServiceController>.value(
          value: controller,
          child: Consumer<MinibarRestaurantHotelServiceController>(
            child: Container(
                alignment: Alignment.center,
                height: kMobileWidth,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                )),
            builder: (_, controller, child) {
              return controller.isInProgress
                  ? child!
                  : Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.topHeaderTextSpacing),
                              child: NeutronTextHeader(
                                message: header,
                              ),
                            ),
                            const SizedBox(height: SizeManagement.rowSpacing),
                            //choose item
                            NeutronTextTitle(
                              isRequired: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ITEM),
                              isPadding: false,
                            ),
                            const SizedBox(height: SizeManagement.rowSpacing),
                            buildAutoComplete(),
                            const SizedBox(
                                height: SizeManagement.rowSpacing * 2),
                            //price
                            NeutronTextTitle(
                              isRequired: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE),
                              isPadding: false,
                            ),
                            const SizedBox(height: SizeManagement.rowSpacing),
                            controller.tePriceController.buildWidget(
                              focusNode: rateNode,
                              isDouble: true,
                              isDecor: true,
                              validator: (String? value) {
                                if (value == null ||
                                    !NumberValidator.validatePositiveNumber(
                                        value.replaceAll(',', ''))) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.PRICE_MUST_BE_NUMBER);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                                height: SizeManagement.rowSpacing * 2),
                            //warehouse
                            NeutronTextTitle(
                              isRequired: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DEFAULT_WAREHOUSE),
                              isPadding: false,
                            ),
                            const SizedBox(height: SizeManagement.rowSpacing),
                            NeutronDropDownCustom(
                              childWidget: NeutronDropDown(
                                isPadding: false,
                                items: [
                                  '',
                                  ...WarehouseManager().getActiveWarehouseName()
                                ],
                                value: WarehouseManager()
                                        .getActiveWarehouseName()
                                        .contains(
                                            controller.defaultWarehouseName)
                                    ? controller.defaultWarehouseName
                                    : '',
                                onChanged: (String newWarehouse) {
                                  controller.setDefaultWarehouse(newWarehouse);
                                },
                              ),
                            ),
                            const SizedBox(
                                height: SizeManagement.bottomFormFieldSpacing),
                            ...[
                              Row(children: [
                                Checkbox(
                                    checkColor: ColorManagement.greenColor,
                                    value: controller.isAutoExport,
                                    onChanged: (newValue) {
                                      controller.setAutoExport(newValue);
                                    }),
                                NeutronTextContent(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .AUTOMATIC_REDUCTION_IN_WAREHOUSE))
                              ]),
                              const SizedBox(
                                  height:
                                      SizeManagement.bottomFormFieldSpacing),
                            ],
                            //button
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: NeutronButton(
                                margin: const EdgeInsets.only(
                                    bottom: SizeManagement.rowSpacing),
                                icon: Icons.save,
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    String result =
                                        await controller.updateMinibar();
                                    if (result ==
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.SUCCESS)) {
                                      Navigator.pop(context);
                                    }
                                    MaterialUtil.showResult(context, result);
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Autocomplete buildAutoComplete() {
    return Autocomplete<HotelItem>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        List<HotelItem> listItem = ItemManager().itemsTypeOther;
        if (textEditingValue.text.isEmpty) {
          return listItem;
        }

        return listItem.where((HotelItem option) =>
            _isPartialMatch(option.name!, textEditingValue.text));
      },
      onSelected: (HotelItem selection) {
        rateNode.requestFocus();
        controller.setItem(selection);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: ColorManagement.mainBackground,
            elevation: 5,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: 200,
                  maxWidth: kMobileWidth -
                      SizeManagement.cardOutsideHorizontalPadding * 2),
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) => ListTile(
                  onTap: () => onSelected(options.elementAt(index)),
                  title: Text(
                    options.elementAt(index).name!,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: ColorManagement.oddColor,
                      backgroundImage: options.elementAt(index).image == null
                          ? null
                          : MemoryImage(options.elementAt(index).image!)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minVerticalPadding: 0,
                  focusColor: Colors.white38,
                  hoverColor: Colors.white38,
                ),
                itemCount: options.length,
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onEditingComplete) {
        return NeutronTextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          isDecor: true,
          readOnly: controller.service != null,
          onChanged: (String value) {
            // controller.setItem( value);
          },
        );
      },
      initialValue: TextEditingValue(text: controller.selectedItem?.name ?? ''),
      displayStringForOption: (option) => option.name!,
    );
  }

  bool _isPartialMatch(String option, String searchText) {
    // Chia chuỗi tìm kiếm thành các từ
    List<String> searchWords = searchText.split(' ');

    // Kiểm tra xem mỗi từ trong chuỗi tìm kiếm có tồn tại trong tùy chọn hay không
    return searchWords.every((word) => option.toLowerCase().contains(word));
  }
}
