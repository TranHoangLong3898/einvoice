import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronbuttontext.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';

class RoomTypeFormDetails extends StatelessWidget {
  const RoomTypeFormDetails({Key? key, this.mapRoomTypes}) : super(key: key);
  final dynamic mapRoomTypes;
  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double maxWidthOfInputField = isMobile ? 89 : 80;
    final double maxWidthOfNameField = isMobile ? 90 : 110;
    num priceTotal = 0;
    return SizedBox(
      width: isMobile ? kMobileWidth : kWidth - 130,
      child: isMobile
          ? buildContentMobile(priceTotal)
          : buildContentPc(
              maxWidthOfNameField, maxWidthOfInputField, priceTotal),
    );
  }

  Column buildContentPc(
      double maxWidthOfNameField, double maxWidthOfInputField, num priceTotal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        //list items of minibar service
        DataTable(
            columnSpacing: 3,
            horizontalMargin: 3,
            columns: <DataColumn>[
              DataColumn(
                label: SizedBox(
                  width: maxWidthOfNameField,
                  child: NeutronTextTitle(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_ROOMTYPE)),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: maxWidthOfInputField,
                  child: NeutronTextTitle(
                    textAlign: TextAlign.center,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_QUANTITY),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: maxWidthOfInputField,
                  child: NeutronTextTitle(
                    textAlign: TextAlign.right,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PRICE_RAW),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  width: maxWidthOfInputField,
                  child: NeutronTextTitle(
                    textAlign: TextAlign.right,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_TOTAL),
                  ),
                ),
              ),
            ],
            rows: (mapRoomTypes as Map<dynamic, dynamic>)
                .entries
                .where((element) => element.value['num'] != 0)
                .map((roomType) {
              priceTotal += roomType.value['total'];
              return DataRow(
                cells: <DataCell>[
                  //name
                  DataCell(SizedBox(
                    width: maxWidthOfNameField,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: SizeManagement.dropdownLeftPadding),
                      child: NeutronTextContent(
                        message:
                            RoomTypeManager().getRoomTypeNameByID(roomType.key),
                      ),
                    ),
                  )),
                  //qty
                  DataCell(
                    SizedBox(
                      width: maxWidthOfInputField,
                      child: NeutronTextContent(
                          textAlign: TextAlign.center,
                          color: ColorManagement.positiveText,
                          message: roomType.value['num'].toString()),
                    ),
                  ),
                  // price raw
                  DataCell(
                    SizedBox(
                      width: maxWidthOfInputField,
                      child: NeutronTextContent(
                          textAlign: TextAlign.right,
                          color: ColorManagement.positiveText,
                          message: NumberUtil.numberFormat.format(
                              RoomTypeManager()
                                  .getAllRoomTypeByID(roomType.key)
                                  .price)),
                    ),
                  ),
                  // price final
                  DataCell(SizedBox(
                    width: maxWidthOfInputField,
                    child: NeutronTextContent(
                      textAlign: TextAlign.right,
                      color: ColorManagement.positiveText,
                      message: NumberUtil.numberFormat
                          .format(roomType.value['total'])
                          .toString(),
                    ),
                  )),
                ],
              );
            }).toList()
              ..add(DataRow(cells: <DataCell>[
                DataCell.empty,
                DataCell.empty,
                DataCell.empty,
                DataCell(SizedBox(
                  width: maxWidthOfInputField,
                  child: NeutronTextContent(
                    textAlign: TextAlign.right,
                    color: ColorManagement.positiveText,
                    message:
                        NumberUtil.numberFormat.format(priceTotal).toString(),
                  ),
                ))
              ]))),
      ],
    );
  }

  Widget buildContentMobile(num priceTotal) {
    final List<Widget> childrenContent =
        (mapRoomTypes as Map<dynamic, dynamic>).entries.map((e) {
      priceTotal += e.value['total'];
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.mainBackground),
        margin: const EdgeInsets.only(
            left: SizeManagement.cardOutsideHorizontalPadding,
            right: SizeManagement.cardOutsideHorizontalPadding,
            bottom: SizeManagement.bottomFormFieldSpacing),
        child: ExpansionTile(
          title: Row(
            children: [
              SizedBox(
                width: 110,
                child: NeutronTextContent(
                  message: RoomTypeManager().getRoomTypeNameByID(e.key),
                ),
              ),
              const SizedBox(
                width: SizeManagement.rowSpacing,
              ),
              Expanded(
                  child: NeutronTextContent(
                textAlign: TextAlign.right,
                color: ColorManagement.positiveText,
                message:
                    NumberUtil.numberFormat.format(e.value['total']).toString(),
              ))
            ],
          ),
          children: [
            const SizedBox(
              height: SizeManagement.rowSpacing,
            ),
            Row(
              children: [
                const SizedBox(
                  width: SizeManagement.cardOutsideHorizontalPadding,
                ),
                Expanded(
                    child: NeutronTextContent(
                        // textAlign: TextAlign.center,
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_QUANTITY))),
                Expanded(
                    child: NeutronTextContent(
                  textAlign: TextAlign.center,
                  color: ColorManagement.positiveText,
                  message: e.value['num'].toString(),
                )),
              ],
            ),
            const SizedBox(
              height: SizeManagement.rowSpacing,
            ),
            Row(
              children: [
                const SizedBox(
                  width: SizeManagement.cardOutsideHorizontalPadding,
                ),
                Expanded(
                    child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_PRICE_RAW))),
                Expanded(
                    child: NeutronTextContent(
                  textAlign: TextAlign.center,
                  color: ColorManagement.positiveText,
                  message: NumberUtil.numberFormat
                      .format(RoomTypeManager().getRoomTypeByID(e.key).price),
                )),
                const SizedBox(
                  width: SizeManagement.cardOutsideHorizontalPadding,
                ),
              ],
            ),
            const SizedBox(
              height: SizeManagement.rowSpacing,
            ),
          ],
        ),
      );
    }).toList();
    return Column(
      children: [
        const SizedBox(
          height: SizeManagement.rowSpacing,
        ),
        buildTitleMobile(),
        Expanded(child: ListView(children: childrenContent)),
        NeutronButtonText(
          text:
              "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(priceTotal)}",
        )
      ],
    );
  }

  Widget buildTitleMobile() {
    return SizedBox(
      height: SizeManagement.cardHeight,
      child: Row(
        children: [
          const SizedBox(
            width: 2 * SizeManagement.cardOutsideHorizontalPadding,
          ),
          SizedBox(
            width: 110,
            child: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE),
            ),
          ),
          Expanded(
            child: NeutronTextContent(
              textAlign: TextAlign.center,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
            ),
          ),
          const SizedBox(
            width: SizeManagement.cardOutsideHorizontalPadding,
          ),
        ],
      ),
    );
  }
}
