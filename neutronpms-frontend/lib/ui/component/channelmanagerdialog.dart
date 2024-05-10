import 'package:flutter/material.dart';
import 'package:ihotel/manager/channelmanager.dart';
import 'package:ihotel/ui/component/hotel/dailyallotmentdialog.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../manager/usermanager.dart';
import '../../ui/channelmanager/cmbookingform.dart';
import '../../ui/channelmanager/cminventoryform.dart';
import '../../ui/channelmanager/cmmappingform.dart';
import '../../util/designmanagement.dart';

class ChannelManagerDialog extends StatelessWidget {
  const ChannelManagerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          width: isMobile ? kMobileWidth : kWidth,
          height: kHeight,
          child: ChangeNotifierProvider<ChannelManager>.value(
            value: ChannelManager(),
            child: Consumer<ChannelManager>(builder: (_, controller, __) {
              return DefaultTabController(
                length: UserManager.isAdmin() ? 4 : 2,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: ColorManagement.mainBackground,
                    appBar: AppBar(
                      bottom: TabBar(
                        tabs: [
                          if (UserManager.isAdmin())
                            Tooltip(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.SIDEBAR_CONFIGURATION),
                              child: const Tab(
                                icon: Icon(Icons.link),
                              ),
                            ),
                          Tooltip(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_SINGLE_UPDATE),
                            child: const Tab(
                              icon: Icon(Icons.umbrella),
                            ),
                          ),
                          Tooltip(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_BULK_UPDATE),
                              child: const Tab(
                                  icon: Icon(Icons.online_prediction))),
                          if (UserManager.isAdmin())
                            Tooltip(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_GUEST_BOOKING),
                                child:
                                    const Tab(icon: Icon(Icons.book_online))),
                        ],
                      ),
                      title: Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.SIDEBAR_CHANNEL_MANAGER),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    body: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (UserManager.isAdmin()) const CMMappingForm(),
                        const DalilyAllotmentDialog(),
                        // const CMAvaibilityForm(),
                        const CMInventoryForm(),
                        if (UserManager.isAdmin()) const CMBookingForm()
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ));
  }
}
