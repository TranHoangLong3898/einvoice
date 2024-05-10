import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutronwaiting.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class DashboardMuchHotelsAppbar extends StatelessWidget {
  DashboardMuchHotelsAppbar({Key? key}) : super(key: key);
  final DailyDataHotelsController _dailyDataHotelsController =
      DailyDataHotelsController.createInstance();
  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    return ChangeNotifierProvider.value(
      value: _dailyDataHotelsController,
      child: Consumer<DailyDataHotelsController>(
        builder: (_, controller, __) {
          return SizedBox(
            width: isMobile ? double.infinity : null,
            child: SingleChildScrollView(
              scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
              child: SizedBox(
                width: isMobile ? 500 : null,
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Container(
                      width: 130,
                      height: 45,
                      margin: const EdgeInsets.all(8),
                      child: NeutronDropDownCustom(
                        backgroundColor: ColorManagement.lightMainBackground,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.SIDEBAR_HOTEL),
                        childWidget: NeutronDropDown(
                            isTooltip: true,
                            isCenter: true,
                            isPadding: false,
                            onChanged: (value) {
                              controller.setNameHotel(value);
                            },
                            value: controller.selectedNameHotel,
                            items: controller.listNameHotels),
                      ),
                    ),
                    if (controller.years.isNotEmpty)
                      Container(
                        width: 90,
                        height: 45,
                        margin: const EdgeInsets.all(8),
                        child: NeutronDropDownCustom(
                          backgroundColor: ColorManagement.lightMainBackground,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_YEAR),
                          childWidget: NeutronDropDown(
                              isCenter: true,
                              isPadding: false,
                              onChanged: (value) {
                                controller.setYear(value);
                              },
                              value: controller.selectYear,
                              items: controller.years.toList()),
                        ),
                      ),
                    Container(
                      width: 55,
                      height: 45,
                      margin: const EdgeInsets.all(8),
                      child: NeutronDropDownCustom(
                        backgroundColor: ColorManagement.lightMainBackground,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_MONTH),
                        childWidget: NeutronDropDown(
                            isCenter: true,
                            isPadding: false,
                            onChanged: (value) {
                              controller.setMonth(value);
                            },
                            value: controller.selectMonth,
                            items: DateUtil.listMonth),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: NeutronBlurButton(
                        margin: 8,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_REFRESH),
                        icon: Icons.refresh,
                        onPressed: () {
                          controller.loadingData();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: NeutronBlurButton(
                        margin: 0,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                        icon: Icons.file_present_rounded,
                        onPressed: () async {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => WillPopScope(
                                  onWillPop: () => Future.value(false),
                                  child: const NeutronWaiting()));
                          await controller
                              .getAllDailyDataForExporting()
                              .then((value) {
                            if (controller.rawDataExportExcel.isEmpty) return;
                            ExcelUlti.exportReprotDailyDataHotels(
                                controller,
                                controller.totalMapData,
                                controller.dataSetTypeCost,
                                value);
                          }).whenComplete(() => Navigator.pop(context));
                        },
                      ),
                    ),
                    IconButton(
                        padding: isMobile
                            ? const EdgeInsets.fromLTRB(0, 0, 3, 0)
                            : const EdgeInsets.symmetric(horizontal: 8),
                        constraints: BoxConstraints(
                            maxWidth: isMobile ? 30 : 40,
                            minWidth: isMobile ? 30 : 40),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
