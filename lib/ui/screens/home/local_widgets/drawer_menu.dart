import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/enums/drawer_menu_item.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/providers/delivery/latest_task_provider.dart';
import 'package:fraazo_delivery/providers/splash/authentication_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/screen_widgets/app_version_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/asset_assign_dialog.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/online_logout_dialog.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/cash_settlement_code_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

import '../../../screen_widgets/dialogs/asset_assign_dialog.dart';
import '../../../utils/toast.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu();

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final List<DrawerMenuItem> _menuItemList = [];

  /*final List<IconData> _menuIconList = [
    Icons.assignment_outlined,
    Icons.ac_unit,
    Icons.accessibility_new,
    Icons.request_quote_outlined,
    Icons.sports_motorsports_outlined,
    Icons.pin_outlined,
    Icons.history,
    Icons.money,
    Icons.person_pin_outlined,
    Icons.article_outlined,
    Icons.help_outline,
    Icons.exit_to_app,
    Icons.delivery_dining,
  ];*/

  final List<String> _menuIconNameList = [
    'ic_user_detail',
    'ic_c_hand', //ic_training
    'ic_payout',
    'ic_login',
    'ic_history',
    // 'ic_training', //ic_login_hrs
    // 'ic_payout',
    'ic_asset_mgnt',
    'ic_terms',
    'ic_support',
    'ic_logout',
  ];

  @override
  void initState() {
    super.initState();
    _menuItemList.addAll(DrawerMenuItem.values);
    /*if (!Globals.shouldShowBilling) {
      _menuItemList.removeAt(5);
      _menuIconNameList.removeAt(5);
    }*/

    // if (!PrefHelper.getBool(PrefKeys.IS_ASSET_ENABLE)) {
    //   _menuItemList.removeAt(2);
    //   _menuIconNameList.removeAt(2);
    // }
    if (!Globals.user!.billingEnabled!) {
      _menuItemList.removeAt(2);
      _menuIconNameList.removeAt(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryBlackColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrawerHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              color: lightBlackTxtColor,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: List.generate(
                _menuItemList.length,
                _buildMenuItem,
              ),
            ),
          ),
          const ContainerDivider(),
          const AppVersionWidget(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return InkWell(
      onTap: () => _onMenuTap(DrawerMenuItem.User_Details),
      child: SizedBox(
        width: double.maxFinite,
        //height: 160,0.28,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 0), //16, 50, 16, 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                  radius: 28, //30
                  backgroundColor: Colors.white,
                  backgroundImage: Globals.user!.profilePic!.isNotEmpty
                      ? NetworkImage(Globals.user!.profilePic!)
                      : null,
                  child: Visibility(
                    visible: Globals.user!.profilePic!.isEmpty,
                    child: const Text(
                      "🧔🏻",
                      style: TextStyle(fontSize: 38),
                    ),
                  )),
              sizedBoxH10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Globals.user?.fullName ?? "-",
                    style: commonTextStyle(fontSize: 18, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  sizedBoxH5,
                  Text(
                    'ID: ${Globals.user!.id}',
                    style: commonTextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    return InkWell(
      onTap: () => _onMenuTap(_menuItemList[index]),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.center,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              blendMode: BlendMode.dstOut,
              child: SvgPicture.asset(
                _menuIconNameList[index].svgImageAsset,
                color: menuTitleColor,
              ),
            ),
            /*Icon(
              _menuIconNameList[index],
              color: menuTitleColor,
            ),*/
            sizedBoxW20,
            Expanded(
              child: Text(
                _menuItemList[index].name.replaceAll("_", " "),
                style: commonTextStyle(
                  fontSize: 14,
                  color: menuTitleColor,
                ),
                /*style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: menuTitleColor,
                  fontSize: 15,
                ),*/
              ),
            )
          ],
        ),
      ),
    );
  }

  // not using index here because code becomes less readable
  void _onMenuTap(DrawerMenuItem drawerMenuItem) {
    RouteHelper.pop();
    switch (drawerMenuItem) {
      case DrawerMenuItem.User_Details:
        RouteHelper.push(Routes.REGISTRATION_SCREEN, args: false);
        break;

      // case DrawerMenuItem.Training_Screen:
      //   RouteHelper.push(Routes.TRAINING_SCREEN);
      //   break;

      case DrawerMenuItem.Asset_Management:
        //
        RouteHelper.push(Routes.ASSET_MANAGEMENT_SCREEN);
        //_openAssetAssignDialog();
        break;
      case DrawerMenuItem.Settle_cash_in_hand:
        RouteHelper.push(Routes.FLOATING_CASH);
        break;
      case DrawerMenuItem.Payouts:
        RouteHelper.push(Routes.EARNINGS);
        // _showCashSettlementCodeDialog();
        break;
      case DrawerMenuItem.Task_History:
        RouteHelper.push(Routes.HISTORY);
        break;
      // case DrawerMenuItem.Earnings:
      //   RouteHelper.push(Routes.EARNINGS);
      //   break;
      case DrawerMenuItem.Login_Hours:
        RouteHelper.push(Routes.RIDER_ATTENDANCE);
        break;
      case DrawerMenuItem.Terms_And_Conditions:
        RouteHelper.push(Routes.TERMS_CONDITIONS_SCREEN);
        //_openTermsAndConditionsDialog();
        break;
      case DrawerMenuItem.Support:
        final _orderSeqList =
            context.read(latestTaskProvider.notifier).getOrderSeq();

        final _orderSeq = _orderSeqList
            ?.where((element) =>
                element.orderStatus == Constants.OS_REACHED_CUSTOMER)
            .toList();

        if (_orderSeq?.isNotEmpty ?? false) {
          if (!(_orderSeq?.single.supportEnabled ?? false)) {
            Toast.error(
                'Support will be available once you reach the customer location.');
          } else {
            _navigateToSupport();
          }
        } else {
          _navigateToSupport();
        }

        /*if (!Globals.isSupportEnable) {
          Toast.error(
              'Support will be available once you reach the customer location.');
        } else {
          RouteHelper.push(Routes.SUPPORT_SCREEN);
          // _openSupportDialog();
        }*/
        break;
      case DrawerMenuItem.Logout:
        _onLogoutTap();
        break;
      default:
        break;
    }
  }

  void _navigateToSupport() => RouteHelper.push(Routes.SUPPORT_SCREEN);

  Future _onLogoutTap() async {
    if (Globals.user?.status?.toLowerCase() == "busy") {
      Toast.error('Please complete your current Task!');
    } else {
      final bool isSelectedYes =
          (await RouteHelper.openDialog(OnlineLogoutDialog()) as bool?) ??
              false;
      if (isSelectedYes) {
        AuthenticationProvider().logout();
      }
    }
  }

  void _openAssetManagementDialog() {
    showDialog(
      context: context,
      builder: (_) => const AssetAssignDialog(),
    );
  }

  void _showCashSettlementCodeDialog() {
    showDialog(context: context, builder: (_) => CashSettlementCodeDialog());
  }

  /*Future _openTermsAndConditionsDialog() {
    return showDialog(
      context: context,
      builder: (_) => const TermsAndConditionsDialog(isAcceptMode: false),
    );
  }*/

  /* void _openSupportDialog() {
    RouteHelper.pop();
    showDialog(
      context: context,
      builder: (_) => const SupportDialog(),
    );
  }*/

  Future _openAssetAssignDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AssetAssignDialog(),
    );
  }
}
