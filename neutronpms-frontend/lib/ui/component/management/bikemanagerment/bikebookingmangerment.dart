import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/bikerentalmanagementcontrollder.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../../modal/service/bikerental.dart';

class BikeBookingMangement extends StatefulWidget {
  const BikeBookingMangement({Key? key}) : super(key: key);

  @override
  State<BikeBookingMangement> createState() => _BikeBookingMangementState();
}

class _BikeBookingMangementState extends State<BikeBookingMangement> {
  final BikeRentalManagementController bikeRentalManagementController =
      BikeRentalManagementController(BikeRentalProgress.booked);

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
                                  ? buicontentMobile(bikeRental, controller)
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
                      ],
                    )),
                //pagination
                Container(
                  height: 30,
                  alignment: Alignment.bottomCenter,
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
              ]);
            })));
  }

  Container buicontentMobile(
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
                    message: RoomManager().getNameRoomById(bikeRental.room!),
                  )),
              const SizedBox(width: 4),
              Expanded(
                child: NeutronTextContent(
                  color: ColorManagement.positiveText,
                  message: NumberUtil.numberFormat.format(bikeRental.price),
                ),
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
            //button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  onPressed: () async {
                    String result = await controller.checkinBike(bikeRental);
                    if (mounted) {
                      MaterialUtil.showResult(
                          context, MessageUtil.getMessageByCode(result));
                    }
                  },
                  tooltip: MessageUtil.getMessageByCode(
                      MessageCodeUtil.BIKE_PROGRESS_IN),
                  icon: const Icon(Icons.pedal_bike_sharp),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
          ],
        ),
      );

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
                child: Text(
              NumberUtil.numberFormat.format(bikeRental.price),
              textAlign: TextAlign.start,
              style: NeutronTextStyle.positiveNumber,
            )),
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () async {
                  String result = await controller.checkinBike(bikeRental);
                  if (mounted) {
                    MaterialUtil.showResult(
                        context, MessageUtil.getMessageByCode(result));
                  }
                },
                tooltip: MessageUtil.getMessageByCode(
                    MessageCodeUtil.BIKE_PROGRESS_IN),
                icon: const Icon(Icons.pedal_bike_sharp),
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
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
            textAlign: TextAlign.start,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
          )),
          const SizedBox(width: 40),
          const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
        ],
      ));

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
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
              ),
            ),
            const SizedBox(width: 34)
          ],
        ),
      );
}
