import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controller/management/bikerentalmanagementcontrollder.dart';
import '../../../../modal/service/bikerental.dart';
import '../../../../modal/status.dart';
import '../../../controls/neutronbuttontext.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/responsiveutil.dart';

class BikeRentalManagement extends StatefulWidget {
  const BikeRentalManagement({Key? key}) : super(key: key);
  @override
  State<BikeRentalManagement> createState() => _BikeRentalManagementState();
}

class _BikeRentalManagementState extends State<BikeRentalManagement> {
  final BikeRentalManagementController bikeRentalManagementController =
      BikeRentalManagementController(BikeRentalProgress.checkin);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width = isMobile ? kMobileWidth : kLargeWidth;
    const height = kHeight;

    return SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider.value(
            value: bikeRentalManagementController,
            child: Consumer<BikeRentalManagementController>(
                builder: (_, controller, __) {
              final children = controller.isLoadding
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ))
                  : (controller.bikeRentals.isEmpty
                      ? Center(
                          child: NeutronTextContent(
                              message: MessageUtil.getMessageByCode(
                                  MessageCodeUtil.NO_DATA)),
                        )
                      : ListView(
                          children: controller.bikeRentals
                              .map((bikeRental) => isMobile
                                  ? buildContentMobile(bikeRental, controller)
                                  : buicontentPC(bikeRental, controller))
                              .toList()));

              return Stack(fit: StackFit.expand, children: [
                Container(
                    width: width,
                    height: height,
                    margin: const EdgeInsets.only(bottom: 65),
                    child: Column(
                      children: [
                        //title
                        !isMobile ? buildTitlePc() : buildTitleMobile(),
                        Expanded(child: children),
                        //pagination
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    controller.getBikeRentalsFirstPage();
                                  },
                                  icon: const Icon(Icons.skip_previous)),
                              IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    controller.getBikeRentalsPreviousPage();
                                  },
                                  icon: const Icon(
                                    Icons.navigate_before_sharp,
                                  )),
                              IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    controller.getBikeRentalsNextPage();
                                  },
                                  icon: const Icon(
                                    Icons.navigate_next_sharp,
                                  )),
                              IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    controller.getBikeRentalsLastPage();
                                  },
                                  icon: const Icon(Icons.skip_next)),
                            ],
                          ),
                        )
                      ],
                    )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: NeutronButtonText(
                        text:
                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} ${NumberUtil.numberFormat.format(controller.getTotal())}"))
              ]);
            })));
  }

  Container buildTitleMobile() => Container(
        padding: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding +
                SizeManagement.cardInsideHorizontalPadding),
        child: Row(
          children: [
            Expanded(
              child: NeutronTextTitle(
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BIKE),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: NeutronTextTitle(
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_START),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
              ),
            ),
            const SizedBox(width: 34)
          ],
        ),
      );

  Container buildTitlePc() => Container(
      height: 50,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Row(
        children: [
          const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          Expanded(
              child: NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER),
          )),
          Expanded(
              child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
          )),
          Expanded(
              child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BIKE),
          )),
          Expanded(
              child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
          )),
          Expanded(
              child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_START),
          )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
          )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
          )),
          const SizedBox(width: 40),
          const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
        ],
      ));

  Container buicontentPC(
          BikeRental bikeRental, BikeRentalManagementController controller) =>
      Container(
        height: SizeManagement.cardHeight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideVerticalPadding),
        child: Row(
          children: [
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            Expanded(
              child: NeutronTextContent(
                  message: SupplierManager()
                      .getSupplierNameByID(bikeRental.supplierID!)),
            ),
            Expanded(
              child: NeutronTextContent(
                message: bikeRental.type!,
              ),
            ),
            Expanded(child: NeutronTextContent(message: bikeRental.bike!)),
            Expanded(
                child: NeutronTextContent(
                    tooltip: bikeRental.name, message: bikeRental.name!)),
            const SizedBox(width: 8),
            Expanded(
                child: NeutronTextContent(
                    tooltip: RoomManager().getNameRoomById(bikeRental.room!),
                    message: RoomManager().getNameRoomById(bikeRental.room!))),
            Expanded(
                child: NeutronTextContent(
                    message:
                        '${DateUtil.dateToDayMonthString(bikeRental.start!.toDate())} ${DateUtil.dateToHourMinuteString(bikeRental.start!.toDate())}')),
            Expanded(
                child: Text(
              NumberUtil.numberFormat.format(bikeRental.price),
              textAlign: TextAlign.end,
              style: NeutronTextStyle.positiveNumber,
            )),
            Expanded(
                child: Text(
              NumberUtil.numberFormat.format(bikeRental.getTotal()),
              textAlign: TextAlign.end,
              style: NeutronTextStyle.totalNumber,
            )),
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () async {
                  bool? confirmResult = await MaterialUtil.showConfirm(
                      context,
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_BIKERENTAL_CHECKOUT,
                          [bikeRental.bike!]));
                  if (confirmResult == null || !confirmResult) {
                    return;
                  }
                  String result = await controller.checkoutBike(bikeRental);
                  if (mounted) {
                    MaterialUtil.showResult(
                        context, MessageUtil.getMessageByCode(result));
                  }
                },
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TOOLTIP_CHECKOUT_BIKE),
                icon: const Icon(Icons.bike_scooter_outlined),
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          ],
        ),
      );

  Container buildContentMobile(
          BikeRental bikeRental, BikeRentalManagementController controller) =>
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideVerticalPadding),
        child: ExpansionTile(
          childrenPadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          tilePadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          title: Row(
            children: [
              Expanded(
                child: NeutronTextContent(message: bikeRental.bike!),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: NeutronTextContent(
                    message:
                        '${DateUtil.dateToDayMonthString(bikeRental.start!.toDate())} ${DateUtil.dateToHourMinuteString(bikeRental.start!.toDate())}'),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: NeutronTextContent(
                    textAlign: TextAlign.right,
                    color: ColorManagement.positiveText,
                    message:
                        NumberUtil.moneyFormat.format(bikeRental.getTotal())),
              ),
            ],
          ),
          children: [
            const SizedBox(height: SizeManagement.rowSpacing),
            //supplier
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_SUPPLIER),
                )),
                Expanded(
                    child: NeutronTextContent(
                        message: SupplierManager()
                            .getSupplierNameByID(bikeRental.supplierID!)))
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            //type
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
                )),
                Expanded(
                  child: NeutronTextContent(message: bikeRental.type!),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            //name
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
                )),
                Expanded(
                  child: NeutronTextContent(
                    message: bikeRental.name!,
                  ),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            //room
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
                )),
                Expanded(
                  child: NeutronTextContent(
                    message: RoomManager().getNameRoomById(bikeRental.room!),
                  ),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
                )),
                Expanded(
                  child: NeutronTextContent(
                    color: ColorManagement.positiveText,
                    message: NumberUtil.numberFormat.format(bikeRental.price),
                  ),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  onPressed: () async {
                    bool? confirmResult = await MaterialUtil.showConfirm(
                        context,
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.CONFIRM_BIKERENTAL_CHECKOUT,
                            [bikeRental.bike!]));
                    if (confirmResult == null || !confirmResult) {
                      return;
                    }
                    String result = await controller.checkoutBike(bikeRental);
                    if (mounted) {
                      MaterialUtil.showResult(
                          context, MessageUtil.getMessageByCode(result));
                    }
                  },
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_CHECKOUT_BIKE),
                  icon: const Icon(Icons.bike_scooter_outlined),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
          ],
        ),
      );
}
