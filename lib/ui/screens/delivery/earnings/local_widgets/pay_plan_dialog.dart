import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/delivery/pay_plan_model.dart';
import 'package:fraazo_delivery/providers/delivery/earnings/pay_plan_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class PayPlanDialog extends StatefulWidget {
  const PayPlanDialog({Key? key}) : super(key: key);

  @override
  _PayPlanDialogState createState() => _PayPlanDialogState();
}

class _PayPlanDialogState extends State<PayPlanDialog> {
  final _payPlanProvider = StateNotifierProvider.autoDispose<PayPlanProvider,
      AsyncValue<PayPlanModel>>((_) => PayPlanProvider());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPayPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: textColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: padding8,
            child: Consumer(builder: (_, watch, __) {
              return watch(_payPlanProvider).when(
                data: (PayPlanModel payPlan) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 9,
                              child: Text(
                                '${payPlan.data!.headingTittle1}',
                                textAlign: TextAlign.center,
                                style: commonPoppinsStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  RouteHelper.pop();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: closeColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const ContainerDivider(
                        color: Color.fromRGBO(88, 88, 88, 0.27),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Column(
                          children: [
                            _buildPayOutData(
                                'Per Order Pay', payPlan.data!.perOrderPay!),
                            sizedBoxH10,
                            _buildPayOutData('Fuel Charges(After 5kms Extra)',
                                payPlan.data!.fuelChargesAfter5kmsExtra!),
                            sizedBoxH10,
                            _buildPayOutData('Shift login Pay',
                                payPlan.data!.shiftLoginPay!),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${payPlan.data!.headingTittle2}',
                          style: commonPoppinsStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                      const ContainerDivider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: payPlan.data!.objList!.length,
                        // padding: const EdgeInsets.all(16),
                        itemBuilder: (_, int index) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: _buildObjectItem(
                              payPlan.data!.objList![index].orderThreshold!,
                              payPlan.data!.objList![index].rate!),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const FDCircularLoader(
                  progressColor: bgColor,
                ),
                error: (e, _) => FDErrorWidget(
                  onPressed: _getPayPlan,
                  errorType: e,
                  textColor: bgColor,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectItem(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: commonTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '₹ $value',
          style: commonTextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: payValueColor),
        )
      ],
    );
  }

  Widget _buildPayOutData(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: commonTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '₹ $value',
          style: commonTextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: payValueColor),
        )
      ],
    );
  }

  Future _getPayPlan() {
    return context.read(_payPlanProvider.notifier).getPayoutStructure();
  }
}
