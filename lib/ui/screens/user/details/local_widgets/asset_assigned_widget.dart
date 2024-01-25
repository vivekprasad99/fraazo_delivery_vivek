import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/providers/asset_management/rider_asset_accepted_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/asset_title.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class AssetAssignedWidget extends StatefulWidget {
  const AssetAssignedWidget({Key? key}) : super(key: key);

  @override
  _AssetAssignedWidgetState createState() => _AssetAssignedWidgetState();
}

class _AssetAssignedWidgetState extends State<AssetAssignedWidget> {
  final _riderAssetAcceptedProvider = StateNotifierProvider.autoDispose<
          RiderAssetAcceptedProvider, AsyncValue<RiderAssetModel>>(
      (_) => RiderAssetAcceptedProvider(const AsyncLoading()));

  @override
  void initState() {
    super.initState();
    _getRiderAssetAccepted();
  }

  DateFormatter? dateFormatter = DateFormatter();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      return watch(_riderAssetAcceptedProvider).when(
        data: (RiderAssetModel riderAsset) => _buildAssetList(riderAsset),
        loading: () => const FDCircularLoader(progressColor: Colors.white),
        error: (e, _) => FDErrorWidget(
          onPressed: _getRiderAssetAccepted,
          errorType: e,
        ),
      );
    });
  }

  Widget _buildAssetList(RiderAssetModel riderAsset) {
    if (riderAsset.riderAssetList.isEmpty) {
      return const Expanded(
        child: NoDataWidget(
          noDataText: 'No Asset Assigned',
        ),
      );
    }
    return Column(
      children: [
        const AssetTitle(isAssetList: true),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            itemCount: riderAsset.riderAssetList.length,
            itemBuilder: (_, int index) {
              final assetDetail = riderAsset.riderAssetList[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: dividerSetInCash.withOpacity(0.12),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                (assetDetail.name ?? '')
                                    .assetProductType()
                                    .svgImageAsset,
                              ),
                            ),
                          ),
                          sizedBoxW10,
                          Expanded(
                            child: Text(
                              assetDetail.name!,
                              textAlign: TextAlign.start,
                              style: commonTextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          assetDetail.quantity.toString(),
                          textAlign: TextAlign.center,
                          style: commonTextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        dateFormatter!.parseDateTimeToDate(
                          DateTime.parse(assetDetail.createdAt!),
                        ),
                        textAlign: TextAlign.right,
                        style: commonTextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => sizedBoxH5,
          ),
        ),
      ],
    );
  }

  Future _getRiderAssetAccepted() {
    return context
        .read(_riderAssetAcceptedProvider.notifier)
        .getRiderAcceptedAsset();
  }
}
