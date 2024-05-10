import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/addgroupcontroller.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbutton.dart';

class PickRoomGroupDialog extends StatefulWidget {
  const PickRoomGroupDialog(
      {Key? key, required this.groupController, this.pageController})
      : super(key: key);
  final AddGroupController groupController;
  final PageController? pageController;
  @override
  State<PickRoomGroupDialog> createState() => _PickRoomGroupState();
}

class _PickRoomGroupState extends State<PickRoomGroupDialog> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);

    return ChangeNotifierProvider.value(
        value: widget.groupController,
        child: Consumer<AddGroupController>(
            builder: ((_, controllerGroup, __) => controllerGroup.isLoading
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
                          child: buildContent(isMobile, controllerGroup)),
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
                              final result = await controllerGroup.addGroup();
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
                                        [widget.groupController.teName!.text]));
                              } else {
                                MaterialUtil.showAlert(context, result);
                              }
                            }),
                      )
                    ],
                  ))));
  }

  List<Widget> buildChildren() {
    return widget.groupController.availableRooms.entries
        .where((element) => element.value!.isNotEmpty)
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
                    ...roomTypeEntries.value!
                        .map((roomID) => InkWell(
                              onTap: () {
                                widget.groupController
                                    .onTapRoomPick(roomTypeEntries.key, roomID);
                              },
                              child: Container(
                                color: widget.groupController
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
    // ..add(Column(
    //   children: [
    //     NeutronButton(
    //         icon: Icons.skip_previous,
    //         onPressed: () async {
    //           widget.pageController.animateToPage(0,
    //               duration: const Duration(seconds: 1), curve: Curves.easeIn);
    //         }),
    //     const SizedBox(
    //       height: SizeManagement.rowSpacing,
    //     )
    //   ],
    // ));
  }

  Widget buildContent(bool isMobile, AddGroupController controllerGroup) {
    return Padding(
      padding: const EdgeInsets.only(top: SizeManagement.rowSpacing),
      child: ListView(
        children: buildChildren(),
      ),
    );
  }
}
