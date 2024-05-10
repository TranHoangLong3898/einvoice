import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/hotel.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';

class SelectHotelItem extends StatelessWidget {
  const SelectHotelItem({
    Key? key,
    required this.hotel,
    required this.imageData,
  }) : super(key: key);

  final Hotel hotel;
  final Uint8List? imageData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //image
        hotelImage,
        //hotel name
        Expanded(
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: ColorManagement.transparentBackground,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: NeutronTextContent(
              message: hotel.name!,
            ),
          ),
        ),
      ],
    );
  }

  Widget get hotelImage {
    Widget image;
    if (imageData == null) {
      image = Container(
        height: double.maxFinite,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(SizeManagement.borderRadius8),
          ),
        ),
        child: NeutronTextContent(
          message:
              MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NO_AVATAR),
        ),
      );
    } else {
      image = ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        child: Image.memory(imageData!, fit: BoxFit.cover),
      );
    }

    return AspectRatio(aspectRatio: 1, child: image);
  }
}
