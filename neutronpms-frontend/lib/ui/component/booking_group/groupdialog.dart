import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/booking_group/update_group_dialog.dart';
import 'package:ihotel/ui/component/service/servicedialog.dart';
import 'package:ihotel/ui/controls/neutronprintpdf.dart';
import 'package:ihotel/ui/controls/neutronshowconfigdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/contextmenuutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/booking/groupcontroller.dart';
import '../../../controller/booking/notecontroller.dart';
import '../../../manager/generalmanager.dart';
import '../../../manager/usermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutrontextformfield.dart';
import '../booking/bookingdialog.dart';
import '../booking/depositdialog.dart';
import '../booking/discountdialog.dart';
import '../booking/logbookingdialog.dart';
import '../booking/pricedialog.dart';
import 'costbookinggroup.dart';

class GroupDialog extends StatefulWidget {
  final Booking? booking;
  final bool isStatus;

  const GroupDialog({Key? key, this.booking, this.isStatus = true})
      : super(key: key);

  @override
  State<GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<GroupDialog> {
  GroupController? controller;
  final GlobalKey<PopupMenuButtonState> _popupKey = GlobalKey();
  final ScrollController actionButtonScroll = ScrollController();

  @override
  void initState() {
    controller ??= GroupController(widget.booking!.sID!, widget.isStatus);
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width = isMobile ? kMobileWidth : kLargeWidth + 100;
    const height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<GroupController>.value(
          value: controller!,
          child: Consumer<GroupController>(builder: (_, controller, __) {
            if (controller.processing) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor));
            }
            return Scaffold(
              // floatingActionButton: floatingActionButton(controller),
              backgroundColor: ColorManagement.mainBackground,
              appBar: AppBar(
                backgroundColor: ColorManagement.mainBackground,
                title: NeutronTextContent(
                    message:
                        "${UITitleUtil.getTitleByCode(UITitleCode.GROUPDIALOG_TITLE)} - ${controller.getBookingsByFilter().length}"),
                actions: (isMobile)
                    ? const []
                    : UserManager.canSeeStatusPageNotPartnerAndApprover() &&
                            widget.booking!.status != BookingStatus.unconfirmed
                        ? buildActionButton()
                        : const [],
              ),
              body: Column(
                children: [
                  if (isMobile)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: actionButtonScroll,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: UserManager
                                    .canSeeStatusPageNotPartnerAndApprover() &&
                                widget.booking!.status !=
                                    BookingStatus.unconfirmed
                            ? buildActionButton()
                            : [],
                      ),
                    ),
                  SizedBox(
                    height: 45,
                    child: Row(
                      children: [
                        if (!isMobile)
                          //name
                          Expanded(
                            child: NeutronTextTitle(
                              fontSize: 14,
                              isPadding: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_NAME),
                            ),
                          ),
                        //room
                        Expanded(
                          child: NeutronTextTitle(
                            fontSize: 14,
                            isPadding: true,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ROOM),
                          ),
                        ),
                        if (!isMobile) ...[
                          //status
                          Expanded(
                            child: NeutronTextTitle(
                              fontSize: 14,
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_STATUS),
                            ),
                          ),
                          //in
                          Expanded(
                            child: NeutronTextTitle(
                              fontSize: 14,
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_IN_DATE),
                            ),
                          ),
                          //out
                          Expanded(
                            child: NeutronTextTitle(
                              fontSize: 14,
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_OUT_DATE),
                            ),
                          ),
                        ],
                        //deposit
                        Expanded(
                          child: NeutronTextTitle(
                            textAlign: TextAlign.end,
                            fontSize: 14,
                            isPadding: true,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PAYMENT),
                          ),
                        ),
                        if (!isMobile) ...[
                          //AVERAGE room charge
                          Expanded(
                            child: Tooltip(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                              child: NeutronTextTitle(
                                textAlign: TextAlign.end,
                                fontSize: 14,
                                isPadding: true,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                              ),
                            ),
                          ),
                          //room charge
                          Expanded(
                            child: NeutronTextTitle(
                              textAlign: TextAlign.end,
                              fontSize: 14,
                              isPadding: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT),
                            ),
                          ),
                          //service
                          Expanded(
                            child: NeutronTextTitle(
                              textAlign: TextAlign.end,
                              fontSize: 14,
                              isPadding: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SERVICE),
                            ),
                          ),
                          //discount
                          Expanded(
                            child: NeutronTextTitle(
                              textAlign: TextAlign.end,
                              fontSize: 14,
                              isPadding: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DISCOUNT),
                            ),
                          ),
                          // Transffered
                          Expanded(
                            child: SizedBox(
                              width: 60,
                              child: Tooltip(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TRANSFERRED_GROUP),
                                child: NeutronTextTitle(
                                  textAlign: TextAlign.end,
                                  fontSize: 14,
                                  isPadding: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode
                                          .TABLEHEADER_TRANSFERRED_GROUP),
                                ),
                              ),
                            ),
                          ),
                          // Transffering
                          Expanded(
                            child: SizedBox(
                              width: 60,
                              child: Tooltip(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TRANSFERRING_GROUP),
                                child: NeutronTextTitle(
                                  textAlign: TextAlign.end,
                                  fontSize: 14,
                                  isPadding: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode
                                          .TABLEHEADER_TRANSFERRING_GROUP),
                                ),
                              ),
                            ),
                          ),
                          //total charge
                          Expanded(
                            child: NeutronTextTitle(
                              textAlign: TextAlign.end,
                              fontSize: 14,
                              isPadding: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                            ),
                          ),
                        ],

                        //remaining
                        Expanded(
                          child: NeutronTextTitle(
                            textAlign: TextAlign.end,
                            fontSize: 14,
                            isPadding: true,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_REMAIN),
                          ),
                        ),
                        const SizedBox(width: 30),
                        //menu button
                        Expanded(
                            child: IconButton(
                          onPressed: () {
                            controller.setFilter();
                          },
                          icon: const Icon(Icons.filter_alt_outlined),
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.SIDEBAR_FILTER),
                          padding: const EdgeInsets.all(0),
                        )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...controller
                                .getBookingsByFilter()
                                .map((booking) => Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 56, 56, 54)))),
                                      height: 45,
                                      child: Row(
                                        children: [
                                          if (!isMobile)
                                            Expanded(
                                                child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: NeutronTextContent(
                                                message: booking.name!,
                                                tooltip: booking.name,
                                              ),
                                            )),
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: NeutronTextContent(
                                                message: RoomManager()
                                                    .getNameRoomById(
                                                        booking.room!)),
                                          )),
                                          if (!isMobile) ...[
                                            Expanded(
                                                child: NeutronTextContent(
                                                    message: BookingStatus
                                                        .getStatusString(
                                                            booking.status!)!)),
                                            Expanded(
                                                child: NeutronTextContent(
                                                    message: DateUtil
                                                        .dateToDayMonthString(
                                                            booking.inDate!))),
                                            Expanded(
                                                child: NeutronTextContent(
                                                    message: DateUtil
                                                        .dateToDayMonthString(
                                                            booking.outDate!))),
                                          ],
                                          Expanded(
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.end,
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(
                                                          booking.deposit))),
                                          if (!isMobile) ...[
                                            Expanded(
                                                child: SizedBox(
                                              width: 80,
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.end,
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(controller
                                                          .getAvegageRoomChargeByBooking(
                                                              booking))),
                                            )),
                                            Expanded(
                                                child: InkWell(
                                              onTap: () async {
                                                if (controller.bookingParent
                                                        .bookingType ==
                                                    BookingType.monthly) {
                                                  return;
                                                }
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        PriceDialog(
                                                            isCheckGroup: true,
                                                            isReadonly: true,
                                                            priceBooking:
                                                                booking.price!,
                                                            staysday: DateUtil
                                                                .getStaysDay(
                                                                    booking
                                                                        .inDate!,
                                                                    booking
                                                                        .outDate!)));
                                              },
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.end,
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking
                                                          .getRoomCharge())),
                                            )),
                                            Expanded(
                                                child: InkWell(
                                              onTap: () async =>
                                                  await showDialog<String>(
                                                      builder: (ctx) =>
                                                          ServiceDialog(
                                                              booking: booking),
                                                      context: context),
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.end,
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking
                                                          .getServiceCharge())),
                                            )),
                                            Expanded(
                                                child: NeutronTextContent(
                                                    textAlign: TextAlign.end,
                                                    color: ColorManagement
                                                        .negativeText,
                                                    message: booking.discount ==
                                                            0
                                                        ? "0"
                                                        : "-${NumberUtil.numberFormat.format(booking.discount)}")),
                                            // transfferd
                                            Expanded(
                                                child: NeutronTextContent(
                                                    textAlign: TextAlign.end,
                                                    color: ColorManagement
                                                        .positiveText,
                                                    message: NumberUtil
                                                        .numberFormat
                                                        .format(booking
                                                            .transferred))),
                                            // transferring
                                            Expanded(
                                                child: NeutronTextContent(
                                                    textAlign: TextAlign.end,
                                                    color: ColorManagement
                                                        .positiveText,
                                                    message: NumberUtil
                                                        .numberFormat
                                                        .format(booking
                                                            .transferring))),
                                            Expanded(
                                                child: NeutronTextContent(
                                                    textAlign: TextAlign.end,
                                                    color: ColorManagement
                                                        .positiveText,
                                                    message: NumberUtil
                                                        .numberFormat
                                                        .format(booking
                                                            .getTotalCharge()))),
                                          ],
                                          Expanded(
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.end,
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking
                                                          .getRemaining()))),
                                          SizedBox(
                                            width: 30,
                                            child: IconButton(
                                                tooltip: UITitleUtil
                                                    .getTitleByCode(UITitleCode
                                                        .POPUPMENU_PRINT_CHECKOUT),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          NeutronShowConfigDialog(
                                                            enDate: controller
                                                                .endDate,
                                                            startDate:
                                                                controller
                                                                    .startDate,
                                                            onChangeEndDate:
                                                                (p0) {
                                                              controller
                                                                  .setEndDate(
                                                                      p0);
                                                            },
                                                            onChangeStartDate:
                                                                (p0) {
                                                              controller
                                                                  .setStartDate(
                                                                      p0);
                                                            },
                                                            listItem: booking
                                                                        .bookingType ==
                                                                    BookingType
                                                                        .monthly
                                                                ? [
                                                                    ...controller
                                                                        .getDayByMonth()[
                                                                            booking.id]!
                                                                        .toList(),
                                                                    UITitleUtil.getTitleByCode(
                                                                        UITitleCode
                                                                            .CUSTOM)
                                                                  ]
                                                                : null,
                                                            value: controller
                                                                .selectMonth,
                                                            onPressed2:
                                                                (value) {
                                                              controller
                                                                  .setMonth(
                                                                      value);
                                                            },
                                                            onPressed:
                                                                (showOption) async {
                                                              if (showOption[
                                                                      "isShowPrice"]! ||
                                                                  showOption[
                                                                      "isShowService"]!) {
                                                                await PrintPDFToDevice.printPdfAccordingToDevice(
                                                                        context,
                                                                        PDFUtil.buildCheckOutGroupPDFDoc(
                                                                            await controller.exportDpfAndExcel(booking
                                                                                .id!),
                                                                            controller
                                                                                .getTotalDeposit(),
                                                                            controller,
                                                                            showOption[
                                                                                "isShowPrice"]!,
                                                                            showOption[
                                                                                "isShowService"]!,
                                                                            showOption[
                                                                                "isShowPayment"]!,
                                                                            showOption[
                                                                                "isShowRemaining"]!,
                                                                            showOption[
                                                                                "isShowDailyRate"]!),
                                                                        UITitleUtil.getTitleByCode(UITitleCode
                                                                            .POPUPMENU_PRINT_CHECKOUT))
                                                                    .whenComplete(
                                                                        () {
                                                                  controller.setMonth(
                                                                      UITitleUtil.getTitleByCode(
                                                                          UITitleCode
                                                                              .ALL));
                                                                });
                                                              } else {
                                                                MaterialUtil.showAlert(
                                                                    context,
                                                                    MessageUtil.getMessageByCode(
                                                                        MessageCodeUtil
                                                                            .PLEASE_CHOOSE_CHECKBOX));
                                                              }
                                                            },
                                                          ));
                                                },
                                                icon: const Icon(
                                                    Icons.picture_as_pdf)),
                                          ),
                                          Expanded(
                                              child: NeutronBookingContextMenu(
                                            booking: booking,
                                            backgroundColor: ColorManagement
                                                .lightMainBackground,
                                            tooltip: UITitleUtil.getTitleByCode(
                                                UITitleCode.TOOLTIP_MENU),
                                          )),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            SizedBox(
                              height: 45,
                              child: Row(
                                children: [
                                  if (!isMobile)
                                    const Expanded(child: SizedBox()),
                                  const Expanded(child: SizedBox()),
                                  if (!isMobile) ...[
                                    const Expanded(child: SizedBox()),
                                    const Expanded(child: SizedBox()),
                                    const Expanded(child: SizedBox()),
                                  ],
                                  //deposit
                                  Expanded(
                                      child: NeutronTextContent(
                                    textAlign: TextAlign.end,
                                    message: NumberUtil.numberFormat
                                        .format(controller.getTotalDeposit()),
                                    color: ColorManagement.positiveText,
                                  )),
                                  if (!isMobile) ...[
                                    const Expanded(child: SizedBox()),
                                    Expanded(
                                        child: SizedBox(
                                      width: double.infinity,
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        message: NumberUtil.numberFormat.format(
                                            controller.getTotalRoomCharge()),
                                        color: ColorManagement.positiveText,
                                      ),
                                    )),
                                    Expanded(
                                        child: SizedBox(
                                      width: double.infinity,
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        message: NumberUtil.numberFormat.format(
                                            controller.getTotalService()),
                                        color: ColorManagement.positiveText,
                                      ),
                                    )),
                                    Expanded(
                                        child: SizedBox(
                                      width: double.infinity,
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        message: NumberUtil.numberFormat.format(
                                            controller.getTotalDiscount()),
                                        color: ColorManagement.negativeText,
                                      ),
                                    )),
                                    Expanded(
                                        child: SizedBox(
                                      width: double.infinity,
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        message: NumberUtil.numberFormat.format(
                                            controller.getTotalTranfferred()),
                                        color: ColorManagement.positiveText,
                                      ),
                                    )),
                                    Expanded(
                                        child: SizedBox(
                                      width: double.infinity,
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        message: NumberUtil.numberFormat.format(
                                            controller.getTotalTransfferring()),
                                        color: ColorManagement.positiveText,
                                      ),
                                    )),
                                    Expanded(
                                        child: SizedBox(
                                      width: double.infinity,
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        message: NumberUtil.numberFormat.format(
                                            controller.getTotalCharge()),
                                        color: ColorManagement.positiveText,
                                      ),
                                    )),
                                  ],
                                  //remaining
                                  Expanded(
                                    child: NeutronTextContent(
                                      textAlign: TextAlign.end,
                                      message: NumberUtil.numberFormat.format(
                                          controller.getTotalRemaining()),
                                      color: ColorManagement.positiveText,
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  //menu button
                                  Expanded(
                                      child: IconButton(
                                    onPressed: () {
                                      controller.setFilter();
                                    },
                                    icon: const Icon(Icons.filter_alt_outlined),
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.SIDEBAR_FILTER),
                                    padding: const EdgeInsets.all(0),
                                  )),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  ChangeNotifierProvider.value(
                    value: NoteController(booking: widget.booking),
                    child: Consumer<NoteController>(
                      builder: (context, controller, child) => controller.saving
                          ? Container(
                              alignment: Alignment.center,
                              constraints:
                                  const BoxConstraints(maxHeight: kMobileWidth),
                              child: const CircularProgressIndicator(
                                color: ColorManagement.greenColor,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: NeutronTextFormField(
                                backgroundColor:
                                    ColorManagement.lightMainBackground,
                                paddingVertical: 16,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.HINT_NOTES),
                                isDecor: true,
                                maxLine: 4,
                                controller: controller.notesController,
                                suffixIcon: Container(
                                  width: 60,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorManagement.redColor),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: IconButton(
                                      onPressed: () async {
                                        await controller
                                            .saveNotes()
                                            .then((result) {
                                          if (result ==
                                              MessageUtil.getMessageByCode(
                                                  MessageCodeUtil.SUCCESS)) {
                                            MaterialUtil.showSnackBar(
                                                context, result);
                                            Navigator.pop(context);
                                          } else {
                                            MaterialUtil.showAlert(
                                                context, result);
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.save),
                                      color: ColorManagement.white,
                                      alignment: Alignment.center),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // FloatingActionButton floatingActionButton(GroupController controller) =>
  //     FloatingActionButton(
  //       backgroundColor: ColorManagement.redColor,
  //       mini: true,
  //       tooltip:
  //           UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
  //       onPressed: () async {
  //         ExcelUlti.exportBookingGroup(controller);
  //       },
  //       child: const Icon(Icons.file_present_rounded),
  //     );

  List<Widget> buildActionButton() => [
        //detail group
        IconButton(
            icon: const Icon(Icons.group),
            tooltip:
                UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DETAIL_GROUP),
            onPressed: () async {
              await showDialog<String>(
                  context: context,
                  builder: (context) => UpdateGroupDialog(
                      bookings: controller!.getBookingsByFilter(),
                      isUpdate:
                          widget.booking!.status != BookingStatus.checkout &&
                              widget.booking!.status != BookingStatus.cancel &&
                              widget.booking!.status != BookingStatus.noshow));
            }),
        //add
        IconButton(
            icon: const Icon(Icons.add),
            tooltip:
                UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_ADD_BOOKING),
            onPressed: () async {
              String? result = await showDialog<String>(
                  builder: (ctx) => BookingDialog(
                        booking: Booking.empty(
                            group: true,
                            name: controller!.bookingParent.name,
                            bookingType: controller!.bookingParent.bookingType,
                            sID: controller!.bookingParent.sID,
                            inDate: controller!.bookingParent.inDate,
                            outDate: controller!.bookingParent.outDate,
                            sourceID: controller!.bookingParent.sourceID,
                            ratePlanID: controller!.bookingParent.ratePlanID,
                            price: []),
                        addBookingGroup: true,
                      ),
                  context: context);
              if (mounted && result != null) {
                MaterialUtil.showSnackBar(context, result);
              }
            }),
        //checkin
        IconButton(
            icon: const Icon(Icons.flight_land),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CHECKIN),
            onPressed: () async {
              final results = await controller!.checkInGroup();
              if (mounted && results == null) {
                MaterialUtil.showAlert(context,
                    MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS));
                return;
              }
              if (mounted && results!.isNotEmpty) {
                MaterialUtil.showAlert(context, results);
              }
            }),
        //payment
        IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_PAYMENT),
            onPressed: () async {
              if (controller!.bookings.isEmpty) return;
              await showDialog<String>(
                context: context,
                builder: (_) =>
                    DepositDialog(booking: controller!.bookingParent),
              );
            }),
        //service
        IconButton(
            icon: const Icon(Icons.fact_check),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_SERVICE),
            onPressed: () async {
              if (controller!.bookings.isEmpty) return;
              await showDialog<String>(
                  builder: (ctx) =>
                      ServiceDialog(booking: controller!.bookingParent),
                  context: context);
            }),
        //discount
        IconButton(
            icon: const Icon(Icons.money_off),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_DISCOUNT),
            onPressed: () async {
              if (controller!.bookings.isEmpty) return;
              await showDialog(
                  context: context,
                  builder: (context) =>
                      DiscountDialog(booking: controller!.bookingParent));
            }),
        //cost
        if (UserManager.canSeeAccounting())
          IconButton(
              icon: const Icon(Icons.account_balance_wallet_rounded),
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_COST),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => CostBookingGroupDialog(
                        booking: controller!.bookingParent));
              }),
        //checkout
        IconButton(
            icon: const Icon(Icons.flight_takeoff),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CHECKOUT),
            onPressed: () async {
              final result = await controller!.checkOutGroup();
              if (!mounted) {
                return;
              }
              if (result == MessageCodeUtil.SUCCESS) {
                MaterialUtil.showSnackBar(context,
                    MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS));
              } else {
                MaterialUtil.showAlert(context, result);
              }
            }),
        //cancel
        IconButton(
            icon: const Icon(Icons.cancel),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CANCEL),
            onPressed: () async {
              if (controller!.bookingParent.status == BookingStatus.cancel ||
                  controller!.bookingParent.status == BookingStatus.noshow) {
                MaterialUtil.showAlert(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT,
                        [controller!.bookingParent.name!]));
                return;
              }
              final bool? confirmResult = await MaterialUtil.showConfirm(
                  context,
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.CONFIRM_CANCEL_BOOKING_GROUP_X,
                      [controller!.bookingParent.name!]));
              if (confirmResult == null || !confirmResult) {
                return;
              }
              await controller!.cancelGroup().then((result) {
                if (result == MessageCodeUtil.SUCCESS) {
                  MaterialUtil.showSnackBar(context,
                      MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS));
                } else {
                  MaterialUtil.showAlert(context, result);
                }
                if (mounted) {
                  return;
                }
              });
            }),
        // noshow
        IconButton(
            icon: const Icon(Icons.no_accounts_rounded),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_NO_SHOW),
            onPressed: () async {
              if (controller!.bookingParent.status == BookingStatus.cancel ||
                  controller!.bookingParent.status == BookingStatus.noshow) {
                MaterialUtil.showAlert(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT,
                        [controller!.bookingParent.name!]));
                return;
              }
              await controller!.noShowGroup().then((result) {
                if (result == MessageCodeUtil.SUCCESS) {
                  MaterialUtil.showSnackBar(context,
                      MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS));
                } else {
                  MaterialUtil.showAlert(context, result);
                }
                if (mounted) {
                  return;
                }
              });
            }),
        //log bookinggroup
        IconButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  LogBookingDialog(booking: widget.booking!, isGroup: true)),
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_LOG_BOOKING),
          icon: Icon(
            Icons.receipt_long_rounded,
            color: ColorManagement.iconMenuEnableColor,
            size: GeneralManager.iconMenuSize,
          ),
        ),
        //print
        IconButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_PRINT),
          onPressed: () async {
            _popupKey.currentState!.showButtonMenu();
          },
          icon: PopupMenuButton(
              tooltip: '',
              key: _popupKey,
              enabled: false,
              color: ColorManagement.mainBackground,
              onSelected: (String value) async {
                if (value == 'Print checkin') {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          NeutronShowConfigDialogExprortExcelAndDpf(
                            onPressedpDF: (showOption) async {
                              await PrintPDFToDevice.printPdfAccordingToDevice(
                                  context,
                                  PDFUtil.buildGroupCheckInPDFDoc(
                                      controller!.getGroup(),
                                      showOption["isShowPrice"]!),
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.POPUPMENU_PRINT_CHECKIN));
                            },
                            onPressedExcel: (showOption) {
                              ExcelUlti.exportCheckInFormGroup(
                                  controller!.getGroup(),
                                  showOption["isShowPrice"]!);
                              Navigator.pop(context);
                            },
                          ));
                } else if (value == 'Print booking') {
                  return showDialog(
                      context: context,
                      builder: (context) =>
                          NeutronShowConfigDialogExprortExcelAndDpf(
                            isNotesInBooking: true,
                            onPressedpDF: (showOption) async {
                              await PrintPDFToDevice.printPdfAccordingToDevice(
                                  context,
                                  PDFUtil.buildReservationFormGroupPDFDoc(
                                      controller!
                                          .getBookingsByRoomtypeAndArrivalAndDeparturFilter(),
                                      controller!.getGroup(),
                                      showOption["isShowPrice"]!,
                                      showOption["isShowNotes"]!,
                                      (await controller?.getNoteForBooking()),
                                      controller!.getTotalRoomCharge(),
                                      controller!.dataMeal,
                                      pngBytes: GeneralManager.policyHotel),
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.POPUPMENU_PRINT_BOOKING));
                            },
                            onPressedExcel: (showOption) async {
                              ExcelUlti.exportCheckInReservationFormGroup(
                                  controller!
                                      .getBookingsByRoomtypeAndArrivalAndDeparturFilter(),
                                  controller!.getGroup(),
                                  showOption["isShowPrice"]!,
                                  showOption["isShowNotes"]!,
                                  (await controller!.getNoteForBooking())
                                      as String,
                                  controller!.dataMeal);
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                          ));
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => NeutronShowConfigDialog(
                            listItem: widget.booking!.bookingType ==
                                    BookingType.monthly
                                ? controller!.listMonthByAllBookings().toList()
                                : null,
                            value: controller?.selectMonth,
                            onPressed2: (value) {
                              controller?.setMonth(value);
                            },
                            onPressed: (showOption) async {
                              if (showOption["isShowPrice"]! ||
                                  showOption["isShowService"]!) {
                                await PrintPDFToDevice
                                    .printPdfAccordingToDevice(
                                        context,
                                        PDFUtil.buildGroupCheckOutPDFDoc(
                                            await controller!
                                                .exportAllBookingDpfAndExcel(),
                                            controller!,
                                            showOption["isShowPrice"]!,
                                            showOption["isShowService"]!,
                                            showOption["isShowPayment"]!,
                                            showOption["isShowRemaining"]!),
                                        UITitleUtil.getTitleByCode(UITitleCode
                                            .POPUPMENU_PRINT_CHECKOUT));
                                controller!.setMonth(UITitleUtil.getTitleByCode(
                                    UITitleCode.ALL));
                              } else {
                                MaterialUtil.showAlert(
                                    context,
                                    MessageUtil.getMessageByCode(MessageCodeUtil
                                        .PLEASE_CHOOSE_CHECKBOX));
                              }
                            },
                            onPressed1: (showOption) async {
                              ExcelUlti.exportCheckInFormGroupCheckOut(
                                  await controller!
                                      .exportAllBookingDpfAndExcel(),
                                  controller!,
                                  showOption["isShowPrice"]!,
                                  showOption["isShowService"]!,
                                  showOption["isShowPayment"]!,
                                  showOption["isShowRemaining"]!);
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              controller!.setMonth(
                                  UITitleUtil.getTitleByCode(UITitleCode.ALL));
                            },
                            isGroup: true,
                          ));
                }
              },
              itemBuilder: (context) => ContextMenuUtil().printContextMenu(),
              child: const Icon(Icons.print)),
        ),
        //excel
        IconButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          onPressed: () async {
            ExcelUlti.exportBookingGroup(controller!);
          },
          icon: Icon(
            Icons.file_present_rounded,
            color: ColorManagement.iconMenuEnableColor,
            size: GeneralManager.iconMenuSize,
          ),
        ),
      ];
}
