import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import 'month_container.dart';

class SimpleMonthYearPicker {
  /// list of Months
  static final List<MonthModel> _monthModelList = [
    MonthModel(index: 1, name: 'Jan'),
    MonthModel(index: 2, name: 'Feb'),
    MonthModel(index: 3, name: 'Mar'),
    MonthModel(index: 4, name: 'Apr'),
    MonthModel(index: 5, name: 'May'),
    MonthModel(index: 6, name: 'Jun'),
    MonthModel(index: 7, name: 'Jul'),
    MonthModel(index: 8, name: 'Aug'),
    MonthModel(index: 9, name: 'Sep'),
    MonthModel(index: 10, name: 'Oct'),
    MonthModel(index: 11, name: 'Nov'),
    MonthModel(index: 12, name: 'Dec'),
  ];

  /// shows dialog to select month and year
  ///
  /// The [context] argument must not be null.
  ///
  /// The [titleFontFamily] is optional.  Defaults to 'Rajdhani' fontFamily.
  /// It sets the font-family to use in 'Select Month' title.
  ///
  /// The [yearTextFontFamily] argument is optional. Defaults to 'Rajdhani' fontFamily.
  /// It sets the font-family to use in displayed year .
  ///
  /// The [monthTextFontFamily] argument is optional. Defaults to 'Rajdhani' fontFamily.
  /// It sets the font-family to use in month text.
  ///
  /// The [backgroundColor] argument is optional. Defaults to Theme.of(context).scaffoldBackgroundColor.
  /// It sets the background color used in the dialog.
  ///
  /// The [selectionColor] argument is optional. Defaults to Theme.of(context).primaryColor.
  /// It sets the background color of selected month, text-color of remaining months and button color.
  ///
  /// The [barrierDismissible] argument is optional and is used to indicate whether tapping on the barrier will dismiss the dialog.
  ///  Defaults to true.
  ///

  static Future showMonthYearPickerDialog({
    @required BuildContext? context,
    String? titleFontFamily,
    String? yearTextFontFamily,
    String? monthTextFontFamily,
    Color? backgroundColor,
    Color? selectionColor,
    bool? barrierDismissible,
  }) async {
    final ThemeData theme = Theme.of(context!);
    var primaryColor = selectionColor ?? theme.primaryColor;
    var bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    /// to get current year
    int selectedYear = DateTime.now().year;

    /// to get index corresponding to current month (1- Jan, 2- Feb,..)
    var selectedMonth = DateTime.now().month;

    final monthPicked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: barrierDismissible ?? true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => MediaQuery.removeViewInsets(
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            context: context,
            child: Align(
              alignment: Alignment.center,
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: bgColor,
                child: Container(
                  width: 370,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //title + select year
                      Row(
                        children: [
                          //title
                          Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SELECT_MONTH),
                            style: TextStyle(
                              fontFamily: titleFontFamily ?? 'Rajdhani',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // left arrow
                          IconButton(
                            onPressed: () => setState(() {
                              selectedYear = selectedYear - 1;
                            }),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 10,
                              color: primaryColor,
                            ),
                          ),
                          //year
                          Text(
                            selectedYear.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: yearTextFontFamily ?? 'Rajdhani',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //right arrow
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedYear = selectedYear + 1;
                              });
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      //list month
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            height: 100,
                            width: 300,
                            child: GridView.builder(
                              itemCount: _monthModelList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6),
                              itemBuilder: (_, index) {
                                var monthModel = _monthModelList[index];
                                return InkWell(
                                  onTap: () => setState(() {
                                    selectedMonth = index + 1;
                                  }),
                                  child: MonthContainer(
                                    fontFamily:
                                        monthTextFontFamily ?? 'Rajdhani',
                                    month: monthModel.name,
                                    fillColor: index + 1 == selectedMonth
                                        ? primaryColor
                                        : bgColor,
                                    borderColor: index + 1 == selectedMonth
                                        ? primaryColor
                                        : bgColor,
                                    textColor: index + 1 != selectedMonth
                                        ? ColorManagement.mainColorText
                                        : bgColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //button: ok and cancel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 30,
                              width: 70,
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border.all(
                                  color: primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                UITitleUtil.getTitleByCode(UITitleCode.CANCEL),
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () {
                              String selectedMonthString = selectedMonth < 10
                                  ? "0$selectedMonth"
                                  : "$selectedMonth";
                              var selectedDate = DateTime.parse(
                                  '$selectedYear-$selectedMonthString-01');
                              Navigator.pop(context, selectedDate);
                            },
                            child: Container(
                              height: 30,
                              width: 70,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'OK',
                                style: TextStyle(color: bgColor),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (monthPicked == null) {
      return null;
    }
    String selectedMonthString =
        selectedMonth < 10 ? "0$selectedMonth" : "$selectedMonth";
    return DateTime.parse('$selectedYear-$selectedMonthString-01');
  }
}
