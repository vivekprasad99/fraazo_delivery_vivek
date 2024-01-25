import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/return_inventory/return_inventory_model.dart';
import 'package:fraazo_delivery/providers/delivery/return_inventory_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class ReturnInventoryWidget extends StatefulWidget {
  const ReturnInventoryWidget({Key? key}) : super(key: key);

  @override
  _ReturnInventoryWidgetState createState() => _ReturnInventoryWidgetState();
}

class _ReturnInventoryWidgetState extends State<ReturnInventoryWidget> {
  final _returnInventoryProvider = StateNotifierProvider.autoDispose<
      ReturnInventoryProvider, AsyncValue<ReturnInventoryModel>>(
    (_) => ReturnInventoryProvider(const AsyncLoading()),
  );
  @override
  void initState() {
    super.initState();
    _getReturnInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer(
        builder: (_, watch, __) {
          return watch(_returnInventoryProvider).when(
            data: (ReturnInventoryModel returnInventoryModel) {
              return Column(
                children: [
                  Text(
                    returnInventoryModel.message ?? '',
                    textAlign: TextAlign.center,
                    style: commonTextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  sizedBoxH10,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContainerDivider(
                        color: const Color(0xffECECEC).withOpacity(0.2),
                      ),
                      sizedBoxH5,
                      ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: returnInventoryModel.data?.length ?? 0,
                          separatorBuilder: (_, __) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: ContainerDivider(
                                  color:
                                      const Color(0xffECECEC).withOpacity(0.2),
                                ),
                              ),
                          itemBuilder: (_, int index) {
                            final _returnInventoryData =
                                returnInventoryModel.data?[index];
                            return Column(
                              children: [
                                Text(
                                  "Order - ${_returnInventoryData!.orderNumber}",
                                  textAlign: TextAlign.center,
                                  style: commonTextStyle(
                                      fontSize: 16,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                                sizedBoxH10,
                                Text(
                                  _returnInventoryData.orderStatus ==
                                          'CANCELLED_BY_FRAAZO'
                                      ? 'CANCELLED'
                                      : 'RESCHEDULED',
                                  textAlign: TextAlign.center,
                                  style: commonTextStyle(
                                      fontSize: 16,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          }),
                      sizedBoxH5,
                      ContainerDivider(
                        color: const Color(0xffECECEC).withOpacity(0.2),
                      ),
                    ],
                  ),
                  sizedBoxH10,
                ],
              );
            },
            loading: () => const FDCircularLoader(),
            error: (e, _) => FDErrorWidget(
              onPressed: _getReturnInventory,
              errorType: e,
            ),
          );
        },
      ),
    );
  }

  Future _getReturnInventory() {
    return context
        .read(_returnInventoryProvider.notifier)
        .getReturnInventoryFetch();
  }
}
