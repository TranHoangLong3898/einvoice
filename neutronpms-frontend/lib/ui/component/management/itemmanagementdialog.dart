import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/management/itemmanagementcontroller.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../ui/controls/neutroniconbutton.dart';
import '../../../ui/controls/neutrontextformfield.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class ItemManagementDialog extends StatefulWidget {
  const ItemManagementDialog({Key? key}) : super(key: key);

  @override
  State<ItemManagementDialog> createState() => _ItemManagementDialogState();
}

class _ItemManagementDialogState extends State<ItemManagementDialog> {
  ItemManagementController? controller;
  @override
  void initState() {
    controller ??= ItemManagementController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.disposeAllTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: Scaffold(
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
                title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_ITEM_MANAGEMENT),
                    style: Theme.of(context).textTheme.bodyLarge)),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChangeNotifierProvider.value(
                value: controller,
                child: Consumer<ItemManagementController>(
                  builder: (_, controller, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.transparentBackground,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: NeutronDropDown(
                                        items: controller.types,
                                        value: controller.type,
                                        onChanged: (value) {
                                          controller.setType(value);
                                        })),
                                NeutronIconButton(
                                    icon: Icons.delete,
                                    onPressed: () async {
                                      bool? confirm =
                                          await MaterialUtil.showConfirm(
                                              context,
                                              MessageUtil.getMessageByCode(
                                                  MessageCodeUtil
                                                      .CONFIRM_DELETE_X,
                                                  [controller.type]));
                                      if (confirm!) {
                                        final result =
                                            await controller.deleteItemType();
                                        if (mounted) {
                                          MaterialUtil.showResult(
                                              context, result);
                                        }
                                      }
                                    }),
                                NeutronIconButton(
                                    icon: controller.addMode
                                        ? Icons.line_style
                                        : Icons.add,
                                    onPressed: () {
                                      controller.toogleMode();
                                    })
                              ],
                            ),
                            if (controller.addMode)
                              Row(
                                children: [
                                  Expanded(
                                      child: NeutronTextFormField(
                                          controller: controller.teNewType,
                                          hint: UITitleUtil.getTitleByCode(
                                              UITitleCode.HINT_NAME))),
                                  NeutronIconButton(
                                      icon: Icons.save,
                                      onPressed: () async {
                                        final result =
                                            await controller.addItemType();
                                        if (mounted) {
                                          MaterialUtil.showResult(
                                              context, result);
                                        }
                                      })
                                ],
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SingleChildScrollView(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 60),
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 8),
                                child: DataTable(
                                  columnSpacing: 3,
                                  horizontalMargin: 3,
                                  columns: [
                                    DataColumn(
                                        label: Text(UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_ITEM))),
                                    DataColumn(
                                        label: Text(UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_UNIT))),
                                    const DataColumn(label: Text(''))
                                  ],
                                  rows: controller.items
                                      .map((item) => DataRow(cells: [
                                            DataCell(Tooltip(
                                                message: item.name,
                                                child: Text(item.name!,
                                                    overflow: TextOverflow
                                                        .ellipsis))),
                                            DataCell(Text(item.unit!)),
                                            DataCell(NeutronIconButton(
                                                icon: Icons.delete,
                                                onPressed: () async {
                                                  final result =
                                                      await controller
                                                          .deleteItem(
                                                              item.name!);
                                                  if (mounted) {
                                                    MaterialUtil.showResult(
                                                        context, result);
                                                  }
                                                }))
                                          ]))
                                      .toList(),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: ColorManagement.orangeColor,
                                    boxShadow: const [
                                      BoxShadow(
                                          blurRadius: 2,
                                          color: Colors.black26,
                                          offset: Offset(3, 3))
                                    ]),
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: NeutronTextFormField(
                                                controller: controller.teItem,
                                                hint:
                                                    UITitleUtil.getTitleByCode(
                                                        UITitleCode
                                                            .HINT_ITEM))),
                                        IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () async {
                                              final result =
                                                  await controller.addItem();
                                              if (mounted) {
                                                MaterialUtil.showResult(
                                                    context, result);
                                              }
                                            }),
                                        Expanded(
                                            child: NeutronTextFormField(
                                                controller: controller.teUnit,
                                                hint:
                                                    UITitleUtil.getTitleByCode(
                                                        UITitleCode.HINT_UNIT)))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
