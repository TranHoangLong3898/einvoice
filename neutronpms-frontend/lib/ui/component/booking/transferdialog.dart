import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/transfercontroller.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../util/designmanagement.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';

class TransferDialog extends StatelessWidget {
  final Booking? booking;

  const TransferDialog({
    Key? key,
    this.booking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth;
    }

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        height: height,
        width: width,
        child: ChangeNotifierProvider(
          create: (_) => TransferController(booking),
          child: Consumer<TransferController>(
            builder: (_, controller, __) {
              if (controller.isLoading()) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.transfers == null) {
                return Center(
                  child: Text(MessageUtil.getMessageByCode(
                      MessageCodeUtil.UNDEFINED_ERROR)),
                );
              }
              Widget child;
              if (controller.transfers!.isEmpty) {
                child = Center(
                  child: Text(
                      MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)),
                );
              } else {
                final children = controller.transfers!
                    .map((transfer) => Card(
                          margin: const EdgeInsets.all(10),
                          color: ColorManagement.lightMainBackground,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: const CircleAvatar(
                                    backgroundColor:
                                        ColorManagement.orangeColor,
                                    child: Icon(Icons.drive_file_move_outline),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        NumberUtil.numberFormat
                                            .format(transfer.amount),
                                        style: const TextStyle(
                                            color:
                                                ColorManagement.positiveText),
                                      ),
                                      Text(transfer.time!
                                          .toDate()
                                          .toString()
                                          .split(".")[0]),
                                      Text(transfer.desc!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList();

                child = Expanded(child: ListView(children: children));
              }

              return Stack(fit: StackFit.expand, children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 65),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Tooltip(
                          message: controller.getInfo(),
                          child: Text(
                            controller.getInfo(),
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      child
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NeutronButtonText(
                      text:
                          "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.getTotal())}"),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }
}
