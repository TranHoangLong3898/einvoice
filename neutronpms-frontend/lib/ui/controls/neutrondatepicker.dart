import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:intl/intl.dart';

import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import 'month_picker/simple_month_year_picker.dart';
import 'neutrondatetimepicker.dart';

class NeutronDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String tooltip;
  final bool isMobile;
  final bool formatOfChannel;
  final void Function(DateTime)? onChange;
  final double margin;
  final Color? colorBackground;
  final BoxBorder? border;

  const NeutronDatePicker(
      {Key? key,
      this.initialDate,
      this.firstDate,
      this.lastDate,
      this.onChange,
      this.formatOfChannel = false,
      this.tooltip = '',
      this.isMobile = false,
      this.margin = 10,
      this.colorBackground,
      this.border})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: border,
                color: colorBackground ?? ColorManagement.transparentBackground,
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8)),
            margin: EdgeInsets.symmetric(horizontal: margin, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10),
            child: NeutronTextContent(message: formatDate())),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
              builder: (context, child) =>
                  DateTimePickerDarkTheme.buildDarkTheme(context, child!),
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate!,
              lastDate: lastDate!);
          if (picked != null && onChange != null) {
            onChange!(picked);
          }
        },
      ),
    );
  }

  String formatDate() {
    if (initialDate == null) {
      return '#N/A';
    }
    if (formatOfChannel) {
      return DateFormat('yyyy-MM-dd').format(initialDate!);
    }
    return isMobile
        ? DateUtil.dateToDayMonthString(initialDate!)
        : DateUtil.dateToStringDDMMYYY(initialDate!);
  }
}

class NeutronMonthPicker extends StatelessWidget {
  final DateTime? initialMonth;
  final DateTime? firstMonth;
  final DateTime? lastMonth;
  final String? tooltip;
  final void Function(DateTime)? onChange;

  const NeutronMonthPicker({
    Key? key,
    this.initialMonth,
    this.firstMonth,
    this.lastMonth,
    this.onChange,
    this.tooltip = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: ColorManagement.transparentBackground,
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8)),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: NeutronTextContent(
                message: DateFormat.yMMM(GeneralManager.locale!.toLanguageTag())
                    .format(initialMonth!))),
        onTap: () async {
          final picked = await SimpleMonthYearPicker.showMonthYearPickerDialog(
            context: context,
            backgroundColor: ColorManagement.mainBackground,
            selectionColor: ColorManagement.greenColor,
          );
          if (picked != null && onChange != null) {
            onChange!(picked);
          }
        },
      ),
    );
  }
}
