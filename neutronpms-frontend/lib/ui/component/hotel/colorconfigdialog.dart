import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class ColorConfigDialog extends StatefulWidget {
  const ColorConfigDialog({Key? key}) : super(key: key);

  @override
  State<ColorConfigDialog> createState() => _ColorConfigDialogState();
}

class _ColorConfigDialogState extends State<ColorConfigDialog> {
  final ColorConfigController colorConfigController = ColorConfigController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
          width: kMobileWidth,
          child: SingleChildScrollView(
            child: ChangeNotifierProvider<ColorConfigController>.value(
              value: colorConfigController,
              child: Consumer<ColorConfigController>(
                builder: (_, controller, __) => controller.isInProgress
                    ? Container(
                        height: kMobileWidth,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            color: ColorManagement.greenColor),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //header
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                vertical: SizeManagement.topHeaderTextSpacing),
                            child: NeutronTextHeader(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.SIDEBAR_COLOR),
                            ),
                          ),
                          //book
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                vertical: SizeManagement.rowSpacing),
                            child: NeutronTextTitle(
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BOOK_COLOR),
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              // InkWell(
                              //   onTap: () {
                              //     showDialog(
                              //         context: context,
                              //         builder: (context) => _buildColorPicker(
                              //             context,
                              //             'book',
                              //             'bed',
                              //             colorConfigController));
                              //   },
                              //   child: Container(
                              //     height: 15,
                              //     width: 15,
                              //     margin: const EdgeInsets.only(right: 4),
                              //     color: controller.colors['book']['bed'],
                              //   ),
                              // ),
                              // Expanded(
                              //   child: NeutronTextContent(
                              //     message: UITitleUtil.getTitleByCode(
                              //         UITitleCode.TABLEHEADER_BED),
                              //   ),
                              // ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'book',
                                          'text',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: controller.colors['book']!['text'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TEXT_COLOR),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'book',
                                          'main',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: controller.colors['book']!['main'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_BACKGROUND),
                                ),
                              ),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                            ],
                          ),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: SizeManagement.rowSpacing),
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 100,
                                  height: GeneralManager.bookingCellHeight,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: GeneralManager.bedCellWidth,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        color:
                                            controller.colors['book']!['bed'],
                                        child: const Text(
                                          'B',
                                          style: TextStyle(
                                              color: ColorManagement.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            color: controller
                                                .colors['book']!['main'],
                                            child: Text(
                                              'Book',
                                              style: TextStyle(
                                                  color: controller
                                                      .colors['book']!['text'],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none),
                                            )),
                                      )
                                    ],
                                  ))),
                          const Divider(
                              color: ColorManagement.borderCell,
                              thickness: 1,
                              height: 4),
                          //check in color
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                vertical: SizeManagement.rowSpacing),
                            child: NeutronTextTitle(
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CHECKIN_COLOR),
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              // InkWell(
                              //   onTap: () {
                              //     showDialog(
                              //         context: context,
                              //         builder: (context) => _buildColorPicker(
                              //             context,
                              //             'in',
                              //             'bed',
                              //             colorConfigController));
                              //   },
                              //   child: Container(
                              //     height: 15,
                              //     width: 15,
                              //     margin: const EdgeInsets.only(right: 4),
                              //     color: controller.colors['in']['bed'],
                              //   ),
                              // ),
                              // Expanded(
                              //   child: NeutronTextContent(
                              //     message: UITitleUtil.getTitleByCode(
                              //         UITitleCode.TABLEHEADER_BED),
                              //   ),
                              // ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'in',
                                          'text',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: controller.colors['in']!['text'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TEXT_COLOR),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'in',
                                          'main',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: controller.colors['in']!['main'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_BACKGROUND),
                                ),
                              ),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                            ],
                          ),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: SizeManagement.rowSpacing),
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 100,
                                  height: GeneralManager.bookingCellHeight,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: GeneralManager.bedCellWidth,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        color: controller.colors['in']!['bed'],
                                        child: const Text(
                                          'B',
                                          style: TextStyle(
                                              color: ColorManagement.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            color: controller
                                                .colors['in']!['main'],
                                            child: Text(
                                              'Check in',
                                              style: TextStyle(
                                                  color: controller
                                                      .colors['in']!['text'],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none),
                                            )),
                                      )
                                    ],
                                  ))),
                          const Divider(
                              color: ColorManagement.borderCell,
                              thickness: 1,
                              height: 4),
                          //check out color
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                vertical: SizeManagement.rowSpacing),
                            child: NeutronTextTitle(
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CHECKOUT_COLOR),
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'out',
                                          'text',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: controller.colors['out']!['text'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TEXT_COLOR),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'out',
                                          'main',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color: controller.colors['out']!['main'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_BACKGROUND),
                                ),
                              ),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: SizeManagement.rowSpacing),
                            alignment: Alignment.center,
                            child: Container(
                                width: 100,
                                height: GeneralManager.bookingCellHeight,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 8),
                                color: controller.colors['out']!['main'],
                                child: Text(
                                  'Check out',
                                  style: TextStyle(
                                      color: controller.colors['out']!['text'],
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none),
                                )),
                          ),
                          const Divider(
                              color: ColorManagement.borderCell,
                              thickness: 1,
                              height: 4),
                          //unconfirmed in color
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                vertical: SizeManagement.rowSpacing),
                            child: NeutronTextTitle(
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_UNCONFIRMED_COLOR),
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'unconfirmed',
                                          'text',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color:
                                      controller.colors['unconfirmed']!['text'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TEXT_COLOR),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => _buildColorPicker(
                                          context,
                                          'unconfirmed',
                                          'main',
                                          colorConfigController));
                                },
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(right: 4),
                                  color:
                                      controller.colors['unconfirmed']!['main'],
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_BACKGROUND),
                                ),
                              ),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                            ],
                          ),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: SizeManagement.rowSpacing),
                              alignment: Alignment.center,
                              child: SizedBox(
                                  width: 100,
                                  height: GeneralManager.bookingCellHeight,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: GeneralManager.bedCellWidth,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        color: controller
                                            .colors['unconfirmed']!['bed'],
                                        child: const Text(
                                          'B',
                                          style: TextStyle(
                                              color: ColorManagement.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            color: controller
                                                .colors['unconfirmed']!['main'],
                                            child: Text(
                                              'Unconfirmed',
                                              style: TextStyle(
                                                  color: controller.colors[
                                                      'unconfirmed']!['text'],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none),
                                            )),
                                      )
                                    ],
                                  ))),
                          const SizedBox(height: SizeManagement.rowSpacing),
                          NeutronButton(
                            onPressed: () async {
                              String? result = await controller.updateColor();
                              if (!mounted) {
                                return;
                              }
                              if (result == MessageCodeUtil.SUCCESS) {
                                bool? confirmResult = await MaterialUtil.showConfirm(
                                    context,
                                    MessageUtil.getMessageByCode(MessageCodeUtil
                                        .TEXTALERT_CHANGE_COLOR_SUCCESS_AND_RELOAD));
                                if (confirmResult == null || !confirmResult) {
                                  return;
                                }
                                GeneralManager().rebuild();
                              } else {
                                MaterialUtil.showAlert(context,
                                    MessageUtil.getMessageByCode(result));
                              }
                            },
                            icon: Icons.save,
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_SAVE),
                          )
                        ],
                      ),
              ),
            ),
          )),
    );
  }

  Dialog _buildColorPicker(BuildContext context, String type, String component,
      ColorConfigController colorConfigController) {
    Color tempColor = colorConfigController.colors[type]![component]!;
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Theme(
        data: ThemeData.dark(),
        child: SizedBox(
          width: kMobileWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialPicker(
                  // colorPickerWidth: kMobileWidth,
                  // enableAlpha: false,
                  // hexInputBar: true,
                  // portraitOnly: true,
                  enableLabel: true,
                  onColorChanged: (Color color) {
                    tempColor = color;
                  },
                  pickerColor: tempColor,
                ),
                NeutronButton(
                  tooltip1:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CANCEL),
                  tooltip2:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SAVE),
                  icon1: Icons.cancel,
                  onPressed1: () {
                    Navigator.pop(context);
                  },
                  icon2: Icons.save,
                  onPressed2: () {
                    colorConfigController.setColor(type, component, tempColor);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorConfigController extends ChangeNotifier {
  bool isInProgress = false;
  Map<String, Map<String, Color>> colors = {};

  ColorConfigController() {
    colors['book'] = <String, Color>{};
    colors['in'] = <String, Color>{};
    colors['out'] = <String, Color>{};
    colors['unconfirmed'] = <String, Color>{};
    if (GeneralManager.hotel!.colors!.isEmpty) {
      colors['in']!['bed'] = ColorManagement.bedNameOfCheckinBooking;
      colors['in']!['text'] = ColorManagement.bookingNameOfCheckinBooking;
      colors['in']!['main'] = ColorManagement.checkinBooking;

      colors['book']!['bed'] = ColorManagement.bedNameOfBookedBooking;
      colors['book']!['text'] = ColorManagement.bookingNameOfBookedBooking;
      colors['book']!['main'] = ColorManagement.bookedBooking;

      colors['out']!['text'] = ColorManagement.bookingNameOfCheckoutBooking;
      colors['out']!['main'] = ColorManagement.checkoutBooking;

      colors['unconfirmed']!['bed'] = ColorManagement.greenColor;
      colors['unconfirmed']!['text'] =
          ColorManagement.bookingNameOfCheckoutBooking;
      colors['unconfirmed']!['main'] = ColorManagement.bookingUnconfirmed;
    } else {
      colors['in']!['bed'] = Color(GeneralManager.hotel!.colors!['in']['bed']);
      colors['in']!['text'] =
          Color(GeneralManager.hotel!.colors!['in']['text']);
      colors['in']!['main'] =
          Color(GeneralManager.hotel!.colors!['in']['main']);

      colors['book']!['bed'] =
          Color(GeneralManager.hotel!.colors!['book']['bed']);
      colors['book']!['text'] =
          Color(GeneralManager.hotel!.colors!['book']['text']);
      colors['book']!['main'] =
          Color(GeneralManager.hotel!.colors!['book']['main']);

      colors['out']!['text'] =
          Color(GeneralManager.hotel!.colors!['out']['text']);
      colors['out']!['main'] =
          Color(GeneralManager.hotel!.colors!['out']['main']);

      colors['unconfirmed']!['bed'] = ColorManagement.greenColor;
      if (GeneralManager.hotel!.colors!['unconfirmed'] == null) {
        colors['unconfirmed']!['text'] =
            ColorManagement.bookingNameOfCheckoutBooking;
        colors['unconfirmed']!['main'] = ColorManagement.bookingUnconfirmed;
      } else {
        colors['unconfirmed']!['text'] =
            Color(GeneralManager.hotel!.colors!['unconfirmed']['text']);
        colors['unconfirmed']!['main'] =
            Color(GeneralManager.hotel!.colors!['unconfirmed']['main']);
      }
    }
  }

  void setColor(String type, String component, Color newColor) {
    if (colors[type]![component]!.value == newColor.value) {
      return;
    }
    colors[type]![component] = newColor;
    notifyListeners();
  }

  bool isChangeValue() {
    if (GeneralManager.hotel!.colors!.isEmpty) {
      return true;
    }
    if (GeneralManager.hotel!.colors!['in']['bed'] !=
            colors['in']!['bed']!.value ||
        GeneralManager.hotel!.colors!['in']['text'] !=
            colors['in']!['text']!.value ||
        GeneralManager.hotel!.colors!['in']['main'] !=
            colors['in']!['main']!.value ||
        GeneralManager.hotel!.colors!['book']['bed'] !=
            colors['book']!['bed']!.value ||
        GeneralManager.hotel!.colors!['book']['text'] !=
            colors['book']!['text']!.value ||
        GeneralManager.hotel!.colors!['book']['main'] !=
            colors['book']!['main']!.value ||
        GeneralManager.hotel!.colors!['out']['main'] !=
            colors['out']!['main']!.value ||
        GeneralManager.hotel!.colors!['out']['text'] !=
            colors['out']!['text']!.value ||
        GeneralManager.hotel!.colors!['unconfirmed']['main'] !=
            colors['unconfirmed']!['main']!.value ||
        GeneralManager.hotel!.colors!['unconfirmed']['text'] !=
            colors['unconfirmed']!['text']!.value) {
      return true;
    }
    return false;
  }

  Future<String> updateColor() async {
    if (!isChangeValue()) {
      return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
    }
    Map<String, Map<String, int>> dataUpdate = {};
    dataUpdate['in'] = {};
    dataUpdate['in']!['text'] = colors['in']!['text']!.value;
    dataUpdate['in']!['main'] = colors['in']!['main']!.value;
    dataUpdate['in']!['bed'] = colors['in']!['bed']!.value;

    dataUpdate['book'] = {};
    dataUpdate['book']!['text'] = colors['book']!['text']!.value;
    dataUpdate['book']!['main'] = colors['book']!['main']!.value;
    dataUpdate['book']!['bed'] = colors['book']!['bed']!.value;

    dataUpdate['out'] = {};
    dataUpdate['out']!['text'] = colors['out']!['text']!.value;
    dataUpdate['out']!['main'] = colors['out']!['main']!.value;

    dataUpdate['unconfirmed'] = {};
    dataUpdate['unconfirmed']!['text'] = colors['unconfirmed']!['text']!.value;
    dataUpdate['unconfirmed']!['main'] = colors['unconfirmed']!['main']!.value;

    isInProgress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-configureColor')
        .call({'hotel_id': GeneralManager.hotelID, 'colors': dataUpdate})
        .then((value) => value.data)
        .onError((error, stackTrace) => error.toString());
    if (result == MessageCodeUtil.SUCCESS) {
      GeneralManager.hotel!.colors = Map.from(dataUpdate);
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }
}
