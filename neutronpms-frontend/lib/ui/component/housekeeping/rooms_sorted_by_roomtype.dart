import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/modal/room.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';

import '../../../controller/housekeeping/housekeepingcontroller.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronroombox.dart';

class RoomsSortedByRoomType extends StatefulWidget {
  final RoomManager roomManager;
  final HouseKeepingPageController controller;

  const RoomsSortedByRoomType({
    Key? key,
    required this.roomManager,
    required this.controller,
  }) : super(key: key);

  @override
  State<RoomsSortedByRoomType> createState() => _RoomsSortedByRoomTypeState();
}

class _RoomsSortedByRoomTypeState extends State<RoomsSortedByRoomType> {
  late SplayTreeMap<String, List<Room>> sortedRooms;

  @override
  void initState() {
    sortedRooms = SplayTreeMap((key1, key2) => key1.compareTo(key2));
    super.initState();
  }

  void update() {
    sortedRooms.clear();
    List<Room> temp = List.from(widget.roomManager.rooms!)
      ..sort((a, b) => a.name!.compareTo(b.name!));
    for (var element in temp) {
      if (!sortedRooms.containsKey(element.roomType)) {
        sortedRooms[element.roomType!] = [];
      }
      sortedRooms[element.roomType]!.add(element);
    }
  }

  @override
  Widget build(BuildContext context) {
    update();
    final bool isMobile = ResponsiveUtil.isMobile(context);

    return Column(
      children: sortedRooms.entries
          .map(
            (e) => Card(
              elevation: 4,
              color: ColorManagement.mainBackground,
              child: ExpansionTile(
                backgroundColor: ColorManagement.mainBackground,
                initiallyExpanded: true,
                title: NeutronTextTitle(
                    message: RoomTypeManager().getRoomTypeNameByID(e.key)),
                expandedAlignment: Alignment.centerLeft,
                childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: isMobile ? 4 : 10,
                    spacing: isMobile ? 4 : 10,
                    children: e.value
                        .map((room) => NeutronRoomBox(
                            controller: widget.controller, room: room))
                        .toList(),
                  ),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
