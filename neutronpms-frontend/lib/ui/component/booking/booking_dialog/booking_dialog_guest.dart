import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/booking/bookingcontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/staydeclaration/staydeclaration.dart';
import 'package:ihotel/ui/component/staydeclaration/guestdeclarationdialog.dart';
import 'package:ihotel/ui/component/staydeclaration/scanqrcodedialog.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class BookingDialogGuest extends StatelessWidget {
  const BookingDialogGuest({
    Key? key,
    required this.controller,
    required this.bottomButon,
  }) : super(key: key);

  final BookingController controller;
  final Widget bottomButon;

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveUtil.isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: isMobile
                ? buildContentGuestInMobile(context)
                : buildContentGuestInPc(context),
          )),
          const SizedBox(height: 8),
          bottomButon
        ],
      ),
    );
  }

  Widget buildContentGuestInPc(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SizeManagement.rowSpacing),
        // Title
        Row(
          children: [
            Expanded(
              child: NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_TRAVEL)),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            Expanded(
              child: NeutronTextTitle(
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COUNTRY),
              ),
            )
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        // From field for internation and domestic
        Row(
          children: [
            // international and domestic
            Expanded(
              child: NeutronDropDownCustom(
                childWidget: NeutronDropDown(
                  isDisabled: controller.isReadonly,
                  isPadding: false,
                  value: controller.getTypeTouristsNameByID(),
                  onChanged: controller.setTypeTourists,
                  items: controller.listTypeTourists,
                ),
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            // auto-complete country
            Expanded(
              child: Autocomplete<String>(
                key: Key(controller.teCountry),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return controller.getTypeTouristsNameByID() ==
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_FOREIGN)
                      ? controller.listCountry
                          .where((element) =>
                              element != GeneralManager.hotel!.country!)
                          .where((String option) => option
                              .toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase()))
                      : const Iterable<String>.empty();
                },
                onSelected: (String selection) {
                  if (kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.android)) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  }
                  controller.setCountry(selection);
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                        onEditingComplete) =>
                    NeutronTextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  isDecor: true,
                  readOnly: controller.getTypeTouristsNameByID() !=
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_FOREIGN),
                ),
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: ColorManagement.mainBackground,
                      elevation: 5,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: kMobileWidth -
                                SizeManagement.cardOutsideHorizontalPadding *
                                    2),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) => ListTile(
                            onTap: () => onSelected(options.elementAt(index)),
                            title: Text(
                              options.elementAt(index),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            minVerticalPadding: 0,
                            hoverColor: Colors.white38,
                          ),
                          itemCount: options.length,
                        ),
                      ),
                    ),
                  );
                },
                initialValue: TextEditingValue(text: controller.teCountry),
              ),
            ),
          ],
        ),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
        //Invoice detail title
        Row(
          children: [
            NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_INVOICE_DETAIL),
            ),
            const Spacer(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170, minWidth: 170),
              child: CheckboxListTile(
                title: NeutronTextContent(
                    message:
                        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ISSUE_INVOICE)}: '),
                selected: controller.isDeclareForTax,
                value: controller.isDeclareForTax,
                onChanged: (bool? checked) {
                  if (controller.isReadonly) {
                    return;
                  }
                  controller.setTaxDeclare(checked!);
                },
                activeColor: ColorManagement.greenColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
        //guest/company + tax code + email on PC
        Row(
          children: [
            //guest name
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['guest'],
                isDecor: true,
                label: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_COMPANY),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //tax code
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['tax_code'],
                isDecor: true,
                label: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_CCCD_TAX_CODE),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //email
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['email'],
                isDecor: true,
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        //address + phone + tax price on PC
        Row(
          children: [
            //address
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['address'],
                isDecor: true,
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ADDRESS),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //phone
            SizedBox(
              width: 100,
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['phone'],
                isDecor: true,
                isPhoneNumber: true,
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE),
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //price
            SizedBox(
                width: 80,
                child: (controller.declarationInvoiceDetail['price']
                        as NeutronInputNumberController)
                    .buildWidget(
                  readOnly: controller.isReadonly,
                  isDouble: true,
                  isDecor: true,
                  label: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_TAX_PRICE),
                  onChanged: (String value) {
                    controller.onChangeOfDeclareInfoFields(value);
                  },
                )),
          ],
        ),
        //Guest title
        const SizedBox(height: SizeManagement.rowSpacing),

        Row(
          children: [
            NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => handleScanQR(context),
              icon: const Icon(Icons.qr_code_2_rounded),
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SCAN_QR_CODE),
            ),
            IconButton(
              onPressed: () => handleAddGuestDeclaration(context),
              icon: const Icon(Icons.add),
              tooltip: UITitleUtil.getTitleByCode(
                  UITitleCode.TOOLTIP_ADD_GUEST_DECLARATION),
            )
          ],
        ),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),

        if (controller.declarationGuest.isNotEmpty)
          ...buildListGuestDetail(context),
      ],
    );
  }

  Widget buildContentGuestInMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SizeManagement.rowSpacing),
        // Type tourists
        NeutronTextTitle(
          isPadding: false,
          message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TRAVEL),
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        NeutronDropDownCustom(
          childWidget: NeutronDropDown(
            isDisabled: controller.isReadonly,
            isPadding: false,
            value: controller.getTypeTouristsNameByID(),
            onChanged: controller.setTypeTourists,
            items: controller.listTypeTourists,
          ),
        ),
        // country
        const SizedBox(
            height: SizeManagement.bottomFormFieldSpacing +
                SizeManagement.rowSpacing),
        // title Country
        NeutronTextTitle(
          isPadding: false,
          message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COUNTRY),
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        Autocomplete<String>(
            key: Key(controller.teCountry),
            optionsBuilder: (textEditingValue) {
              // textEditingValue.text = controller.teCountry.text;
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return controller.listCountry.where(
                  (element) => element.startsWith(textEditingValue.text));
            },
            onSelected: (String selection) {
              controller.setCountry(selection);
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              if (controller.teCountry.isNotEmpty) {
                textEditingController.text = controller.teCountry;
              } else {
                textEditingController.text = '';
              }
              return NeutronTextFormField(
                isDecor: true,
                controller: textEditingController,
                focusNode: focusNode,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: ColorManagement.mainBackground,
                  elevation: 5,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxHeight: 200,
                        maxWidth: kMobileWidth -
                            SizeManagement.cardOutsideHorizontalPadding * 2),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) => ListTile(
                        onTap: () => onSelected(options.elementAt(index)),
                        title: Text(
                          options.elementAt(index),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        minVerticalPadding: 0,
                        hoverColor: Colors.white38,
                      ),
                      itemCount: options.length,
                    ),
                  ),
                ),
              );
            },
            initialValue: TextEditingValue(text: controller.teCountry)),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
        //Invoice detail title
        Row(
          children: [
            NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_INVOICE_DETAIL),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140, minWidth: 130),
              child: CheckboxListTile(
                title: NeutronTextContent(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ISSUE_INVOICE),
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ISSUE_INVOICE)}: ',
                  maxLines: 2,
                ),
                selected: controller.isDeclareForTax,
                value: controller.isDeclareForTax,
                onChanged: (bool? checked) {
                  if (controller.isReadonly) {
                    return;
                  }
                  controller.setTaxDeclare(checked!);
                },
                activeColor: ColorManagement.greenColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
        //guest/company + tax code + email on PC
        Row(
          children: [
            //guest name
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['guest'],
                isDecor: true,
                label: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_COMPANY),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //tax code
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['tax_code'],
                isDecor: true,
                label: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_CCCD_TAX_CODE),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
          ],
        ),
        //email on Mobile
        const SizedBox(height: SizeManagement.rowSpacing),
        Row(
          children: [
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['email'],
                isDecor: true,
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //phone
            SizedBox(
              width: 100,
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['phone'],
                isDecor: true,
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE),
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        //address in Mobile
        Row(
          children: [
            Expanded(
              child: NeutronTextFormField(
                readOnly: controller.isReadonly,
                controller: controller.declarationInvoiceDetail['address'],
                isDecor: true,
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ADDRESS),
                labelRequired: true,
                onChanged: (String value) {
                  controller.onChangeOfDeclareInfoFields(value);
                },
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //price
            SizedBox(
                width: 80,
                child: (controller.declarationInvoiceDetail['price']
                        as NeutronInputNumberController)
                    .buildWidget(
                  readOnly: controller.isReadonly,
                  isDouble: true,
                  isDecor: true,
                  label: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_TAX_PRICE),
                  onChanged: (String value) {
                    controller.onChangeOfDeclareInfoFields(value);
                  },
                )),
          ],
        ),
        //Guest title
        const SizedBox(height: SizeManagement.rowSpacing),
        Row(
          children: [
            NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => handleScanQR(context),
              icon: const Icon(Icons.qr_code_2_rounded),
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SCAN_QR_CODE),
            ),
            IconButton(
              onPressed: () => handleAddGuestDeclaration(context),
              icon: const Icon(Icons.add),
              tooltip: UITitleUtil.getTitleByCode(
                  UITitleCode.TOOLTIP_ADD_GUEST_DECLARATION),
            )
          ],
        ),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),

        if (controller.declarationGuest.isNotEmpty)
          ...buildListGuestDetail(context),
      ],
    );
  }

  void handleScanQR(BuildContext context) async {
    if (controller.isReadonly) {
      return;
    }
    await showDialog(
      context: context,
      builder: (context) => ScanQRCode(),
    ).then((value) {
      if (value == null) {
        return;
      }
      bool result = controller.addGuestDeclarationFromQRCode(value);
      if (!result) {
        MaterialUtil.showAlert(context,
            MessageUtil.getMessageByCode(MessageCodeUtil.PLEASE_RESCAN));
      }
    });
  }

  void handleAddGuestDeclaration(BuildContext context) async {
    if (controller.isReadonly) {
      return;
    }
    final StayDeclaration? result = await showDialog(
        context: context, builder: (context) => GuestDeclarationDialog());
    if (result == null) {
      return;
    }
    controller.addGuestDeclaration(result);
  }

  List<Widget> buildListGuestDetail(BuildContext context) {
    bool isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kWidth;
    final double widthOfDatatableTitle = isMobile ? 120 : 250;
    final double widthOfDatatableContent = width -
        widthOfDatatableTitle -
        //horizontalMagin of datatable
        SizeManagement.cardInsideHorizontalPadding * 2 -
        6; //columnSpacing of Datatable
    return controller.declarationGuest.map((e) {
      return ExpansionTile(
          trailing: IconButton(
            constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
            padding: const EdgeInsets.all(0),
            onPressed: () async {
              if (controller.isReadonly) {
                return;
              }
              StayDeclaration? guestAfterEdit = await showDialog(
                  context: context,
                  builder: (context) => GuestDeclarationDialog(guest: e));
              if (guestAfterEdit == null) {
                return;
              }
              controller.updateGuestDeclaration(e, guestAfterEdit);
            },
            icon: const Icon(Icons.edit, color: ColorManagement.lightColorText),
          ),
          backgroundColor: ColorManagement.mainBackground,
          childrenPadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          leading: IconButton(
            onPressed: () {
              if (controller.isReadonly) {
                return;
              }
              controller.removeGuestDeclaration(e);
            },
            icon:
                const Icon(Icons.remove, color: ColorManagement.lightColorText),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
          ),
          title: isMobile
              ? Row(
                  children: [
                    Expanded(child: NeutronTextContent(message: e.name!)),
                  ],
                )
              : Row(
                  children: [
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    Expanded(child: NeutronTextContent(message: e.name!)),
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    NeutronTextContent(message: e.nationality!),
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                  ],
                ),
          children: [
            DataTable(
              columnSpacing: 6,
              headingRowHeight: 0,
              horizontalMargin: SizeManagement.cardInsideHorizontalPadding,
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              rows: [
                //date of birth
                DataRow(cells: [
                  DataCell(NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DATE_OF_BIRTH))),
                  DataCell(NeutronTextContent(
                      message: DateUtil.dateToString(e.dateOfBirth!))),
                ]),
                //gender
                DataRow(cells: [
                  DataCell(NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_GENDER))),
                  DataCell(NeutronTextContent(message: e.gender!)),
                ]),
                //stay type
                DataRow(cells: [
                  DataCell(NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_STAY_TYPE))),
                  DataCell(NeutronTextContent(message: e.stayType!))
                ]),
                //reason
                DataRow(cells: [
                  DataCell(NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_REASON))),
                  DataCell(NeutronTextContent(message: e.reason ?? '#N/A'))
                ]),
                //cmnd
                DataRow(cells: [
                  DataCell(SizedBox(
                    width: widthOfDatatableTitle,
                    child: NeutronTextContent(
                        textOverflow: TextOverflow.clip,
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CMND_CCCD)),
                  )),
                  DataCell(SizedBox(
                      width: widthOfDatatableContent,
                      child: NeutronTextContent(
                          // tooltip: isMobile ? e.nationalId : null,
                          message: e.nationalId!))),
                ]),
                //passport
                DataRow(cells: [
                  DataCell(NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_PASSPORT))),
                  DataCell(SizedBox(
                      width: widthOfDatatableContent,
                      child: NeutronTextContent(
                          // tooltip: isMobile ? e.passport : null,
                          message: e.passport!))),
                ]),
                //other document id
                DataRow(cells: [
                  DataCell(NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_OTHER_DOCUMENT))),
                  DataCell(SizedBox(
                      width: widthOfDatatableContent,
                      child: NeutronTextContent(
                          // tooltip: isMobile ? e.otherDocId : null,
                          message: e.otherDocId!))),
                ]),
                //national address
                DataRow(cells: [
                  DataCell(SizedBox(
                    width: widthOfDatatableTitle,
                    child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ADDRESS)),
                  )),
                  DataCell(SizedBox(
                    width: widthOfDatatableContent,
                    child: NeutronTextContent(message: e.nationalAddress!),
                  )),
                ]),
                //city address
                DataRow(cells: [
                  DataCell(SizedBox(
                    width: widthOfDatatableTitle,
                    child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CITY_ADDRESS)),
                  )),
                  DataCell(SizedBox(
                    width: widthOfDatatableContent,
                    child: NeutronTextContent(message: e.cityAddress!),
                  )),
                ]),
                //district address
                DataRow(cells: [
                  DataCell(SizedBox(
                    width: widthOfDatatableTitle,
                    child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_DISTRICT_ADDRESS)),
                  )),
                  DataCell(SizedBox(
                    width: widthOfDatatableContent,
                    child: NeutronTextContent(message: e.districtAddress!),
                  )),
                ]),
                //commune address
                DataRow(cells: [
                  DataCell(SizedBox(
                    width: widthOfDatatableTitle,
                    child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_COMMUNE_ADDRESS)),
                  )),
                  DataCell(SizedBox(
                    width: widthOfDatatableContent,
                    child: NeutronTextContent(message: e.communeAddress!),
                  )),
                ]),
                //detail address
                DataRow(cells: [
                  DataCell(SizedBox(
                    width: widthOfDatatableTitle,
                    child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_DETAIL_ADDRESS)),
                  )),
                  DataCell(SizedBox(
                    width: widthOfDatatableContent,
                    child: NeutronTextContent(message: e.detailAddress!),
                  )),
                ]),
              ],
            )
          ]);
    }).toList();
  }
}
