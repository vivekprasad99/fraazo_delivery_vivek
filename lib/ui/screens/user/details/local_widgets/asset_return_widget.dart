import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/asset_management/rider_asset_model.dart';
import 'package:fraazo_delivery/providers/asset_management/counter_increment_provider.dart';
import 'package:fraazo_delivery/providers/asset_management/rider_asset_accepted_provider.dart';
import 'package:fraazo_delivery/providers/asset_management/rider_asset_return_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screen_widgets/asset_title.dart';
import 'package:fraazo_delivery/ui/screen_widgets/no_data_widget.dart';
import 'package:fraazo_delivery/ui/screen_widgets/shadow_card.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class AssetReturnWidget extends StatefulWidget {
  const AssetReturnWidget({Key? key}) : super(key: key);

  @override
  _AssetReturnWidgetState createState() => _AssetReturnWidgetState();
}

class _AssetReturnWidgetState extends State<AssetReturnWidget> {
  final _riderAssetAcceptedProvider = StateNotifierProvider.autoDispose<
      RiderAssetAcceptedProvider, AsyncValue<RiderAssetModel>>(
    (_) => RiderAssetAcceptedProvider(const AsyncLoading()),
  );

  final _riderAssetReturnProvider = StateNotifierProvider(
    (_) => RiderAssetReturnProvider(const AsyncLoading()),
  );

  final counterProvider = ChangeNotifierProvider((ref) => CounterValue());

  final List<TextEditingController> _assetReturnTEC = [];
  late List<RiderAsset> assetList;
  List<Map<String, dynamic>> returnAsset = [];
  bool isReadOnly = true;
  late RiderAssetModel assetModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      _getRiderAssetReturn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_riderAssetAcceptedProvider).when(
          data: (RiderAssetModel riderAsset) => Column(
            children: [
              Expanded(child: _buildReturnDetails(riderAsset)),
              sizedBoxH5,
              Visibility(
                visible: riderAsset.riderAssetList.isNotEmpty,
                child: ShadowCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: NewPrimaryButton(
                      buttonHeight: MediaQuery.of(context).size.height * 0.065,
                      activeColor: btnLightGreen,
                      inactiveColor: buttonInActiveColor,
                      buttonRadius: px_8,
                      buttonTitle: 'Return',
                      onPressed: () => _onReturnTap(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const FDCircularLoader(progressColor: Colors.white),
          error: (e, _) => FDErrorWidget(
            onPressed: _getRiderAssetReturn,
            errorType: e,
          ),
        );
      },
    );
  }

  Future _onReturnTap() async {
    if (!(assetModel.returnRequest ?? true)) {
      returnAsset.clear();
      if (_assetReturnTEC.every((tec) => tec.text.isEmpty || tec.text == '0')) {
        Toast.info('Please enter atleast one value');
        return;
      }
      for (int i = 0; i < assetList.length; i++) {
        final int returnQuantity = _assetReturnTEC[i].text == ''
            ? 0
            : int.parse(_assetReturnTEC[i].text);
        if (returnQuantity <= assetList[i].quantity! &&
            returnQuantity > 0 &&
            !assetList[i].isReturn!) {
          returnAsset.add(
            {
              "asset_id": assetList[i].assetId!,
              "quantity": returnQuantity,
              "assigned_by": assetList[i].assignedBy,
            },
          );
          Toast.info("Return Request Successful");
          setState(() {
            _assetReturnTEC[i].clear();
          });
        } else if (returnQuantity >= assetList[i].quantity! &&
            returnQuantity != 0) {
          Toast.info("return Quantity is more");
          return;
        } else if (returnQuantity < 0) {
          Toast.info("return Quantity cannot be negative");
          return;
        }
      }
      await context
          .read(_riderAssetReturnProvider.notifier)
          .riderAssetReturn(returnAsset);
    } else {
      Toast.info("Previous return request is pending");
      return;
    }
    await context
        .read(_riderAssetAcceptedProvider.notifier)
        .getRiderAcceptedAsset();
  }

  Widget _buildReturnDetails(RiderAssetModel riderAsset) {
    if (riderAsset.riderAssetList.isEmpty) {
      return const NoDataWidget(
        noDataText: 'No asset assigned to return',
      );
    }
    return Consumer(
      builder: (_, watch, __) {
        final count = watch(counterProvider);
        return Column(
          children: [
            const AssetTitle(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                itemCount: riderAsset.riderAssetList.length,
                itemBuilder: (_, int index) {
                  assetModel = riderAsset;
                  assetList = riderAsset.riderAssetList;
                  final RiderAsset assetDetail =
                      riderAsset.riderAssetList[index];
                  _assetReturnTEC.add(TextEditingController());
                  _assetReturnTEC[index].text = assetList[index].isReturn!
                      ? assetDetail.returnQuantity.toString()
                      : count.getIndexValue == index
                          ? count.getRiderAssetDetail != null
                              ? count.getRiderAssetDetail!.changeQuantity
                                  .toString()
                              : '0'
                          : _assetReturnTEC[index].text.isEmpty
                              ? '0'
                              : _assetReturnTEC[index].text;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundColor:
                                  dividerSetInCash.withOpacity(0.12),
                              child: ClipOval(
                                child: SvgPicture.asset(
                                  (assetDetail.name ?? '')
                                      .assetProductType()
                                      .svgImageAsset,
                                ),
                              ),
                            ),
                            sizedBoxW10,
                            Text(
                              assetDetail.name ?? '',
                              textAlign: TextAlign.start,
                              style: commonTextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 29,
                              height: 29,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: lightBlackTxtColor,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.remove,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _getDecrementCounter(
                                    index,
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.110,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: borderLineColor,
                              ),
                              child: FDTextField(
                                //37,34
                                controller: _assetReturnTEC[index],
                                isNumber: true,
                                textStyle: commonTextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                isReadOnly: assetList[index].quantity == 0 ||
                                    assetList[index].isReturn!,
                              ),
                            ),
                            Container(
                              width: 29,
                              height: 29,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: lightBlackTxtColor,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.add,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _getIncrementCounter(
                                    index,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => sizedBoxH5,
              ),
            ),
          ],
        );
      },
    );
  }

  Future _getRiderAssetReturn() {
    return context
        .read(_riderAssetAcceptedProvider.notifier)
        .getRiderAcceptedAsset();
  }

  void _getIncrementCounter(int index) {
    if (int.parse(_assetReturnTEC[index].text) < assetList[index].quantity!) {
      context
          .read(counterProvider)
          .increment(index, assetList[index], _assetReturnTEC[index].text);
    } else {
      Toast.info("You can't enter more than the available quantity");
    }
  }

  void _getDecrementCounter(int index) {
    if (int.parse(_assetReturnTEC[index].text) > 0) {
      context
          .read(counterProvider)
          .decrement(index, assetList[index], _assetReturnTEC[index].text);
    } else {
      Toast.info("You can't enter less than 0");
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < assetList.length; i++) {
      _assetReturnTEC[i].dispose();
    }
    super.dispose();
  }
}
