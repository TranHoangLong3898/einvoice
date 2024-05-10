import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/ui/controls/swap_too_fast.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/warehousemanager.dart';
import '../../../../modal/warehouse/inventory/warehousechecknote.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronbutton.dart';
import '../../../controls/neutrondropdown.dart';
import 'inventorycheckdialog.dart';

class ListInventoryCheckDialog extends StatefulWidget {
  const ListInventoryCheckDialog({Key? key}) : super(key: key);

  @override
  State<ListInventoryCheckDialog> createState() =>
      _ListInventoryCheckDialogState();
}

class _ListInventoryCheckDialogState extends State<ListInventoryCheckDialog> {
  final WarehouseNotesManager warehouseNotesManager = WarehouseNotesManager();

  @override
  void initState() {
    warehouseNotesManager.initProperties(WarehouseNotesType.inventoryCheck);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return ChangeNotifierProvider<WarehouseNotesManager>.value(
        value: warehouseNotesManager,
        child: Consumer<WarehouseNotesManager>(builder: (_, controller, __) {
          if (controller.isInProgress == null) {
            return SwapTooFast(action: warehouseNotesManager.getWarehouseNotes);
          }

          if (controller.isInProgress!) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor));
          }

          return Stack(children: [
            Container(
                margin: const EdgeInsets.only(
                    bottom: SizeManagement.marginBottomForStack),
                child: Column(
                  children: [
                    const SizedBox(
                        height: SizeManagement.cardOutsideVerticalPadding * 2),
                    //search
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isNotDesktop ? 100 : 130,
                          height: SizeManagement.cardHeight,
                          child: NeutronDropDown(
                            items: [
                              UITitleUtil.getTitleByCode(UITitleCode.ALL),
                              ...InventorySatus.getInventoryCheckNoteStatus()
                                  .map((e) => UITitleUtil.getTitleByCode(e))
                            ],
                            value: UITitleUtil.getTitleByCode(
                                warehouseNotesManager.status),
                            onChanged: (newStatus) =>
                                warehouseNotesManager.setStatus(newStatus),
                          ),
                        ),
                        const SizedBox(
                            width:
                                SizeManagement.cardOutsideVerticalPadding * 2),
                        SizedBox(
                            width: isNotDesktop ? 130 : 230,
                            height: SizeManagement.cardHeight,
                            child: buildSearch(controller, isNotDesktop)),
                      ],
                    ),
                    if (controller.data.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      //title
                      if (!isNotDesktop) buildTitle(),
                      //list
                      Expanded(child: buildList(isNotDesktop)),
                      //pagination
                      Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                controller.previousPage();
                              },
                              child: Icon(
                                Icons.skip_previous,
                                color: controller.pageIndex >= 0
                                    ? ColorManagement.iconMenuEnableColor
                                    : ColorManagement.iconMenuDisableColor,
                              ),
                            ),
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () {
                                controller.nextPage();
                              },
                              child: const Icon(Icons.skip_next,
                                  color: ColorManagement.iconMenuEnableColor),
                            )
                          ],
                        ),
                      )
                    ],
                    if (controller.data.isEmpty)
                      Expanded(
                        child: Center(
                            child: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    MessageCodeUtil.NO_DATA))),
                      )
                  ],
                )),
            //add-button
            Align(
              alignment: Alignment.bottomCenter,
              child: NeutronButton(
                icon1: Icons.add,
                onPressed1: () async {
                  showDialog(
                      context: context,
                      builder: (context) => InventoryCheckDialog(
                          warehouseNotesManager: warehouseNotesManager));
                },
              ),
            )
          ]);
        }));
  }

  Widget buildTitle() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.rowSpacing,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: NeutronTextTitle(
              fontSize: 14,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_INVOICE_NUMBER),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 14,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR),
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 40)
        ],
      ),
    );
  }

  ListView buildList(bool isMobile) {
    return ListView(
        children: warehouseNotesManager.filterData().where((element) {
      if (warehouseNotesManager.status == MessageCodeUtil.ALL) {
        return true;
      }
      return (element as WarehouseNoteCheck).status ==
          warehouseNotesManager.status;
    }).map((inventoryCheck) {
      return isMobile
          ? InventoryCheckItemInMobile(
              key: Key(inventoryCheck.id!),
              inventoryCheck: inventoryCheck as WarehouseNoteCheck,
              warehouseNotesManager: warehouseNotesManager,
            )
          : InventoryCheckItemInPC(
              key: Key(inventoryCheck.id!),
              inventoryCheck: inventoryCheck as WarehouseNoteCheck,
              warehouseNotesManager: warehouseNotesManager,
            );
    }).toList());
  }

  Widget buildSearch(WarehouseNotesManager controller, bool isNotDesktop) =>
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 280,
          height: SizeManagement.cardHeight,
          child: TextFormField(
            controller: controller.queryString,
            style: const TextStyle(
              color: ColorManagement.lightColorText,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            onChanged: (String value) {
              controller.setQueryString(value);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(
                  SizeManagement.cardInsideHorizontalPadding),
              suffixIcon: InkWell(
                onTap: () => controller.getWarehouseNotes(),
                child: const Icon(
                  Icons.search,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              hintStyle: const TextStyle(
                color: ColorManagement.lightColorText,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                borderSide: const BorderSide(
                    color: ColorManagement.mainBackground, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                borderSide: const BorderSide(
                    color: ColorManagement.mainBackground, width: 1),
              ),
              prefixIcon: isNotDesktop
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: () {
                          controller.checkSearch();
                        },
                        style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor: MaterialStateProperty.all<Color>(
                                ColorManagement.greenColor),
                            fixedSize: MaterialStateProperty.all<Size>(
                                const Size(80, 50))),
                        child: Text(
                          controller.isSearchByInvoice
                              ? UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_INVOICE_NUMBER)
                              : UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CREATOR),
                          style: const TextStyle(
                            color: ColorManagement.lightColorText,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              hintText: controller.isSearchByInvoice
                  ? UITitleUtil.getTitleByCode(
                      UITitleCode.HINT_INPUT_INVOICE_NUMBER_TO_SEARCH)
                  : UITitleUtil.getTitleByCode(
                      UITitleCode.HINT_INPUT_CREATOR_TO_SEARCH),
              fillColor: ColorManagement.lightMainBackground,
              filled: true,
            ),
            cursorColor: ColorManagement.greenColor,
            cursorHeight: 20,
          ),
        ),
      );
}

