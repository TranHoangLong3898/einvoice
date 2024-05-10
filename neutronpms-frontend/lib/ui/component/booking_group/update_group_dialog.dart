import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/component/booking_group/pick_room_update_group_dialog.dart';
import '../../../controller/booking/updategroupcontroller.dart';
import '../../../modal/booking.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';
import 'general_update_group_booking_dialog.dart';

class UpdateGroupDialog extends StatefulWidget {
  final List<Booking>? bookings;
  final bool? isUpdate;
  const UpdateGroupDialog({Key? key, this.bookings, this.isUpdate})
      : super(key: key);

  @override
  State<UpdateGroupDialog> createState() => _UpdateGroupDialogState();
}

class _UpdateGroupDialogState extends State<UpdateGroupDialog> {
  final PageController pageController = PageController(initialPage: 0);
  UpdateGroupController? _updateGroupController;
  List<Widget> page = [];

  @override
  void initState() {
    _updateGroupController ??= UpdateGroupController(widget.bookings);
    page = [
      GeneralUpdateGroupDialog(
          pageController: pageController,
          updateGroupController: _updateGroupController,
          isUpdate: widget.isUpdate),
      PickRoomUpdateGroupDialog(
        updateGroupController: _updateGroupController,
        pageController: pageController,
      )
    ];
    super.initState();
  }

  @override
  void dispose() {
    _updateGroupController?.teName?.dispose();
    _updateGroupController?.teEmail?.dispose();
    _updateGroupController?.tePhone?.dispose();
    _updateGroupController?.teNotes?.dispose();
    _updateGroupController?.teSaler?.dispose();
    _updateGroupController?.teExternalSaler?.dispose();
    for (var element in _updateGroupController!.teNums.values) {
      element.disposeTextController();
    }
    _updateGroupController?.teSourceID?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth + 50;
    }
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return page[index];
          },
          itemCount: page.length,
          controller: pageController,
        ),
      ),
    );
  }
}
