import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/providers/asset_management/assigned_update_provider.dart';
import 'package:fraazo_delivery/providers/asset_management/rider_asset_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_outline_button.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class AssetAssignDialog extends StatefulWidget {
  const AssetAssignDialog({Key? key}) : super(key: key);

  @override
  _AssetAssignDialogState createState() => _AssetAssignDialogState();
}

class _AssetAssignDialogState extends State<AssetAssignDialog> {
  final _assignedUpdateProvider = StateNotifierProvider(
    (_) => AssignedUpdateProvider(const AsyncLoading()),
  );

  @override
  void initState() {
    super.initState();
    _getRiderAsset();
  }

  String requestId = "";
  List<Map<String, dynamic>> asset = [];
  late RiderAssetModel riderAsset;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            title: Text(
              "ATL has assigned you",
              style: commonPoppinsStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: assetAssignedColors),
              textAlign: TextAlign.center,
            ),
            content: Consumer(
              builder: (_, watch, __) {
                return watch(riderAssetProvider).when(
                  data: (RiderAssetModel riderAsset) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAssetList(riderAsset),
                      sizedBoxH30,
                      _buildAcceptRejectButton(riderAsset),
                      _buildCloseButton(riderAsset),
                    ],
                  ),
                  loading: () => const FDCircularLoader(
                    progressColor: bgColor,
                  ),
                  error: (e, _) => FDErrorWidget(
                    textColor: bgColor,
                    onPressed: _getRiderAsset,
                    errorType: e,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetList(RiderAssetModel riderAsset) {
    if (riderAsset.riderAssetList.isEmpty) {
      return const NoDataWidget(
        textColor: Colors.black,
      );
    }
    requestId = riderAsset.riderAssetList[0].requestId!;
    return Column(
      children: [
        for (RiderAsset assetDetail in riderAsset.riderAssetList)
          Padding(
            padding: EdgeInsets.symmetric(vertical: px_8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: bgColor,
                  child: ClipOval(
                    child: SvgPicture.asset(
                      (assetDetail.name ?? '').assetProductType().svgImageAsset,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: px_10, right: px_10),
                    child: Text(
                      assetDetail.name.toString(),
                      style: commonTextStyle(fontSize: 14, color: assetColors),
                    ),
                  ),
                ),
                Text(assetDetail.quantity.toString(),
                    style: commonTextStyle(color: assetColors, fontSize: 14),
                    textAlign: TextAlign.end)
              ],
            ),
          )
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     CircleAvatar(
        //       radius: 19,
        //       backgroundColor: bgColor,
        //       child: ClipOval(
        //         child: SvgPicture.asset(
        //           (assetDetail.name ?? '').assetProductType().svgImageAsset,
        //         ),
        //       ),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20),
        //       child: Expanded(
        //         child: Text(
        //           assetDetail.name.toString(),
        //           style: commonTextStyle(fontSize: 14, color: assetColors),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: Text(assetDetail.quantity.toString(),
        //           style: commonTextStyle(color: assetColors, fontSize: 14),
        //           textAlign: TextAlign.end),
        //     ),
        //   ],
        // ),
        // sizedBoxH15
      ],
    );
    ListView.separated(
      shrinkWrap: true,
      itemCount: riderAsset.riderAssetList.length,
      itemBuilder: (_, int index) {
        final assetDetail = riderAsset.riderAssetList[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: bgColor,
              child: ClipOval(
                child: SvgPicture.asset(
                  (assetDetail.name ?? '').assetProductType().svgImageAsset,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Expanded(
                child: Text(
                  assetDetail.name.toString(),
                  style: commonTextStyle(fontSize: 14, color: assetColors),
                ),
              ),
            ),
            Expanded(
              child: Text(assetDetail.quantity.toString(),
                  style: commonTextStyle(color: assetColors, fontSize: 14),
                  textAlign: TextAlign.end),
            ),
          ],
        );
      },
      separatorBuilder: (_, __) => sizedBoxH15,
    );
  }

  Widget _buildAcceptRejectButton(RiderAssetModel riderAsset) {
    return Visibility(
      visible: riderAsset.riderAssetList.isNotEmpty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NewOutlineButton(
            buttonBgColor: Colors.white,
            activeColor: assetFontColors,
            inactiveColor: Colors.white,
            buttonRadius: px_4,
            buttonHeight: 38,
            borderWidth: 1,
            buttonWidth: 138,
            buttonTitle: 'Reject',
            fontColor: assetFontColors,
            onPressed: () {
              _onRejectTap(requestId);
            },
          ),
          sizedBoxW10,
          NewPrimaryButton(
            onPressed: () {
              _onAcceptTap(requestId);
            },
            buttonTitle: "Accept",
            buttonWidth: 138,
            buttonHeight: 38,
            fontSize: 14,
            activeColor: buttonColor,
            inactiveColor: buttonColor,
            buttonRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(RiderAssetModel riderAsset) {
    return Visibility(
      visible: riderAsset.riderAssetList.isEmpty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NewOutlineButton(
            buttonBgColor: Colors.white,
            activeColor: assetFontColors,
            inactiveColor: Colors.white,
            buttonRadius: px_4,
            buttonHeight: 38,
            borderWidth: 1,
            buttonWidth: 138,
            buttonTitle: 'Close',
            fontColor: assetFontColors,
            onPressed: () {
              _onCloseTap();
            },
          ),
        ],
      ),
    );
  }

  Future _onAcceptTap(String id) async {
    await context
        .read(_assignedUpdateProvider.notifier)
        .updateAssignedStatus(id, "ACCEPTED");
    Toast.normal("Items Assigned Successfully");
    RouteHelper.pop();
  }

  Future _onRejectTap(String id) async {
    await context
        .read(_assignedUpdateProvider.notifier)
        .updateAssignedStatus(id, "REJECTED");
    Toast.normal("Asset Request Rejected Successfully");
    RouteHelper.pop();
  }

  void _onCloseTap() {
    RouteHelper.pop();
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

  Future _getRiderAsset() {
    return context.read(riderAssetProvider.notifier).getRiderAssetFetch();
  }
}
