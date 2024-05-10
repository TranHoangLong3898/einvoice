import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/addgroupcontroller.dart';
import 'package:ihotel/ui/component/booking_group/general_group_dialog.dart';
import 'package:ihotel/ui/component/booking_group/pick_room_group_dialog.dart';
import '../../../constants.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';

class PageOneAddGroup extends StatefulWidget {
  const PageOneAddGroup({
    Key? key,
  }) : super(key: key);

  @override
  State<PageOneAddGroup> createState() => _PageOneAddGroupState();
}

class _PageOneAddGroupState extends State<PageOneAddGroup> {
  final PageController pageController = PageController(initialPage: 0);
  AddGroupController? _groupController;
  List<Widget> page = [];

  @override
  void initState() {
    _groupController ??= AddGroupController();
    page = [
      GeneralGroupDialog(
        pageController: pageController,
        groupController: _groupController!,
      ),
      PickRoomGroupDialog(
        groupController: _groupController!,
        pageController: pageController,
      )
    ];
    super.initState();
  }

  @override
  void dispose() {
    _groupController?.teName?.dispose();
    _groupController?.teEmail?.dispose();
    _groupController?.tePhone?.dispose();
    _groupController?.teNotes?.dispose();
    _groupController?.teSaler?.dispose();
    _groupController?.teExternalSaler?.dispose();
    for (var element in _groupController!.teNums.values) {
      element.disposeTextController();
    }
    _groupController?.teSourceID?.dispose();
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
