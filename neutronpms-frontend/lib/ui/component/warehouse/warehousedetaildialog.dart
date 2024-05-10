import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/component/warehouse/export/exportdialog.dart';
import 'package:ihotel/ui/component/warehouse/import/importdialog.dart';
import 'package:ihotel/ui/component/warehouse/transfer/transferdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../manager/roles.dart';
import '../../../manager/usermanager.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../util/materialutil.dart';
import '../management/accounting/accountingdialog.dart';

class WarehouseDetailDialog extends StatefulWidget {
  final Warehouse warehouse;
  const WarehouseDetailDialog({Key? key, required this.warehouse})
      : super(key: key);

  @override
  State<WarehouseDetailDialog> createState() => _WarehouseDetailDialogState();
}

class _WarehouseDetailDialogState extends State<WarehouseDetailDialog> {
  WarehouseNotesManager? warehouseNotesManager;

  @override
  void initState() {
    warehouseNotesManager = WarehouseNotesManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);
    final double width = isNotDesktop ? kMobileWidth : kWidth;

    final Widget children = widget.warehouse.items!.isEmpty
        ? Center(
            child: NeutronTextContent(
                message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)))
        : ListView.builder(
            itemCount: widget.warehouse.items!.length,
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManagement.cardOutsideHorizontalPadding),
            itemBuilder: (context, index) {
              final String idItem =
                  widget.warehouse.items!.keys.elementAt(index);
              final HotelItem? item = ItemManager().getItemById(idItem);
              final num amount = widget.warehouse.getAmountOfItem(idItem) ?? 0;
              return Container(
                decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? ColorManagement.oddColor
                        : ColorManagement.evenColor,
                    borderRadius:
                        BorderRadius.circular(SizeManagement.borderRadius8)),
                margin:
                    const EdgeInsets.only(bottom: SizeManagement.rowSpacing),
                child: Row(
                  children: [
                    //image
                    Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: item!.image != null
                          ? Image.memory(item.image!)
                          : NeutronTextContent(
                              textOverflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              fontSize: 10,
                              message: MessageUtil.getMessageByCode(
                                  MessageCodeUtil.TEXTALERT_NO_AVATAR),
                            ),
                    ),
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    //id
                    if (!isNotDesktop)
                      Expanded(
                        flex: 2,
                        child: NeutronTextContent(message: item.id!),
                      ),
                    //name
                    Expanded(
                      flex: 3,
                      child: NeutronTextContent(
                          tooltip: item.name, message: item.name!),
                    ),
                    //status
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: NeutronTextContent(
                            textAlign: TextAlign.center,
                            message: UITitleUtil.getTitleByCode(item.isActive!
                                ? UITitleCode.STATUS_ACTIVE
                                : UITitleCode.STATUS_DEACTIVE)),
                      ),
                    ),
                    //amount
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: NeutronTextContent(
                            message: NumberUtil.numberFormat.format(amount)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: kHeight,
        child: Scaffold(
          backgroundColor: ColorManagement.mainBackground,
          floatingActionButton: FloatingActionButton(
            mini: true,
            backgroundColor: ColorManagement.lightMainBackground,
            onPressed: () async {
              await WarehouseManager()
                  .exportToExcel(widget.warehouse)
                  .whenComplete(() => Navigator.pop(context));
            },
            child: const Icon(
              Icons.file_present_rounded,
              color: ColorManagement.white,
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: SizeManagement.marginBottomForStack),
                child: Column(children: [
                  //header
                  Container(
                    margin: const EdgeInsets.only(
                      top: SizeManagement.topHeaderTextSpacing,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            SizeManagement.cardOutsideHorizontalPadding),
                    alignment: Alignment.center,
                    child: NeutronTextHeader(message: widget.warehouse.name!),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  //title
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(
                          width: SizeManagement.cardInsideHorizontalPadding),
                      //image
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        child: NeutronTextTitle(
                          fontSize: 14,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_IMAGE),
                        ),
                      ),
                      const SizedBox(
                          width: SizeManagement.cardInsideHorizontalPadding),
                      //id
                      if (!isNotDesktop)
                        Expanded(
                          flex: 2,
                          child: NeutronTextTitle(
                              fontSize: 14,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ID)),
                        ),
                      //name
                      Expanded(
                        flex: 3,
                        child: NeutronTextTitle(
                            fontSize: 14,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ITEM)),
                      ),
                      //status
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: NeutronTextTitle(
                              fontSize: 14,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_STATUS_COMPACT)),
                        ),
                      ),
                      //amount
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: NeutronTextTitle(
                              fontSize: 14,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_AMOUNT_COMPACT)),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: children),
                ]),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                  icon: Icons.add,
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_IMPORT_ITEM),
                  onPressed: () async {
                    warehouseNotesManager!.noteType!
                        .add(WarehouseNotesType.import);
                    final Map<String, dynamic>? result = await showDialog(
                        context: context,
                        builder: (context) => ImportDialog(
                              warehouseNotesManager: warehouseNotesManager,
                              priorityWarehouse: widget.warehouse,
                              isImportExcelFile: false,
                            ));
                    if (result == null) {
                      return;
                    }
                    if (UserManager.role!.contains(Roles.accountant) ||
                        UserManager.canCRUDWarehouseNote()) {
                      // ignore: use_build_context_synchronously
                      final bool? confirmResult = await MaterialUtil.showConfirm(
                          context,
                          MessageUtil.getMessageByCode(MessageCodeUtil
                              .CONFIRM_CREATE_COST_MANAGEMENT_AFTER_IMPORT));

                      if (confirmResult == null || !confirmResult) {
                        return;
                      }
                      // ignore: use_build_context_synchronously
                      await showDialog(
                          context: context,
                          builder: (context) => AddAccountingDialog(
                                inputData: result,
                              ));
                    }
                  },
                  icon1: Icons.remove,
                  tooltip1: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_EXPORT_ITEM),
                  onPressed1: () {
                    Navigator.pop(context);
                    warehouseNotesManager!.noteType![0] =
                        WarehouseNotesType.export;
                    showDialog(
                        context: context,
                        builder: (context) => ExportDialog(
                              warehouseNotesManager: warehouseNotesManager,
                              priorityWarehouse: widget.warehouse,
                              isImportExcelFile: false,
                            ));
                  },
                  icon2: Icons.compare_arrows_rounded,
                  tooltip2: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_TRANSFER_ITEM),
                  onPressed2: () {
                    Navigator.pop(context);
                    warehouseNotesManager!.noteType![0] =
                        WarehouseNotesType.transfer;
                    showDialog(
                        context: context,
                        builder: (context) => TransferDialog(
                              warehouseNotesManager: warehouseNotesManager,
                              priorityWarehouse: widget.warehouse,
                              isImportExcelFile: false,
                            ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
