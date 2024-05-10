import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/booking/booking_dialog/booking_dialog_detail.dart';
import 'package:ihotel/ui/component/booking/booking_dialog/booking_dialog_general.dart';
import 'package:ihotel/ui/component/booking/booking_dialog/booking_dialog_guest.dart';
import 'package:ihotel/ui/component/booking/pricedialog.dart';
import 'package:ihotel/ui/controls/neutronprintpdf.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/pdfutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/bookingcontroller.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../controls/neutronshowconfigdialog.dart';
import '../../controls/neutrontexttilte.dart';
import '../hotel/roomtypedialog.dart';

class BookingDialog extends StatefulWidget {
  final Booking? booking;
  final int? initialTab;
  final bool addBookingGroup;

  const BookingDialog(
      {Key? key, this.booking, this.initialTab, this.addBookingGroup = false})
      : super(key: key);
  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  BookingController? controllerBooking;
  late bool isShowButton, isReadonly;
  final formKey = GlobalKey<FormState>();
  final ScrollController generalScroll = ScrollController();
  final ScrollController detailScroll = ScrollController();
  final ScrollController guestScroll = ScrollController();

  @override
  void initState() {
    isShowButton = widget.booking!.status == BookingStatus.booked ||
        widget.booking!.status == BookingStatus.checkin;
    isReadonly = widget.booking!.status == BookingStatus.checkout ||
        widget.booking!.status == BookingStatus.cancel ||
        widget.booking!.status == BookingStatus.noshow;
    controllerBooking ??= BookingController(widget.booking!,
        addBookingGroup: widget.addBookingGroup);
    super.initState();
  }

  @override
  void dispose() {
    controllerBooking?.disposeTextEditing();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kWidth;
    const height = kHeight;

    if (controllerBooking!.isNotHaveRoomTypeAndRoom) {
      return buildAlertCreateRoom(width);
    }

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: width,
            height: height,
            child: Form(
              key: formKey,
              child: ChangeNotifierProvider.value(
                value: controllerBooking,
                child: Consumer<BookingController>(
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    ),
                    builder: (_, controller, child) {
                      if (controller.updating) {
                        return child!;
                      }

                      return DefaultTabController(
                        initialIndex: widget.initialTab ?? 0,
                        length: 3,
                        child: Scaffold(
                          resizeToAvoidBottomInset: false,
                          backgroundColor: ColorManagement.lightMainBackground,
                          appBar: PreferredSize(
                            preferredSize: const Size.fromHeight(80),
                            child: TabBar(
                                labelPadding: const EdgeInsets.all(15),
                                indicatorWeight: 5,
                                indicatorColor: BookingStatus
                                    .getBookingDialogIndicatorColor(
                                        controller.booking.status!),
                                tabs: [
                                  NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GENERAL)),
                                  NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_DETAIL)),
                                  NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST)),
                                ]),
                          ),
                          body: TabBarView(
                            children: [
                              BookingDialogGeneral(
                                controller: controller,
                                bottomButon: buildButton(),
                              ),
                              BookingDialogDetail(
                                controller: controller,
                                bottomButon: buildButton(),
                              ),
                              BookingDialogGuest(
                                controller: controller,
                                bottomButon: buildButton(),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            )));
  }

  Widget buildButton() {
    return NeutronButton(
        margin: const EdgeInsets.only(bottom: SizeManagement.rowSpacing),
        tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SAVE),
        tooltip1: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_PRINT_CHECKIN),
        tooltip2:
            UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_PRINT_RESERVATION),
        icon: widget.booking!.isEmpty!
            ? Icons.add
            : controllerBooking!.isShowBottomButton
                ? Icons.save
                : null,
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            final result = await controllerBooking!.updateBooking();
            if (!mounted) {
              return;
            }
            if (result ==
                MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) {
              Navigator.pop(
                  context,
                  controllerBooking!.isAddBooking
                      ? MessageUtil.getMessageByCode(
                          MessageCodeUtil.ADD_BOOKING_AT_ROOM_SUCCESS, [
                          controllerBooking!.teName!.text,
                          RoomManager().getNameRoomById(controllerBooking!.room)
                        ])
                      : MessageUtil.getMessageByCode(
                          MessageCodeUtil.BOOKING_AT_ROOM_UPDATE_SUCCESS, [
                          controllerBooking!.teName!.text,
                          RoomManager().getNameRoomById(controllerBooking!.room)
                        ]));
            } else {
              MaterialUtil.showAlert(context, result);
            }
          }
        },
        icon1: !controllerBooking!.isAddBooking ? Icons.print : null,
        onPressed1: () async {
          return showDialog(
              context: context,
              builder: (context) => NeutronShowConfigDialogExprortExcelAndDpf(
                    onPressedpDF: (showOption) async {
                      await PrintPDFToDevice.printPdfAccordingToDevice(
                          context,
                          PDFUtil.buildCheckInPDFDoc(controllerBooking!.booking,
                              showOption["isShowPrice"]!,
                              pngBytes: GeneralManager.policyHotel),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_PRINT_CHECKIN));
                    },
                    onPressedExcel: (showOption) {
                      ExcelUlti.exportCheckInForm(controllerBooking!.booking,
                          showOption["isShowPrice"]!);
                      Navigator.pop(context);
                    },
                  ));
        },
        icon2: !controllerBooking!.isAddBooking
            ? Icons.playlist_add_check_circle
            : null,
        onPressed2: () async {
          showDialog(
              context: context,
              builder: (context) => NeutronShowConfigDialogExprortExcelAndDpf(
                    isNotesInBooking: true,
                    iconExcel: null,
                    onPressedpDF: (showOption) async {
                      await PrintPDFToDevice.printPdfAccordingToDevice(
                          context,
                          PDFUtil.buildReservationFormPDFDoc(
                              controllerBooking!.booking,
                              showOption["isShowPrice"]!,
                              showOption["isShowNotes"]!,
                              pngBytes: GeneralManager.policyHotel),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_PRINT_RESERVATION));
                    },
                  ));
        });
  }

  Widget buildAlertCreateRoom(double width) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
          width: width,
          height: kHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          alignment: Alignment.center,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                children: [
                  TextSpan(
                      text: MessageUtil.getMessageByCode(
                          MessageCodeUtil.TEXTALERT_PLEASE)),
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Navigator.pop(context);
                          await showDialog(
                              context: context,
                              builder: (context) => RoomTypeDialog());
                        },
                      text: MessageUtil.getMessageByCode(MessageCodeUtil
                              .TEXTALERT_TO_CREATE_ROOMTYPE_AND_ROOM)
                          .toLowerCase(),
                      style: const TextStyle(
                        color: ColorManagement.redColor,
                        fontSize: 20,
                      )),
                  TextSpan(
                      text: MessageUtil.getMessageByCode(MessageCodeUtil
                          .TEXTALERT_BEFORE_CREATING_NEW_BOOKING))
                ]),
          )),
    );
  }

  void showPriceDialog(BookingController controller) async {
    final result = await showDialog(
        context: context,
        builder: (context) => PriceDialog(
              staysday: controller.staysDay,
              priceBooking: controller.priceAfterMultipleRatePlan,
            ));
    if (result != null) {
      controller.setPrice(result);
    }
  }
}
