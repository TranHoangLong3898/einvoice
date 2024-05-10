import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronDateTimePickerBorder extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime)? onPressed;
  final bool? isEditDateTime;
  final String? label;
  final bool isRequiredlabel;
  final String Function(DateTime)? formatDate;

  const NeutronDateTimePickerBorder({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onPressed,
    this.isEditDateTime,
    this.label,
    this.isRequiredlabel = false,
    this.formatDate,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: InputDecorator(
        decoration: InputDecoration(
          label: label != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                      text: TextSpan(
                          text: label,
                          style: NeutronTextStyle.content,
                          children: <TextSpan>[
                        if (isRequiredlabel)
                          const TextSpan(
                              text: ' *', style: TextStyle(color: Colors.red))
                      ])),
                )
              : null,
          isDense: true,
          fillColor: ColorManagement.mainBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            borderSide:
                const BorderSide(color: ColorManagement.borderCell, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: NeutronTextContent(
                  message: dateInfo,
                ),
              ),
            ),
            if (isEditDateTime!)
              IconButton(
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    try {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate ?? DateTime.now(),
                          firstDate: firstDate!,
                          lastDate: lastDate!,
                          builder: (context, child) =>
                              DateTimePickerDarkTheme.buildDarkTheme(
                                  context, child!));
                      onPressed!(picked!);
                    } catch (e) {}
                  },
                  icon: const Icon(Icons.calendar_today))
          ],
        ),
      ),
    );
  }

  String get dateInfo {
    if (initialDate == null) return "#N/A";
    if (formatDate != null) return formatDate!(initialDate!);
    return DateUtil.dateToString(initialDate!);
  }
}

class DateTimePickerDarkTheme {
  static Theme buildDarkTheme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: ColorManagement.white,
          onPrimary: Colors.black,
          surface: Color.fromARGB(255, 66, 66, 66),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            color: ColorManagement.lightColorText,
          ),
        ),
        dialogBackgroundColor: ColorManagement.mainBackground,
      ),
      child: child,
    );
  }
}

class NeutronHourPicker {
  final ThemeData darkThemeData = ThemeData().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: ColorManagement.white,
      onPrimary: Colors.white,
      surface: Color.fromARGB(255, 66, 66, 66),
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        color: ColorManagement.lightColorText,
      ),
    ),
    dialogBackgroundColor: ColorManagement.mainBackground,
  );

  final TimeOfDay initTime;
  final BuildContext context;

  NeutronHourPicker({required this.context, required this.initTime});

  Future<TimeOfDay?> pickTime() async {
    return await showTimePicker(
        context: context,
        builder: (context, child) => Theme(
              data: darkThemeData,
              child: child!,
            ),
        initialTime: initTime);
  }
}
