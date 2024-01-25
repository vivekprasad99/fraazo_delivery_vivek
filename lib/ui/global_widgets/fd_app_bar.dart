import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class FDAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color backgroundColor;

  const FDAppBar({
    Key? key,
    this.titleText,
    this.actions,
    this.onBackPressed,
    this.backgroundColor = AppColors.primary,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: bgColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleSpacing: titleText != null ? NavigationToolbar.kMiddleSpacing : 0,
      title: titleText != null
          ? Text(
              titleText!,
              /*style: const TextStyle(
                color: Colors.white,
              ),*/
              style: commonTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : const SizedBox(
              height: 48,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                //child: AppLogo(),
              ),
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
