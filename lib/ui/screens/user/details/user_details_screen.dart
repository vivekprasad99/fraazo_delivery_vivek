import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/models/user/bank_details_model.dart';
import 'package:fraazo_delivery/providers/splash/authentication_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/asset_details_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/basic_user_details_widget.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';

import '../../../../helpers/shared_pref/pref_keys.dart';
import 'local_widgets/bank_details_widget.dart';
import 'local_widgets/extra_user_details_widget.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({Key? key}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isUserVerified = Globals.user?.isVerified ?? false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: FDAppBar(
        titleText: "User Details",
        actions: [
          if (!RouteHelper.canPop() && !_isUserVerified)
            TextButton(
                onPressed: _onCheckVerification,
                child: const Text(
                  "Check Verification",
                  style: TextStyle(color: Colors.white),
                ))
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar:
          RouteHelper.canPop() ? null : _buildNavigationButton(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
      child: FlexSeparated(
        spacing: 15,
        direction: Axis.vertical,
        children: [
          _buildVerifiedOrNotWidget(),
          if (!_isUserVerified)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Please fill below details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          _buildExpandedCard("Basic Details", const BasicUserDetailsWidget()),
          _buildExpandedCard("Extra Details", const ExtraUserDetailsWidget(),
              isInitiallyExpanded: !_isUserVerified),

          // _buildExpandedCard("Documents", const DocumentDetails()),
          // _buildExpandedCard(
          //   "Bank Details",
          //   BankDetailsWidget(_bankDetailsProvider),
          //   middleChild: _buildVerificationBadgeForBank(),
          // ),
          Visibility(
              visible: PrefHelper.getBool(PrefKeys.IS_ASSET_ENABLE),
              child: _buildExpandedCard("Asset", const AssetDetailsWidget())),
        ],
      ),
    );
  }

  Widget _buildExpandedCard(
    String title,
    Widget child, {
    bool isInitiallyExpanded = false,
    Widget? middleChild,
  }) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow()],
      ),
      child: ExpansionTile(
        maintainState: true,
        initiallyExpanded: isInitiallyExpanded,
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (middleChild != null) ...[sizedBoxW10, middleChild],
          ],
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        children: [child],
      ),
    );
  }

  Widget _buildVerifiedOrNotWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _isUserVerified ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _isUserVerified
            ? "Your account is verified"
            : "Your account is not verified yet",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    return SizedBox(
      height: 50,
      child: Align(
          child: InkWell(
        child: TextButton(
          onPressed: () => _isUserVerified
              ? RouteHelper.pushReplacement(Routes.HOME)
              : AuthenticationProvider().logout(checkPermission: false),
          child: Text(
            _isUserVerified ? "GO TO TASKS" : "LOGOUT",
            style: TextStyle(
              color: _isUserVerified ? AppColors.primary : Colors.red,
              fontSize: _isUserVerified ? 17 : 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )),
    );
  }

  // Widget _buildVerificationBadgeForBank() {
  //   return Consumer(
  //     builder: (_, watch, __) {
  //       final asyncValue = watch();
  //       final bankDetails = asyncValue.data?.value;
  //       if (bankDetails?.id == null) {
  //         return const SizedBox();
  //       }
  //       final String verificationStatus =
  //           bankDetails?.verificationStatus ?? "-";
  //
  //       final Color bgColor;
  //       if (verificationStatus == "VERIFIED_BY_PAYU") {
  //         bgColor = Colors.green;
  //       } else if (verificationStatus == "PENDING") {
  //         bgColor = Colors.orange;
  //       } else {
  //         bgColor = Colors.red;
  //       }
  //       return Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //         decoration: BoxDecoration(
  //           color: bgColor,
  //           borderRadius: BorderRadius.circular(6),
  //         ),
  //         child: Text(
  //           verificationStatus,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 13,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future _onCheckVerification() async {
    await ProviderContainer()
        .read(userProfileProvider.notifier)
        .getUserDetails();
    if (_isUserVerified != Globals.user?.isVerified) {
      setState(() {
        _isUserVerified = Globals.user?.isVerified ?? false;
      });
    }
  }
}
