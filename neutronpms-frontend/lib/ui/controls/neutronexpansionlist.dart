// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/extraguestcontroller.dart';
import 'package:ihotel/controller/booking/service/insiderestaurantcontroller.dart';
import 'package:ihotel/controller/booking/service/laundrycontroller.dart';
import 'package:ihotel/controller/booking/service/minibarcontroller.dart';
import 'package:ihotel/controller/booking/service/othercontroller.dart';
import 'package:ihotel/controller/booking/service/restaurantservicecontroller.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../modal/booking.dart';
import '../../modal/service/bikerental.dart';
import '../../modal/service/extraguest.dart';
import '../../modal/service/laundry.dart';
import '../../modal/service/minibar.dart';
import '../../modal/service/other.dart';
import '../../modal/service/service.dart';
import '../../ui/component/service/bikerentalinvoiceform.dart';
import '../../util/dateutil.dart';
import '../../util/numberutil.dart';
import '../component/service/extraguestform.dart';
import '../component/service/laundryform.dart';
import '../component/service/minibarform.dart';
import '../component/service/othersform.dart';

// ignore: must_be_immutable
class NeutronExpansionPanelList extends StatefulWidget {
  final Booking booking;
  final List<Service> services;

  const NeutronExpansionPanelList(
      {Key? key, required this.services, required this.booking})
      : super(key: key);

  @override
  State<NeutronExpansionPanelList> createState() =>
      _NeutronExpansionPanelListState();
}

class _NeutronExpansionPanelListState extends State<NeutronExpansionPanelList> {
  late List<bool> isExpandedList;
  late List<GlobalObjectKey<FormState>> formKeys;
  late List<UpdateServiceController?> controllers;

  @override
  void initState() {
    isExpandedList = widget.services.map((e) => false).toList();
    formKeys =
        widget.services.map((e) => GlobalObjectKey<FormState>(e.id!)).toList();
    controllers = widget.services.map((service) {
      if (service is Minibar) {
        return UpdateMinibarController(
            booking: widget.booking, service: service);
      } else if (service is Laundry) {
        return UpdateLaundryController(
            booking: widget.booking, service: service);
      } else if (service is ExtraGuest) {
        return UpdateExtraGuestController(
            booking: widget.booking, service: service);
      } else if (service is Other) {
        return UpdateOtherController(booking: widget.booking, service: service);
      } else if (service is BikeRental) {
        return BikeRentalInvoiceController(widget.booking, service);
      } else if (service is OutsideRestaurantService) {
        return DeleteRestaurantServiceController();
      } else if (service is InsideRestaurantService) {
        return UpdateInsideRestaurantController(
            booking: widget.booking, service: service);
      }
      return null;
    }).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (formKeys.length < widget.services.length) {
      isExpandedList = widget.services.map((e) => false).toList();
      formKeys = widget.services
          .map((e) => GlobalObjectKey<FormState>(e.id!))
          .toList();
      controllers = widget.services.map((service) {
        if (service is Minibar) {
          return UpdateMinibarController(
              booking: widget.booking, service: service);
        } else if (service is Laundry) {
          return UpdateLaundryController(
              booking: widget.booking, service: service);
        } else if (service is ExtraGuest) {
          return UpdateExtraGuestController(
              booking: widget.booking, service: service);
        } else if (service is Other) {
          return UpdateOtherController(
              booking: widget.booking, service: service);
        } else if (service is BikeRental) {
          return BikeRentalInvoiceController(widget.booking, service);
        } else if (service is InsideRestaurantService) {
          return UpdateInsideRestaurantController(
              booking: widget.booking, service: service);
        }
        return null;
      }).toList();
    }

    return Column(children: [
      for (int i = 0; i < widget.services.length; i++) _buildExpansionTile(i)
    ]);
  }

