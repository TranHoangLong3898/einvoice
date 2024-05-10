import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controller/booking/updategroupcontroller.dart';
import '../../../manager/roommanager.dart';
import '../../../manager/roomtypemanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrontexttilte.dart';

class PickRoomUpdateGroupDialog extends StatefulWidget {
  const PickRoomUpdateGroupDialog(
      {Key? key, this.updateGroupController, this.pageController})
      : super(key: key);
  final UpdateGroupController? updateGroupController;
  final PageController? pageController;

  @override
  State<PickRoomUpdateGroupDialog> createState() =>
      _PickRoomUpdateGroupDialogState();
}

class _PickRoomUpdateGroupDialogState extends State<PickRoomUpdateGroupDialog> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);

    return ChangeNotifierProvider.value(
        value: widget.updateGroupController,
        child: Consumer<UpdateGroupController>(
            builder: ((_, updateControllerGroup, __) =>
                updateControllerGroup.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ))
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                              height: double.infinity,
                              padding: const EdgeInsets.only(bottom: 65),
                              child: buildContent(isMobile)),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: NeutronButton(
                                icon: Icons.skip_previous,
                                onPressed: () async {
                                  widget.pageController!.animateToPage(0,
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeIn);
                                },
                                icon1: Icons.add,
                                onPressed1: () async {
                                  final result =
                                      await updateControllerGroup.updateGroup();
                                  if (!mounted) {
                                    return;
                                  }
                                  if (result ==
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    Navigator.pop(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .BOOKING_GROUP_CREATE_SUCCESS,
                                            [
                                              widget.updateGroupController!
                                                  .teName!.text
                                            ]));
                                  } else {
                                    MaterialUtil.showAlert(context, result);
                                  }
                                }),
                          )
                        ],
                      ))));
  }

  List<Widget> buildChildren() {
    return widget.updateGroupController!.availableRooms.entries
        .where((element) => element.value.isNotEmpty)
        .map((roomTypeEntries) => Column(
              children: [
                SizedBox(
                    child: NeutronTextTitle(
                  message: RoomTypeManager()
                      .getRoomTypeNameByID(roomTypeEntries.key),
                )),
                GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  crossAxisCount: ResponsiveUtil.isMobile(context) ? 3 : 7,
                  mainAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
                  crossAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
                  childAspectRatio: 1.5,
                  children: [
                    ...roomTypeEntries.value
                        .map((roomID) => InkWell(
                              onTap: () {
                                widget.updateGroupController!
                                    .onTapRoomPick(roomTypeEntries.key, roomID);
                              },
                              child: Container(
                                color: widget.updateGroupController!
                                        .roomPicks[roomTypeEntries.key]!
                                        .contains(roomID)
                                    ? ColorManagement.greenColor
                                    : ColorManagement.mainBackground,
                                child: Center(
                                  child: NeutronTextTitle(
                                    message:
                                        RoomManager().getNameRoomById(roomID),
                                  ),
                                ),
                              ),
                            ))
                        .toList()
                  ],
                ),
                const SizedBox(
                  height: SizeManagement.rowSpacing,
                )
              ],
            ))
        .toList();
  }

  Widget buildContent(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(top: SizeManagement.rowSpacing),
      child: ListView(
        children: buildChildren(),
      ),
    );
  }
}
