import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/ui/component/warehouse/export/listexportwarehousedialog.dart';
import 'package:ihotel/ui/component/warehouse/import/listimportwarehousedialog.dart';
import 'package:ihotel/ui/component/warehouse/listwarehousedialog.dart';
import 'package:ihotel/ui/component/warehouse/transfer/listtransferwarehousedialog.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../manager/usermanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/uimultilanguageutil.dart';
import 'inventory/listinventorydialog.dart';
import 'liquidation/listliquidationdialog.dart';
import 'lost/listlostwarehousedialog.dart';

class WarehouseConfigDialog extends StatefulWidget {
  final int? indexSelectedTab;

  const WarehouseConfigDialog({Key? key, this.indexSelectedTab})
      : super(key: key);

  @override
  State<WarehouseConfigDialog> createState() => _WarehouseConfigDialogState();
}

class _WarehouseConfigDialogState extends State<WarehouseConfigDialog>
    with SingleTickerProviderStateMixin {
  final DateTime now = DateTime.now();
  WarehouseNotesManager? warehouseNotesManager;
  TabController? _tabController;

  @override
  void initState() {
    warehouseNotesManager = WarehouseNotesManager();
    WarehouseManager().listenWareHouse();
    WarehouseManager().statusServiceFilter =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
    _tabController = TabController(
        length: UserManager.canSeeWareHouseManagement() ? 7 : 6, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    WarehouseManager().cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNotDesktop = !ResponsiveUtil.isDesktop(context);
    final double width = isNotDesktop ? kMobileWidth : 750;
    const double height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: DefaultTabController(
          length: UserManager.canSeeWareHouseManagement() ? 7 : 6,
          initialIndex: widget.indexSelectedTab ?? 0,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
              title: !isNotDesktop
                  ? NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_WAREHOUSE_MANAGEMENT))
                  : null,
              bottom: TabBar(
                controller: _tabController,
                onTap: (index) {
                  warehouseNotesManager!.setIndex(index);
                  switch (index) {
                    case 1:
                      warehouseNotesManager!
                          .initProperties(WarehouseNotesType.import);
                      break;
                    case 2:
                      warehouseNotesManager!
                          .initProperties(WarehouseNotesType.export);
                      break;
                    case 3:
                      warehouseNotesManager!
                          .initProperties(WarehouseNotesType.liquidation);
                      break;
                    case 4:
                      warehouseNotesManager!
                          .initProperties(WarehouseNotesType.transfer);
                      break;
                    case 5:
                      warehouseNotesManager!
                          .initProperties(WarehouseNotesType.lost);
                      break;
                    case 6:
                      warehouseNotesManager!
                          .initProperties(WarehouseNotesType.inventoryCheck);
                      break;
                  }
                },
                tabs: [
                  if (UserManager.canSeeWareHouseManagement())
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_WAREHOUSE),
                        child: const Tab(icon: Icon(Icons.warehouse))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_IMPORT_ITEM),
                      child: const Tab(
                          icon:
                              Icon(FontAwesomeIcons.rightToBracket, size: 20))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_EXPORT_ITEM),
                      child: const Tab(
                          icon: Icon(FontAwesomeIcons.rightFromBracket,
                              size: 20))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_LIQUIDATION),
                      child: const Tab(icon: Icon(Icons.sell_outlined))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_TRANSFER_ITEM),
                      child: const Tab(
                          icon: Icon(FontAwesomeIcons.rightLeft, size: 20))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_LOST_ITEM),
                      child: const Tab(
                          icon: Icon(FontAwesomeIcons.question, size: 20))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_INVENTORY_CHECK),
                      child: const Tab(icon: Icon(Icons.inventory))),
                ],
              ),
              leading: isNotDesktop ? const Text('') : null,
              leadingWidth: isNotDesktop ? 0 : null,
              actions: [
                ChangeNotifierProvider.value(
                    value: warehouseNotesManager,
                    child: Consumer<WarehouseNotesManager>(
                        builder: (_, controller, __) => Row(
                              children: [
                                if (controller.currentIndex != 0)
                                  IconButton(
                                    onPressed: () {
                                      controller
                                          .exportWarehouseNoteDataToExcel();
                                    },
                                    constraints: const BoxConstraints(
                                        maxWidth: 30, minWidth: 30),
                                    icon:
                                        const Icon(Icons.file_present_rounded),
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TOOLTIP_EXPORT_DATA_TO_EXCEL),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                  ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: isNotDesktop ? 100 : 130,
                                  child: NeutronDatePicker(
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TOOLTIP_START_DATE),
                                    initialDate: controller.startDate,
                                    firstDate: (controller.startDate ?? now)
                                        .subtract(const Duration(days: 365)),
                                    lastDate: (controller.startDate ?? now)
                                        .add(const Duration(days: 365)),
                                    onChange: (DateTime picked) {
                                      warehouseNotesManager!
                                          .setStartDate(picked);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: isNotDesktop ? 100 : 130,
                                  child: NeutronDatePicker(
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TOOLTIP_END_DATE),
                                    initialDate: controller.endDate,
                                    firstDate: (controller.endDate ?? now)
                                        .subtract(const Duration(days: 365)),
                                    lastDate: (controller.endDate ?? now)
                                        .add(const Duration(days: 365)),
                                    onChange: (DateTime picked) {
                                      warehouseNotesManager!.setEndDate(picked);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {
                                    warehouseNotesManager!.getWarehouseNotes();
                                  },
                                  constraints: const BoxConstraints(
                                      maxWidth: 30, minWidth: 30),
                                  icon: const Icon(Icons.search_rounded),
                                  tooltip: UITitleUtil.getTitleByCode(
                                      UITitleCode.TOOLTIP_SEARCH),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                )
                              ],
                            )))
              ],
              backgroundColor: ColorManagement.mainBackground,
            ),
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (UserManager.canSeeWareHouseManagement())
                  const ListWarehouseDialog(),
                const ListImportWarehouseDialog(),
                const ListExportWarehouseDialog(),
                const ListLiquidationWarehouseDialog(),
                const ListTransferWarehouseDialog(),
                const ListLostWarehouseDialog(),
                const ListInventoryCheckDialog(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
