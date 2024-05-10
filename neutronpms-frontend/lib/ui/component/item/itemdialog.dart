import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/item/itemcontroller.dart';
import '../../../handler/filehandler.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../../util/unitulti.dart';
import '../../../validator/stringvalidator.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrondropdown.dart';
import '../../controls/neutrontextformfield.dart';

class ItemDialog extends StatefulWidget {
  final HotelItem? item;
  final bool? readOnly;

  const ItemDialog({Key? key, this.item, this.readOnly}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ItemState();
}

class _ItemState extends State<ItemDialog> {
  final ScrollController scrollController = ScrollController();
  final ScrollPhysics scrollPhysics = const ClampingScrollPhysics();

  late ItemController controller;
  late bool readOnly;
  @override
  void initState() {
    readOnly = widget.readOnly ?? false;
    controller = ItemController(widget.item);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        key: widget.key,
        elevation: 20,
        backgroundColor: ColorManagement.lightMainBackground,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          width: kMobileWidth,
          child: ChangeNotifierProvider<ItemController>.value(
            value: controller,
            child: Consumer<ItemController>(
              child: const SizedBox(
                height: kMobileWidth,
                child: Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor)),
              ),
              builder: (_, controller, child) => controller.isInProgress!
                  ? child!
                  : SingleChildScrollView(
                      clipBehavior: Clip.none,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildImage(),
                          //id
                          NeutronTextFormField(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ID),
                            isDecor: true,
                            controller: controller.teIdController,
                            readOnly: !controller.isAddFeature! || readOnly,
                            validator: (String? id) {
                              return StringValidator.validateRequiredId(id);
                            },
                          ),
                          const SizedBox(
                              height: SizeManagement.bottomFormFieldSpacing),
                          //name
                          NeutronTextFormField(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_NAME),
                              isDecor: true,
                              controller: controller.teNameController,
                              readOnly: readOnly),
                          const SizedBox(
                              height: SizeManagement.bottomFormFieldSpacing),
                          Row(
                            children: [
                              Expanded(
                                child: NeutronDropDownCustom(
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_UNIT),
                                  childWidget: NeutronDropDown(
                                    isDisabled: readOnly,
                                    isPadding: false,
                                    items: [
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.CHOOSE_UNIT),
                                      ...UnitUlti.getUnits().map((e) =>
                                          MessageUtil.getMessageByCode(e))
                                    ],
                                    value: controller.unit ==
                                            MessageUtil.getMessageByCode(
                                                MessageCodeUtil.CHOOSE_UNIT)
                                        ? MessageUtil.getMessageByCode(
                                            MessageCodeUtil.CHOOSE_UNIT)
                                        : MessageUtil.getMessageByCode(
                                            controller.unit),
                                    onChanged: (String newUnit) {
                                      controller.setUnit(newUnit);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardInsideHorizontalPadding),
                              Expanded(
                                  child: controller.teCostPrice.buildWidget(
                                      readOnly: readOnly,
                                      textColor: ColorManagement.positiveText,
                                      isDecor: true,
                                      isDouble: true,
                                      label: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_COST_PRICE))),
                            ],
                          ),
                          const SizedBox(
                              height: SizeManagement.bottomFormFieldSpacing),

                          if (!readOnly)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: NeutronButton(
                                margin: const EdgeInsets.only(
                                    bottom: SizeManagement.rowSpacing),
                                icon1: Icons.save,
                                onPressed1: () async {
                                  String result = await controller.updateItem();
                                  if (!mounted) {
                                    return;
                                  }
                                  if (result ==
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    Navigator.pop(context);
                                  }
                                  MaterialUtil.showResult(context, result);
                                },
                              ),
                            )
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImage() {
    return Transform.translate(
      offset: const Offset(0, -SizeManagement.avatarCircle / 1.5),
      child: Container(
        height: 150,
        width: 150,
        alignment: Alignment.center,
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.white38,
            blurRadius: 2,
          ),
        ], color: ColorManagement.lightMainBackground, shape: BoxShape.circle),
        child: InkWell(
          child: controller.base64 == null
              ? NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CHOOSE_IMAGE))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(300.0),
                  child: Image.memory(controller.base64!)),
          onTap: () async {
            if (readOnly) {
              return;
            }
            pickImage();
          },
        ),
      ),
    );
  }

  void pickImage() async {
    PlatformFile? pickedFile = await FileHandler.pickSingleImage(context);
    if (pickedFile == null) {
      return;
    }
    String result = controller.setImageToItem(pickedFile);
    if (mounted && result != MessageCodeUtil.SUCCESS) {
      MaterialUtil.showAlert(context, result);
    }
  }
}