class InventoryCheckItemInPC extends StatelessWidget {
  const InventoryCheckItemInPC({
    Key? key,
    required this.inventoryCheck,
    required this.warehouseNotesManager,
  }) : super(key: key);

  final WarehouseNoteCheck inventoryCheck;

  final WarehouseNotesManager warehouseNotesManager;

  String? get creator => inventoryCheck.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : inventoryCheck.creator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeManagement.cardHeight,
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardInsideHorizontalPadding),
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.cardOutsideVerticalPadding,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => InventoryCheckDialog(
              inventory: inventoryCheck,
              warehouseNotesManager: warehouseNotesManager,
            ),
          );
        },
        child: Row(
          children: [
            // created time
            SizedBox(
              width: 70,
              child: NeutronTextContent(
                textOverflow: TextOverflow.clip,
                message: DateUtil.dateToDayMonthHourMinuteString(
                    inventoryCheck.createdTime!),
              ),
            ),
            const SizedBox(width: 8),
            //invoice number
            Expanded(
                flex: 2,
                child: NeutronTextContent(
                    textOverflow: TextOverflow.clip,
                    message: inventoryCheck.invoiceNumber ?? "")),
            const SizedBox(width: 8),
            // warehouse
            Expanded(
              flex: 2,
              child: NeutronTextContent(
                  message: WarehouseManager()
                      .getWarehouseNameById(inventoryCheck.warehouse!)!),
            ),
            // status
            Expanded(
              flex: 2,
              child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(inventoryCheck.status!)),
            ),
            //creator
            Expanded(
              flex: 3,
              child: NeutronTextContent(tooltip: creator, message: creator!),
            ),
            const SizedBox(width: 8),
            //excel
            IconButton(
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.download),
                onPressed: () {
                  if (inventoryCheck.status == InventorySatus.BALANCED) {
                    ExcelUlti.exportInventoryBalance(inventoryCheck);
                  } else {
                    ExcelUlti.exportInventoryChecklist(inventoryCheck);
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class InventoryCheckItemInMobile extends StatelessWidget {
  const InventoryCheckItemInMobile({
    Key? key,
    required this.inventoryCheck,
    required this.warehouseNotesManager,
  }) : super(key: key);

  final WarehouseNoteCheck inventoryCheck;

  final WarehouseNotesManager warehouseNotesManager;

  String? get creator => inventoryCheck.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : inventoryCheck.creator;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      color: ColorManagement.lightMainBackground,
      child: ExpansionTile(
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: SizedBox(
          width: 60,
          child: NeutronTextContent(
            message: DateUtil.dateToDayMonthHourMinuteString(
                inventoryCheck.createdTime!),
          ),
        ),
        title: NeutronTextContent(
          message: inventoryCheck.invoiceNumber ?? "",
        ),
        subtitle: NeutronTextContent(
          message: UITitleUtil.getTitleByCode(inventoryCheck.status!),
          color: inventoryCheck.status == InventorySatus.BALANCED
              ? ColorManagement.greenColor
              : ColorManagement.yellowColor,
        ),
        iconColor: ColorManagement.lightColorText,
        children: [
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_WAREHOUSE),
                ),
              ),
              Expanded(
                child: NeutronTextContent(
                    message: WarehouseManager()
                        .getWarehouseNameById(inventoryCheck.warehouse!)!),
              ),
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATED_TIME),
                ),
              ),
              Expanded(
                child: NeutronTextContent(
                    message: DateUtil.dateToDayMonthHourMinuteString(
                        inventoryCheck.createdTime!)),
              ),
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATOR),
                ),
              ),
              Expanded(
                child: NeutronTextContent(message: creator!),
              ),
            ],
          ),
          if (inventoryCheck.status == InventorySatus.BALANCED) ...[
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.HEADER_CHECKER),
                  ),
                ),
                Expanded(
                  child: NeutronTextContent(message: inventoryCheck.checker!),
                ),
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.HEADER_CHECK_TIME),
                  ),
                ),
                Expanded(
                  child: NeutronTextContent(
                      message: DateUtil.dateToDayMonthHourMinuteString(
                          inventoryCheck.checkTime!)),
                ),
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
                  ),
                ),
                Expanded(
                  child: NeutronTextContent(message: inventoryCheck.note ?? ''),
                ),
              ],
            ),
          ],
          const SizedBox(height: SizeManagement.rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                  constraints: const BoxConstraints(maxWidth: 40),
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    if (inventoryCheck.status == InventorySatus.BALANCED) {
                      ExcelUlti.exportInventoryBalance(inventoryCheck);
                    } else {
                      ExcelUlti.exportInventoryChecklist(inventoryCheck);
                    }
                  }),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => InventoryCheckDialog(
                    inventory: inventoryCheck,
                    warehouseNotesManager: warehouseNotesManager,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
