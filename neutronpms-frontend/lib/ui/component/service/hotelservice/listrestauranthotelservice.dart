import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/item/listitemdialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/minibarhotelservicedialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class ListRestaurantHotelService extends StatefulWidget {
  const ListRestaurantHotelService({Key? key}) : super(key: key);

  @override
  State<ListRestaurantHotelService> createState() =>
      _ListRestaurantHotelServiceState();
}

class _ListRestaurantHotelServiceState
    extends State<ListRestaurantHotelService> {
  ItemManager itemManager = ItemManager();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);

    return ChangeNotifierProvider.value(
        value: itemManager,
        child: Consumer<ItemManager>(
            child: const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor)),
            builder: (_, itemManager, child) {
              if (itemManager.isLoading) {
                return child!;
              }
              return Stack(children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    child: Column(
                      children: [
                        isMobile ? buildTitleInMobile() : buildTitleInPC(),
                        //list
                        Expanded(child: buildContent(isMobile)),
                      ],
                    )),
                //add-button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NeutronButton(
                    icon1: Icons.add,
                    onPressed1: () async {
                      await showDialog(
                          context: context,
                          builder: (ctx) => const MinibarHotelServiceDialog(
                              type: ItemType.restaurant));
                    },
                  ),
                )
              ]);
            }));
  }

  Widget buildTitleInPC() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      height: SizeManagement.cardHeight,
      child: Row(
        children: [
          Expanded(
            child: NeutronTextTitle(
              fontSize: 14,
              isPadding: true,
              messageUppercase: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ID),
            ),
          ),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              isPadding: true,
              messageUppercase: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              fontSize: 14,
              textAlign: TextAlign.end,
              isPadding: false,
              messageUppercase: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
            ),
          ),
          const SizedBox(width: 150)
        ],
      ),
    );
  }

  Widget buildTitleInMobile() {
    return Container(
      height: 45,
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(
              width: SizeManagement.cardInsideHorizontalPadding +
                  SizeManagement.cardOutsideHorizontalPadding),
          Expanded(
              child: NeutronTextTitle(
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            fontSize: 14,
            messageUppercase: false,
          )),
          const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding)
        ],
      ),
    );
  }

  Widget buildContent(bool isMobile) {
    if (ItemManager().items.isEmpty) {
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 20),
              children: [
                TextSpan(
                    text: MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_NEED_TO_CONFIG_X_FIRST, [
                  UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ITEM)
                      .toLowerCase()
                ])),
                TextSpan(
                    text:
                        '\n\n${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_PLEASE)}'),
                TextSpan(
                  text: MessageUtil.getMessageByCode(
                          MessageCodeUtil.TEXTALERT_CLICK_HERE)
                      .toLowerCase(),
                  style: const TextStyle(
                      color: ColorManagement.redColor, fontSize: 20),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await showDialog(
                          context: context,
                          builder: (context) => const ListItemDialog());
                    },
                ),
              ]),
        ),
      );
    }

    if (RestaurantItemManager().restaurantItems.isEmpty) {
      return Center(
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(
                MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)),
      );
    }

    return ListView(
        children: isMobile ? buildContentInMobile() : buildContentInPC());
  }

  List<Container> buildContentInPC() {
    return RestaurantItemManager().restaurantItems.map((resItem) {
      return Container(
        height: SizeManagement.cardHeight,
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Row(
          children: [
            const SizedBox(width: SizeManagement.dropdownLeftPadding),
            //id
            Expanded(child: NeutronTextContent(message: resItem.id!)),
            const SizedBox(width: SizeManagement.dropdownLeftPadding),
            //name
            Expanded(
              flex: 2,
              child: NeutronTextContent(
                  tooltip: resItem.name, message: resItem.name!),
            ),
            //price
            Expanded(
                child: NeutronTextContent(
              textAlign: TextAlign.end,
              color: ColorManagement.positiveText,
              message: NumberUtil.numberFormat
                  .format(RestaurantItemManager().getPriceOfItem(resItem.id!)),
            )),
            const SizedBox(width: 30),
            SizedBox(
              width: 60,
              child: IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (ctx) => MinibarHotelServiceDialog(
                          item: resItem, type: ItemType.restaurant));
                },
              ),
            ),
            //delete-button
            SizedBox(
              width: 60,
              child: IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  bool? confirm = await MaterialUtil.showConfirm(
                      context,
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_DELETE_X, [resItem.name!]));
                  if (confirm == null || !confirm) {
                    return;
                  }
                  HotelItem itemDelete = HotelItem.copy(resItem)
                    ..type = ItemType.other;
                  itemManager.isLoading = true;
                  String result = await itemManager.updateItem(itemDelete);
                  itemManager
                    ..isLoading = false
                    ..rebuild();
                  if (mounted) {
                    MaterialUtil.showResult(
                        context, MessageUtil.getMessageByCode(result));
                  }
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Container> buildContentInMobile() {
    return RestaurantItemManager().restaurantItems.map((resItem) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        child: ExpansionTile(
          childrenPadding: const EdgeInsets.symmetric(horizontal: 15),
          title: Row(
            children: [
              Expanded(
                child: NeutronTextContent(message: resItem.name!),
              ),
              const SizedBox(width: 8),
            ],
          ),
          children: [
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ID),
                )),
                Expanded(
                  child: NeutronTextContent(message: resItem.id!),
                )
              ],
            ),
            const SizedBox(height: 15),
            //name
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
                )),
                Expanded(
                  child: NeutronTextContent(
                      tooltip: resItem.name, message: resItem.name!),
                )
              ],
            ),
            const SizedBox(height: 15),
            //price
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
                )),
                Expanded(
                  child: NeutronTextContent(
                    color: ColorManagement.positiveText,
                    message: NumberUtil.numberFormat.format(
                        RestaurantItemManager().getPriceOfItem(resItem.id!)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            //button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (ctx) => MinibarHotelServiceDialog(
                              item: resItem, type: ItemType.restaurant));
                    },
                    icon: const Icon(Icons.edit)),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    bool? confirm = await MaterialUtil.showConfirm(
                        context,
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.CONFIRM_DELETE_X, [resItem.name!]));
                    if (confirm == null || !confirm) {
                      return;
                    }
                    HotelItem itemDelete = HotelItem.copy(resItem)
                      ..type = ItemType.other;
                    itemManager.isLoading = true;
                    String result = await itemManager.updateItem(itemDelete);
                    itemManager
                      ..isLoading = false
                      ..rebuild();
                    if (mounted) {
                      MaterialUtil.showResult(
                          context, MessageUtil.getMessageByCode(result));
                    }
                  },
                )
              ],
            )
          ],
        ),
      );
    }).toList();
  }
}
