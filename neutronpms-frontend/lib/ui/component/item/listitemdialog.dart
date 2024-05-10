import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../manager/itemmanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrondropdown.dart';
import '../../controls/neutrontextcontent.dart';
import 'itemdialog.dart';
import 'itemwidget.dart';

class ListItemDialog extends StatefulWidget {
  const ListItemDialog({Key? key}) : super(key: key);

  @override
  State<ListItemDialog> createState() => _ListItemState();
}

class _ListItemState extends State<ListItemDialog> {
  late TextEditingController teSearch;
  final ItemManager itemManager = ItemManager();

  @override
  void initState() {
    itemManager.statusServiceFilter =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
    teSearch = TextEditingController(text: itemManager.queryString);
    super.initState();
  }

  @override
  void dispose() {
    itemManager.setQueryString('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNotDesktop = ResponsiveUtil.isMobile(context);
    final double width = isNotDesktop ? kMobileWidth : kLargeWidth;
    const height = kHeight;

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          width: width,
          height: height,
          child: ChangeNotifierProvider<ItemManager>.value(
            value: itemManager,
            child: Consumer<ItemManager>(
                child: const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor)),
                builder: (_, controller, child) {
                  return Scaffold(
                      backgroundColor: ColorManagement.mainBackground,
                      appBar: AppBar(
                        title: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.SIDEBAR_ITEM)),
                        actions: [
                          Container(
                            padding: const EdgeInsets.only(
                                right: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            width: 90,
                            child: NeutronDropDown(
                              // isDecor: false,
                              value: controller.statusServiceFilter,
                              onChanged: (String newValue) {
                                controller.setStatusFilter(newValue);
                              },
                              items: [
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ACTIVE),
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_DEACTIVE),
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ALL),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: NeutronButton(
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_DOWNLOAD_TEMPLATE_FILE),
                              margin: const EdgeInsets.all(8),
                              icon: Icons.file_download,
                              onPressed: ExcelUlti.dowloaExportItemFile,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: NeutronButton(
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_UPLOAD_EXCEL_FILE),
                              margin: const EdgeInsets.all(8),
                              icon: Icons.import_export_outlined,
                              onPressed: () async {
                                await ExcelUlti.readItemFromExcelFile()
                                    .then((value) async {
                                  if (value[2].toString().isNotEmpty) {
                                    MaterialUtil.showResult(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.NAME_ITEM_ISEMPTY,
                                            [value[2].toString()]));
                                    return;
                                  }
                                  if (value[1].toString().isNotEmpty) {
                                    MaterialUtil.showResult(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.UNIT_ERRO_AT_LINE,
                                            [value[1].toString()]));
                                    return;
                                  }
                                  if (value.isEmpty) {
                                    MaterialUtil.showResult(
                                        context, MessageCodeUtil.NO_DATA);
                                    return;
                                  }
                                  showDialog(
                                      context: context,
                                      builder: (context) => ListItemImpotrt(
                                            data: value[0],
                                            itemManager: itemManager,
                                          ));
                                }).onError((error, stackTrace) =>
                                        MaterialUtil.showResult(
                                            context, error.toString()));
                              },
                            ),
                          ),
                        ],
                      ),
                      body: controller.isLoading
                          ? child
                          : Stack(children: [
                              Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: ColorManagement.mainBackground,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  margin: const EdgeInsets.only(bottom: 60),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                          height: SizeManagement.rowSpacing),
                                      buildSearchInput(),
                                      const SizedBox(
                                          height: SizeManagement.rowSpacing),
                                      Expanded(child: buildItems(isNotDesktop)),
                                    ],
                                  )),
                              //add-button
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: NeutronButton(
                                  icon1: Icons.add,
                                  onPressed1: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const ItemDialog());
                                  },
                                ),
                              )
                            ]));
                }),
          ),
        ));
  }

  Widget buildItems(bool isNotDesktop) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isNotDesktop ? 1 : 4,
          childAspectRatio: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: itemManager.filter().length,
        itemBuilder: (context, index) => ItemWidget(
            item: itemManager.filter().toList()[index],
            parentContext: context));
  }

  Widget buildSearchInput() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
          width: kMobileWidth,
          height: SizeManagement.cardHeight,
          child: TextField(
            style: const TextStyle(
              color: ColorManagement.lightColorText,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            controller: teSearch,
            onChanged: (String value) {
              itemManager.setQueryString(value);
            },
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                color: ColorManagement.lightColorText,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 156, 156, 156), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 116, 116, 116), width: 1),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: ColorManagement.lightColorText,
              ),
              hintText: UITitleUtil.getTitleByCode(
                  UITitleCode.HINT_INPUT_NAME_TO_SEARCH),
              fillColor: const Color.fromARGB(255, 73, 75, 83),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.dropdownLeftPadding, vertical: 8),
            ),
            cursorColor: ColorManagement.greenColor,
            cursorHeight: 20,
          )),
    );
  }
}

class ListItemImpotrt extends StatelessWidget {
  const ListItemImpotrt(
      {super.key, required this.data, required this.itemManager});
  final Map<String, dynamic> data;
  final ItemManager itemManager;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: ChangeNotifierProvider<ItemManager>.value(
        value: itemManager,
        child: Consumer<ItemManager>(
          builder: (context, controller, child) => SizedBox(
              width: kMobileWidth,
              height: kHeight,
              child: controller.isLoadingImprot
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : Column(
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: NeutronTextTitle(
                                          textAlign: TextAlign.center,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_ITEM)),
                                    ),
                                    Expanded(
                                      child: NeutronTextTitle(
                                          textAlign: TextAlign.center,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_UNIT)),
                                    ),
                                    Expanded(
                                      child: NeutronTextTitle(
                                          textAlign: TextAlign.center,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_AMOUNT)),
                                    ),
                                    const SizedBox(width: 40)
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...data.keys
                                  .map((key) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.center,
                                                  tooltip: data[key]["name"],
                                                  message: data[key]["name"]),
                                            ),
                                            Expanded(
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.center,
                                                  message: MessageUtil
                                                      .getMessageByCode(
                                                          data[key]["unit"])),
                                            ),
                                            Expanded(
                                              child: NeutronTextContent(
                                                  textAlign: TextAlign.center,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(data[key]
                                                          ["cost_price"])),
                                            ),
                                            SizedBox(
                                              width: 40,
                                              child: controller.items
                                                      .where((element) =>
                                                          element.id == key ||
                                                          element.name ==
                                                              data[key]["name"])
                                                      .isNotEmpty
                                                  ? IconButton(
                                                      onPressed: () {
                                                        controller
                                                            .removeItemDuplicated(
                                                                key, data);
                                                      },
                                                      icon: const Icon(
                                                          Icons.remove))
                                                  : null,
                                            )
                                          ],
                                        ),
                                      ))
                                  .toList()
                            ],
                          ),
                        )),
                        NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            await controller
                                .createsMultipleItem(data)
                                .then((result) {
                              if (result != MessageCodeUtil.SUCCESS) {
                                MaterialUtil.showResult(context,
                                    MessageUtil.getMessageByCode(result));
                                return;
                              }
                              MaterialUtil.showSnackBar(context,
                                  MessageUtil.getMessageByCode(result));
                              Navigator.pop(context);
                            });
                          },
                        )
                      ],
                    )),
        ),
      ),
    );
  }
}
