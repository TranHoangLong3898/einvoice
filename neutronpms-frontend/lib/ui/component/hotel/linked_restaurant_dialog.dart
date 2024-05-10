import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotel/linked_restaurant_controller.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';

class LinkedRestaurantDialog extends StatefulWidget {
  const LinkedRestaurantDialog({Key? key}) : super(key: key);

  @override
  State<LinkedRestaurantDialog> createState() => _LinkedRestaurantDialogState();
}

class _LinkedRestaurantDialogState extends State<LinkedRestaurantDialog> {
  LinkedRestaurantController? _linkedRestaurantController;

  @override
  void initState() {
    _linkedRestaurantController ??= LinkedRestaurantController();
    _linkedRestaurantController!.listenColRestaurant();
    super.initState();
  }

  @override
  void dispose() {
    _linkedRestaurantController?.dispol();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth;
    }

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: width,
            height: height,
            child: Scaffold(
              backgroundColor: ColorManagement.mainBackground,
              appBar: AppBar(
                title: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_RESTAURANT)),
                backgroundColor: ColorManagement.mainBackground,
              ),
              body: ChangeNotifierProvider<LinkedRestaurantController>.value(
                  value: _linkedRestaurantController!,
                  child: Consumer<LinkedRestaurantController>(
                      builder: (_, controller, __) {
                    if (controller.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: ColorManagement.greenColor));
                    }

                    // UI desktop
                    final chilren = !isMobile
                        ? controller.restaurantDisplay.map((restaurant) {
                            return Container(
                              height: SizeManagement.cardHeight,
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.cardOutsideVerticalPadding,
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              decoration: BoxDecoration(
                                  color: ColorManagement.lightMainBackground,
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8)),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: SizeManagement
                                        .cardInsideHorizontalPadding,
                                  ),
                                  Expanded(
                                      child: NeutronTextContent(
                                    message: restaurant.nameRes!,
                                  )),
                                  Expanded(
                                      child: NeutronTextContent(
                                    tooltip: restaurant.email,
                                    message: restaurant.email!,
                                  )),
                                  Expanded(
                                    child: NeutronTextContent(
                                        textAlign: TextAlign.center,
                                        message: DateUtil
                                            .dateToDayMonthYearHourMinuteString(
                                                restaurant.created!)),
                                  ),
                                  // swith linked restaurant
                                  SizedBox(
                                      width: 100,
                                      child: Switch(
                                          value: restaurant.isLinked!,
                                          activeColor:
                                              ColorManagement.greenColor,
                                          inactiveTrackColor:
                                              ColorManagement.mainBackground,
                                          onChanged: (value) async {
                                            final String result = await controller
                                                .activeOrDeactiveLinkedRestaurant(
                                                    restaurant);
                                            if (result !=
                                                MessageCodeUtil.SUCCESS) {
                                              // ignore: use_build_context_synchronously
                                              MaterialUtil.showAlert(
                                                  context, result);
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              MaterialUtil.showSnackBar(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      result));
                                            }
                                          })),
                                ],
                              ),
                            );
                          }).toList()
                        // UI mobile
                        : controller.restaurantDisplay.map((restaurant) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground),
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.cardOutsideVerticalPadding,
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardInsideHorizontalPadding),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: NeutronTextContent(
                                          tooltip: restaurant.nameRes,
                                          message: restaurant.nameRes!),
                                    ),
                                    const SizedBox(width: 10),
                                    Switch(
                                        value: restaurant.isLinked!,
                                        activeColor: ColorManagement.greenColor,
                                        inactiveTrackColor:
                                            ColorManagement.mainBackground,
                                        onChanged: (value) async {
                                          final String result = await controller
                                              .activeOrDeactiveLinkedRestaurant(
                                                  restaurant);
                                          if (result !=
                                              MessageCodeUtil.SUCCESS) {
                                          } else {}
                                        }),
                                  ],
                                ),
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: NeutronTextContent(
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_EMAIL_RES),
                                            )),
                                            Expanded(
                                                child: NeutronTextContent(
                                              tooltip: restaurant.email,
                                              message: restaurant.email!,
                                            ))
                                          ],
                                        ),
                                        const SizedBox(
                                            height: SizeManagement
                                                .cardInsideHorizontalPadding),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: NeutronTextContent(
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DATE),
                                            )),
                                            Expanded(
                                                child: NeutronTextContent(
                                                    message: DateUtil
                                                        .dateToDayMonthYearHourMinuteString(
                                                            restaurant
                                                                .created!)))
                                          ],
                                        ),
                                        const SizedBox(
                                            height: SizeManagement
                                                .cardInsideHorizontalPadding),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList();
                    return Column(
                      children: [
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        //title
                        !isMobile
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: SizeManagement
                                            .cardInsideHorizontalPadding +
                                        SizeManagement
                                            .cardOutsideHorizontalPadding,
                                  ),
                                  Expanded(
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME_RES),
                                    ),
                                  ),
                                  Expanded(
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_EMAIL_RES),
                                    ),
                                  ),
                                  Expanded(
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      textAlign: TextAlign.center,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_DATE),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_LINKED_RES),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME_RES),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  NeutronTextTitle(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_LINKED_RES),
                                  ),
                                  const SizedBox(width: 60),
                                ],
                              ),
                        Expanded(
                            child: controller.restaurantDisplay.isNotEmpty
                                ? ListView(
                                    children: chilren,
                                  )
                                : Center(
                                    child: NeutronTextContent(
                                      message: MessageUtil.getMessageByCode(
                                          MessageCodeUtil.NO_DATA),
                                    ),
                                  )),
                      ],
                    );
                  })),
            )));
  }
}
