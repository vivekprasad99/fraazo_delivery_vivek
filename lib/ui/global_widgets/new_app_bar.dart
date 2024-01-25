import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/online_logout_dialog.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:get/get.dart';

import '../../helpers/route/route_helper.dart';

class NewAppBar extends GetView implements PreferredSizeWidget {
  final bool isShowBack;
  final bool isShowLogout;
  final bool inPop;
  final String title;
  const NewAppBar(
      {this.isShowBack = true,
      this.isShowLogout = false,
      this.inPop = true,
      this.title = ''});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Visibility(
        visible: isShowBack,
        child: IconButton(
            onPressed: inPop
                ? () {
                    RouteHelper.pop();
                  }
                : null,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            )),
      ),
      leadingWidth: isShowBack ? 40 : 0,
      title: TextView(
        title: title,
        textStyle: commonTextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      actions: [
        Visibility(
            visible: isShowLogout,
            child: IconButton(
                onPressed: () => _onLogoutTap(),
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                )))
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future _onLogoutTap() async {
    final bool isSelectedYes =
        (await RouteHelper.openDialog(OnlineLogoutDialog()) as bool?) ?? false;
    if (isSelectedYes) {
      RouteHelper.pushAndPopOthers(Routes.LOGIN);
    }
  }
}