  Container _buildExpansionTile(int index) {
    UpdateServiceController updateServiceController = controllers[index]!;
    Service service = widget.services[index];
    String numberBill = service.id!
        .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
    final editForm = formKeys[index];
    updateServiceController.updating = false;
    final bool isMobile = ResponsiveUtil.isMobile(context);
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding,
          vertical: SizeManagement.cardOutsideVerticalPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
        color: ColorManagement.lightMainBackground,
      ),
      child: ChangeNotifierProvider<UpdateServiceController>.value(
        value: updateServiceController,
        child: Consumer<UpdateServiceController>(
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 50),
            child: const CircularProgressIndicator(
              color: ColorManagement.greenColor,
            ),
          ),
          builder: (_, updateServiceController, childLoading) =>
              (updateServiceController.updating ?? false)
                  ? childLoading!
                  : ExpansionTile(
                      //called when expand and collapse ExpansionTile
                      //return true when expanded, false when collapsed
                      onExpansionChanged: (bool expanded) {
                        isExpandedList[index] = expanded;
                        updateServiceController.setProgressDone();
                      },
                      initiallyExpanded: isExpandedList[index],
                      collapsedTextColor: ColorManagement.greenColor,
                      textColor: ColorManagement.greenColor,
                      iconColor: ColorManagement.white,
                      collapsedIconColor: ColorManagement.white,
                      title: Row(
                        children: [
                          //Create-time-column
                          Expanded(
                              child: NeutronTextContent(
                            maxLines: 2,
                            message: DateUtil.dateToDayMonthHourMinuteString(
                                service.created!.toDate()),
                          )),
                          //MHĐ
                          if (!isMobile)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: Row(
                                  children: [
                                    NeutronTextContent(
                                        message:
                                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMNER_BILL)}: "),
                                    NeutronTextContent(message: numberBill),
                                  ],
                                ),
                              ),
                            ),
                          //Total-money-column
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: NeutronTextContent(
                                message: ResponsiveUtil.isMobile(context)
                                    ? NumberUtil.moneyFormat
                                        .format(service.total)
                                    : NumberUtil.numberFormat
                                        .format(service.total),
                                color: ColorManagement.positiveText,
                              ),
                            ),
                          ),
                          //edit button
                          buildEditButton(
                              service, updateServiceController, index),
                          //Delete-button
                          buildDeleteButton(
                              service, updateServiceController, index),
                        ],
                      ),
                      children: [
                          if (isMobile)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                NeutronTextContent(
                                    message:
                                        "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMNER_BILL)}: "),
                                NeutronTextContent(message: numberBill),
                              ],
                            ),
                          getForm(service, updateServiceController, editForm,
                              context)
                        ]),
        ),
      ),
    );
  }

  Widget buildEditButton(Service service,
      UpdateServiceController updateServiceController, int index) {
    if (!widget.booking.isServiceUpdatable(service) ||
        !isExpandedList[index] ||
        service is BikeRental ||
        service is OutsideRestaurantService) {
      return const SizedBox();
    }
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 8),
      width: 26,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        icon: const Icon(Icons.check),
        alignment: Alignment.center,
        onPressed: () async {
          if (formKeys[index].currentState!.validate()) {
            updateServiceController.updateService();
            updateServiceController
                .updateServiceToDatabase()!
                .then((result) => {MaterialUtil.showResult(context, result)});
          }
        },
        color: ColorManagement.greenColor,
        tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SAVE),
      ),
    );
  }

  Widget buildDeleteButton(Service service,
      UpdateServiceController updateServiceController, int index) {
    if (!widget.booking.isServiceUpdatable(service) || !isExpandedList[index]) {
      return const SizedBox();
    }
    return Container(
      alignment: Alignment.center,
      width: 26,
      child: IconButton(
        tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
        alignment: Alignment.center,
        icon: const Icon(Icons.delete),
        onPressed: () async {
          String total = NumberUtil.numberFormat.format(service.total);
          bool? isConfirmed = await MaterialUtil.showConfirm(
              context,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.CONFIRM_DELETE_INVOICE_WITH_AMOUNT, [total]));
          if (isConfirmed!) {
            updateServiceController.setProgressUpdating();
            final result = await widget.booking
                .deleteService(service)
                .then((value) => value)
                .onError((error, stackTrace) => error.toString());
            if (result == MessageCodeUtil.SUCCESS) {
              setState(() {
                widget.services.removeAt(index);
                controllers.removeAt(index);
                formKeys.removeAt(index);
                isExpandedList.removeAt(index);
                MaterialUtil.showSnackBar(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.INVOICE_DELETE_SUCCESS, [total]));
              });
            } else {
              updateServiceController.setProgressDone();
              MaterialUtil.showAlert(
                  context, MessageUtil.getMessageByCode(result));
            }
          }
        },
      ),
    );
  }

  Widget getForm(Service service, dynamic serviceController, GlobalKey editForm,
      BuildContext parentContext) {
    if (service is Minibar) {
      return MininbarInvoiceForm(
        service: service,
        booking: widget.booking,
        minibarController: serviceController,
        minibarEditForm: editForm,
      );
    } else if (service is Laundry) {
      return LaundryInvoiceForm(
        service: service,
        booking: widget.booking,
        laundryController: serviceController,
        laundryEditForm: editForm,
      );
    } else if (service is BikeRental) {
      return BikeRentalInvoiceForm(
          parentContext: parentContext,
          service: service,
          booking: widget.booking,
          controller: serviceController);
    } else if (service is ExtraGuest) {
      return ExtraGuestInvoiceForm(
        service: service,
        booking: widget.booking,
        extraGuestController: serviceController,
        extraGuestEditForm: editForm,
      );
    } else if (service is Other) {
      return OtherInvoiceForm(
        service: service,
        booking: widget.booking,
        otherController: serviceController,
        otherEditForm: editForm,
      );
    } else if (service is OutsideRestaurantService) {
      return RestaurantInvoiceForm(service: service, booking: widget.booking);
    } else if (service is InsideRestaurantService) {
      return InsideRestaurantInvoiceForm(
        service: service,
        booking: widget.booking,
        controller: serviceController,
        editForm: editForm,
      );
    } else {
      return const Text("");
    }
  }
}
