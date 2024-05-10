import 'package:flutter/material.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';

import '../../../manager/itemmanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutrontextcontent.dart';
import 'itemdialog.dart';

class ItemWidget extends StatelessWidget {
  final BuildContext? parentContext;
  final HotelItem item;

  const ItemWidget({Key? key, required this.item, this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double widthOfItemImage = 240;
    return Container(
      width: widthOfItemImage,
      height: widthOfItemImage / 3,
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => ItemDialog(item: item));
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                //image
                Container(
                  width: widthOfItemImage / 3,
                  decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(
                              color: ColorManagement.borderCell, width: 1))),
                  alignment: Alignment.center,
                  child: item.image == null
                      ? NeutronTextContent(
                          textAlign: TextAlign.center,
                          textOverflow: TextOverflow.clip,
                          message: MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_NO_AVATAR))
                      : Image.memory(item.image!,
                          filterQuality: FilterQuality.none),
                ),
                const SizedBox(
                    width: SizeManagement.cardOutsideHorizontalPadding),
                //info of item
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: NeutronTextContent(
                                tooltip: item.name,
                                fontSize: 15,
                                message: item.name!),
                          ),
                          const SizedBox(width: 40)
                        ],
                      ),
                      NeutronTextContent(
                          message:
                              '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT)}: ${item.unit}'),
                      RichText(
                        text: TextSpan(
                            text:
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COST_PRICE)}: ',
                            style: NeutronTextStyle.content,
                            children: [
                              TextSpan(
                                text: NumberUtil.numberFormat
                                    .format(item.costPrice),
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: ColorManagement.positiveText),
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 5,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                width: 50,
                height: 20,
                child: Switch(
                    value: item.isActive ?? true,
                    activeColor: ColorManagement.greenColor,
                    inactiveTrackColor: ColorManagement.mainBackground,
                    onChanged: (value) async {
                      bool? confirm = await MaterialUtil.showConfirm(
                          context,
                          MessageUtil.getMessageByCode(
                              value
                                  ? MessageCodeUtil.CONFIRM_ACTIVE
                                  : MessageCodeUtil.CONFIRM_DEACTIVE,
                              [item.name!]));
                      if (confirm == null || confirm == false) {
                        return;
                      }
                      String result =
                          await ItemManager().toggleActivation(item.id!);
                      // ignore: use_build_context_synchronously
                      MaterialUtil.showResult(
                          parentContext!, MessageUtil.getMessageByCode(result));
                    }),
              )),
        ],
      ),
    );
  }
}
