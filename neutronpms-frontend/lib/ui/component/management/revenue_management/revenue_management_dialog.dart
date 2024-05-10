import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/ui/component/management/revenue_management/add_minus_revenue_dialog.dart';
import 'package:ihotel/ui/component/management/revenue_management/check_revenue_logs.dart';
import 'package:ihotel/ui/component/management/revenue_management/transfer_revenue_dialog.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutronbuttontext.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../handler/firebasehandler.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/uimultilanguageutil.dart';

class RevenueManagementDialog extends StatefulWidget {
  const RevenueManagementDialog({Key? key}) : super(key: key);

  @override
  State<RevenueManagementDialog> createState() =>
      _RevenueManagementDialogState();
}

class _RevenueManagementDialogState extends State<RevenueManagementDialog> {
  late RevenueManagementController controller;

  @override
  void initState() {
    super.initState();
    controller = RevenueManagementController();
  }

  @override
  void dispose() {
    controller.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<RevenueManagementController>(
            child: const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor)),
            builder: (_, controller, child) {
              return Scaffold(
                  backgroundColor: ColorManagement.mainBackground,
                  appBar: buildAppBar(true),
                  body: Column(
                    children: [
                      const SizedBox(height: 10),
                      buildTitle(),
                      const SizedBox(height: 10),
                      Expanded(
                          child:
                              controller.isLoading ? child! : buildContent()),
                      NeutronButton(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_TRANSFER_REVENUE),
                        icon: Icons.arrow_circle_right_outlined,
                        onPressed: addTransferRevenue,
                      )
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
          message:
              UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_REVENUE_USERDRAW)),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_HISTORY),
          icon: FontAwesomeIcons.newspaper,
          // Icons.price_check_rounded,
          onPressed: checkRevenueLogs,
        ),
      ],
    );
  }

  Widget buildTitle() {
    return Row(
      children: [
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding * 2),
        Expanded(
          flex: 2,
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_PAYMENT_METHOD),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            textAlign: TextAlign.end,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
          ),
        ),
        const SizedBox(
            width: 60 + SizeManagement.cardInsideHorizontalPadding * 2),
      ],
    );
  }

  ListView buildContent() {
    return ListView(
        children: PaymentMethodManager().paymentMethodsActive.map(
      (e) {
        if (e.id == PaymentMethodManager.transferMethodID) {
          return const SizedBox();
        }
        return Container(
          height: SizeManagement.cardHeight,
          decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius:
                  BorderRadius.circular(SizeManagement.borderRadius8)),
          margin:
              const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
          child: Row(children: [
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            Expanded(
                // flex: 2,
                child: NeutronTextContent(message: e.name!, tooltip: e.name)),
            const SizedBox(width: 4),
            Expanded(
                child: NeutronTextContent(
              message: NumberUtil.numberFormat
                  .format(controller.revenueDocData[e.id] ?? 0),
              textAlign: TextAlign.end,
              color: (controller.revenueDocData[e.id] ?? 0) >= 0
                  ? ColorManagement.positiveText
                  : ColorManagement.negativeText,
            )),
            // const SizedBox(width: 4),
            IconButton(
              constraints: const BoxConstraints(maxWidth: 30),
              onPressed: () => updateRevenue(e.id!, true),
              icon: Tooltip(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ADD_REVENUE),
                  child: const Icon(Icons.add,
                      color: ColorManagement.orangeColor)),
            ),
            const SizedBox(width: 4),
            IconButton(
              padding: const EdgeInsets.only(bottom: 15),
              constraints: const BoxConstraints(maxWidth: 30, minHeight: 50),
              onPressed: () => updateRevenue(e.id!, false),
              icon: Tooltip(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_MINUS_REVENUE),
                  child: const Icon(
                    Icons.minimize_rounded,
                    color: ColorManagement.orangeColor,
                  )),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          ]),
        );
      },
    ).toList()
          ..add(NeutronButtonText(
            text:
                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} ${NumberUtil.numberFormat.format(controller.totalRevenue)}",
          )));
  }

  void updateRevenue(String methodID, bool isAdd) async {
    await showDialog(
        context: context,
        builder: (context) => AddRevenueDialog(
              methodID: methodID,
              isAdd: isAdd,
            ));
  }

  void addTransferRevenue() async {
    await showDialog(
        context: context,
        builder: (context) =>
            TransferRevenueDialog(controllerRevenue: controller));
  }

  void checkRevenueLogs() async {
    await showDialog(
        context: context, builder: (context) => const RevenueLogsDialog());
  }
}

class RevenueManagementController extends ChangeNotifier {
  late bool isLoading;
  late DateTime now, startDate, endDate;
  StreamSubscription? _streamSubscription;
  late num totalRevenue;
  Map<String, num> revenueDocData = {};

  RevenueManagementController() {
    isLoading = false;
    now = DateTime.now();
    startDate = DateUtil.to0h(now);
    endDate = DateUtil.to24h(now);
    loadRenvenue();
  }

  Future<void> cancelStream() async {
    await _streamSubscription?.cancel();
  }

  Future<void> loadRenvenue() async {
    isLoading = true;
    notifyListeners();
    await _streamSubscription?.cancel();
    _streamSubscription = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colManagement)
        .doc(FirebaseHandler.docRevenue)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        revenueDocData.clear();
        totalRevenue = 0;
        for (var element in snapshot.data()!.entries) {
          revenueDocData.addAll({element.key: element.value});
          totalRevenue += element.value;
        }
      }
      isLoading = false;
      notifyListeners();
    });
  }
}
