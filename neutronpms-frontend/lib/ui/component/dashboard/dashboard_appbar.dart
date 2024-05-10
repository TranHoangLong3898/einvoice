import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/ui/component/dashboard/activity/dashboard_activity.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../controls/neutrondropdown.dart';

class DashboardAppbar extends StatelessWidget {
  const DashboardAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    return ChangeNotifierProvider.value(
      value: DashboardController.instance,
      child: Consumer<DashboardController>(
        builder: (_, controller, __) => Row(
          children: [
            IconButton(
              onPressed: () => controller.openMenu(),
              icon:
                  const Icon(Icons.menu, color: ColorManagement.lightColorText),
            ),
            const Spacer(),
            buildPeriodOptions(controller),
            const SizedBox(width: 4),
            if (UITitleUtil.getTitleByCode(controller.selectedPeriod) ==
                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) ...[
              //choose date
              buildStage(context, controller),
              //refresh
              IconButton(
                  padding: isMobile
                      ? const EdgeInsets.all(0)
                      : const EdgeInsets.symmetric(horizontal: 8),
                  constraints: BoxConstraints(
                      maxWidth: isMobile ? 30 : 40,
                      minWidth: isMobile ? 30 : 40),
                  onPressed: () async => controller.update(),
                  icon: const Icon(Icons.replay_rounded, size: 20)),
            ],
            if (UITitleUtil.getTitleByCode(controller.selectedPeriod) ==
                UITitleUtil.getTitleByCode(UITitleCode.THIS_YEAR)) ...[
              buildOptionsYear(controller),
            ],
            //end drawer
            if (!ResponsiveUtil.isDesktop(context))
              IconButton(
                padding: const EdgeInsets.fromLTRB(0, 0, 3, 0),
                constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
                onPressed: () => controller.openEndDrawer(),
                icon: const Icon(Icons.more_outlined),
              ),
            //home
            if (UserManager.canSeeStatusPage() && !isMobile)
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
    );
  }

  Widget buildPeriodOptions(DashboardController controller) {
    return NeutronDropDownAppar(
      width: 140,
      value: UITitleUtil.getTitleByCode(controller.selectedPeriod),
      label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STAGE),
      fillColorInPutDecoration: Colors.transparent,
      borderColor: Colors.white,
      items: controller.periodTypes
          .map((e) => UITitleUtil.getTitleByCode(e))
          .toList(),
      onChanged: controller.setPeriodType,
    );
  }

  Widget buildOptionsYear(DashboardController controller) {
    return NeutronDropDownAppar(
      width: 140,
      value: controller.selectYear,
      label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_YEAR),
      fillColorInPutDecoration: Colors.transparent,
      borderColor: Colors.white,
      items: controller.setYear.toList(),
      onChanged: controller.setYearData,
    );
  }

  Widget buildStage(BuildContext context, DashboardController controller) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    return InputDecorator(
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            labelText:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STAGE),
            constraints: BoxConstraints(maxWidth: isMobile ? 150 : 230),
            filled: true,
            fillColor: ColorManagement.lightMainBackground,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                gapPadding: 8,
                borderSide: BorderSide(color: ColorManagement.borderCell))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            NeutronTextContent(
                message: isMobile
                    ? DateUtil.dateToDayMonthString(controller.startDate)
                    : DateUtil.dateToString(controller.startDate)),
            const SizedBox(width: 4),
            InkWell(
              onTap: () async {
                GeneralManager().unfocus(context);
                try {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.startDate,
                    firstDate: controller.startDate
                        .subtract(const Duration(days: 365)),
                    lastDate:
                        controller.startDate.add(const Duration(days: 365)),
                    builder: (context, child) =>
                        DateTimePickerDarkTheme.buildDarkTheme(context, child!),
                  );

                  controller.setStartDate(picked!);
                } catch (e) {}
              },
              child: const Icon(Icons.calendar_today, size: 20),
            ),
            const Spacer(),
            const NeutronTextContent(message: '-'),
            const Spacer(),
            NeutronTextContent(
              message: isMobile
                  ? DateUtil.dateToDayMonthString(controller.endDate)
                  : DateUtil.dateToString(controller.endDate),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () async {
                GeneralManager().unfocus(context);
                try {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.endDate,
                    firstDate: controller.startDate,
                    lastDate:
                        controller.startDate.add(const Duration(days: 60)),
                    builder: (context, child) =>
                        DateTimePickerDarkTheme.buildDarkTheme(context, child!),
                  );
                  controller.setEndDate(picked!);
                } catch (e) {}
              },
              child: const Icon(Icons.calendar_today, size: 20),
            ),
            const SizedBox(width: 4),
          ],
        ));
  }

  void showActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        backgroundColor: ColorManagement.dashboardComponent,
        child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: DashboardActivity(),
        ),
      ),
    );
  }
}
