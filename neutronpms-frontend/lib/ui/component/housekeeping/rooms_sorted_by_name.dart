import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/room.dart';

import '../../../controller/housekeeping/housekeepingcontroller.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronroombox.dart';

class RoomsSortedByName extends StatefulWidget {
  final RoomManager roomManager;
  final HouseKeepingPageController controller;

  const RoomsSortedByName({
    Key? key,
    required this.roomManager,
    required this.controller,
  }) : super(key: key);

  @override
  State<RoomsSortedByName> createState() => _RoomsSortedByNameState();
}

class _RoomsSortedByNameState extends State<RoomsSortedByName> {
  late List<Room> sortedRooms;

  @override
  void initState() {
    sortedRooms = [];
    super.initState();
  }

  void update() {
    sortedRooms.clear();
    sortedRooms.addAll(widget.roomManager.rooms!);
    sortedRooms.sort((a, b) => a.name!.compareTo(b.name!));
  }

  @override
  Widget build(BuildContext context) {
    update();

    final bool isMobile = ResponsiveUtil.isMobile(context);
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: isMobile ? 4 : 10,
      spacing: isMobile ? 4 : 10,
      children: sortedRooms
          .map((room) =>
              NeutronRoomBox(controller: widget.controller, room: room))
          .toList(),
    );
  }
}
