import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/room.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../controller/housekeeping/housekeepingcontroller.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronroombox.dart';
import '../../controls/neutrontexttilte.dart';

class RoomsSortedByStatus extends StatefulWidget {
  final RoomManager roomManager;
  final HouseKeepingPageController controller;

  const RoomsSortedByStatus({
    Key? key,
    required this.roomManager,
    required this.controller,
  }) : super(key: key);

  @override
  State<RoomsSortedByStatus> createState() => _RoomsSortedByStatusState();
}

class _RoomsSortedByStatusState extends State<RoomsSortedByStatus> {
  late List<Room> dirtyRooms, cleanRooms, vacantOvernight;

  @override
  void initState() {
    dirtyRooms = [];
    cleanRooms = [];
    vacantOvernight = [];
    super.initState();
  }

  void update() {
    dirtyRooms.clear();
    cleanRooms.clear();
    vacantOvernight.clear();
    dirtyRooms.addAll(
        widget.roomManager.rooms!.where((element) => !element.isClean!));
    cleanRooms.addAll(widget.roomManager.rooms!
        .where((element) => element.isClean! && !element.vacantOvernight!));
    vacantOvernight.addAll(
        widget.roomManager.rooms!.where((element) => element.vacantOvernight!));
    dirtyRooms.sort((a, b) => a.name!.compareTo(b.name!));
    cleanRooms.sort((a, b) => a.name!.compareTo(b.name!));
    vacantOvernight.sort((a, b) => a.name!.compareTo(b.name!));
  }

  @override
  Widget build(BuildContext context) {
    update();

    final bool isMobile = ResponsiveUtil.isMobile(context);

    return Column(
      children: [
        buildRoomsByStatus(true, false, isMobile),
        buildRoomsByStatus(false, false, isMobile),
        buildRoomsByStatus(false, true, isMobile),
      ],
    );
  }

  Widget buildRoomsByStatus(
      bool isDirtyType, bool isVacantOvernight, bool isMobile) {
    return Card(
      elevation: 4,
      color: ColorManagement.mainBackground,
      child: ExpansionTile(
        backgroundColor: ColorManagement.mainBackground,
        initiallyExpanded: true,
        title: NeutronTextTitle(
            message: isVacantOvernight
                ? "Vacant Clean Overnight"
                : UITitleUtil.getTitleByCode(isDirtyType
                    ? UITitleCode.TABLEHEADER_DIRTY_ROOM
                    : UITitleCode.TABLEHEADER_CLEAN_ROOM)),
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            runSpacing: isMobile ? 4 : 10,
            spacing: isMobile ? 4 : 10,
            children: (isVacantOvernight
                    ? vacantOvernight
                    : isDirtyType
                        ? dirtyRooms
                        : cleanRooms)
                .map((room) =>
                    NeutronRoomBox(controller: widget.controller, room: room))
                .toList(),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
