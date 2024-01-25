import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/cash_deposit/unsettled_order_model.dart';
import 'package:fraazo_delivery/providers/cash_deposit/unsettled_order_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/delivery/cash_deposit/local_widgets/latest_transaction_widget.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/cash_settlement_code_dialog.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class FloatingCashScreen extends StatefulWidget {
  const FloatingCashScreen({Key? key}) : super(key: key);

  @override
  _FloatingCashScreenState createState() => _FloatingCashScreenState();
}

class _FloatingCashScreenState extends State<FloatingCashScreen> {
  final _settlementPinTEC = TextEditingController();
  final ValueNotifier<bool> _isHideButton = ValueNotifier(true);
  final ValueNotifier<bool> _isHideGenerateButton = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _getUnsettledOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const FDAppBar(
        backgroundColor: Colors.black,
        titleText: "Settle cash in hand",
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Divider(
          color: dividerSetInCash.withOpacity(0.4),
        ),
        sizedBoxH15,
        Center(
          child: Consumer(
            builder: (_, watch, __) => watch(unsettledOrderProvider).when(
              data: (UnsettledOrderModel unsettledOrder) {
                final bool isReachedMaxLimit =
                    unsettledOrder.amount >= unsettledOrder.limit;
                return Column(
                  children: [
                    /*Align(
                      alignment: FractionalOffset(
                          min(unsettledOrder.amount / unsettledOrder.limit,
                              1),
                          0),
                      child: Text(
                        "₹${unsettledOrder.amount}",
                        style: TextStyle(
                          color: isReachedMaxLimit
                              ? Colors.red
                              : AppColors.secondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),*/
                    _buildSettledCashOverLimit(
                      isReachedMaxLimit,
                      unsettledOrder: unsettledOrder,
                    ),
                    /*sizedBoxH10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "₹0",
                        ),
                        Text("Limit ₹${unsettledOrder.limit}")
                      ],
                    ),*/
                    const SizedBox(height: 25),
                    if ((unsettledOrder.amount) > 0)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'ic_emergency_home'.svgImageAsset,
                            ),
                            sizedBoxW10,
                            Expanded(
                              child: Text(
                                "Deposit Money before reaching to Max Limit(₹${unsettledOrder.limit}) or account will be blocked.",
                                style: commonTextStyle(
                                  lineHeight: 1.4,
                                ),
                                maxLines: 2,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const FDCircularLoader(),
              error: (_, __) => FDErrorWidget(
                onPressed: _getUnsettledOrderList,
                canShowImage: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 33),
        const Expanded(
          child: UPIHistoryWidget(
            isAllTransaction: false,
          ),
        )
      ],
    );
  }

  Widget _buildSettledCashOverLimit(
    bool isReachedMaxLimit, {
    required UnsettledOrderModel unsettledOrder,
  }) =>
      ValueListenableBuilder(
        valueListenable: _isHideButton,
        builder: (BuildContext context, value, Widget? child) {
          return ValueListenableBuilder(
            valueListenable: _isHideGenerateButton,
            builder: (BuildContext context, value, Widget? child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.fromLTRB(20, 14, 14, 15),
                decoration: const BoxDecoration(
                  color: cardLightBlack,
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "₹${unsettledOrder.amount}",
                          style: commonHindStyle(
                            color: isReachedMaxLimit
                                ? Colors.red
                                : Colors.white, //AppColors.secondary,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '/ ${unsettledOrder.limit} ',
                          style: commonHindStyle(
                            color: menuTitleColor,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "(Limit)",
                          style: commonHindStyle(
                            color: menuTitleColor,
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: _isHideButton.value,
                          child: NewPrimaryButton(
                            buttonHeight: 30,
                            //buttonWidth: MediaQuery.of(context).size.width * 0.2,
                            fontSize: 12,
                            activeColor: btnLightGreen,
                            inactiveColor: buttonInActiveColor,
                            buttonRadius: px_5,
                            buttonTitle:
                                _isHideGenerateButton.value ? 'Settle' : 'Done',
                            onPressed: () {
                              if (_isHideGenerateButton.value) {
                                _isHideButton.value = false;
                              } else {
                                _isHideButton.value = true;
                                _isHideGenerateButton.value = true;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    Visibility(
                      visible:
                          _isHideGenerateButton.value && !_isHideButton.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          NewPrimaryButton(
                            buttonHeight: 30,
                            //buttonWidth: MediaQuery.of(context).size.width * 0.2,
                            fontSize: 12,
                            activeColor: btnLightGreen,
                            inactiveColor: buttonInActiveColor,
                            buttonRadius: px_5,
                            buttonTitle: 'Generate Code',
                            onPressed: () {
                              _isHideGenerateButton.value = false;
                              _isHideButton.value = true;
                              _buildOTPPinField();
                            },
                          ),
                          Text(
                            "OR",
                            style: commonTextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          NewPrimaryButton(
                            buttonHeight: 30,
                            //buttonWidth: MediaQuery.of(context).size.width * 0.2,
                            fontSize: 12,
                            activeColor: btnLightGreen,
                            inactiveColor: buttonInActiveColor,
                            buttonRadius: px_5,
                            buttonTitle: 'Pay via UPI',
                            onPressed: _onPayViaUpi,
                          ),
                        ],
                      ),
                    ),
                    sizedBoxH15,
                    Visibility(
                        visible: !_isHideGenerateButton.value,
                        child: _buildOTPPinField()),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: LinearProgressIndicator(
                        backgroundColor: progressBackgroundSetInCash,
                        color: isReachedMaxLimit
                            ? Colors.red
                            : progressSettleInCash, //AppColors.primary,
                        minHeight: 7.0, //15.0,
                        value: unsettledOrder.amount / unsettledOrder.limit,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

  Future _onPayViaUpi() async {
    await RouteHelper.push(
      Routes.UNSETTLED_ORDER_PAYMENT,
    );
    _getUnsettledOrderList();
  }

  Widget _buildOTPPinField() {
    return Consumer(
      builder: (_, watch, __) {
        return watch(settlementCodeProvider).when(
          data: (String? code) {
            _settlementPinTEC.text = code!;
            return code.isNullOrEmpty
                ? Column(
                    children: [
                      Text(
                        "Settlement code is not generated.",
                        style:
                            commonTextStyle(fontSize: 15, color: Colors.white),
                      ),
                      sizedBoxH15
                    ],
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: PinCodeTextField(
                      appContext: context,
                      controller: _settlementPinTEC,
                      length: 6,
                      cursorWidth: 1,
                      autoFocus: true,
                      cursorColor: Colors.white,
                      textStyle: commonTextStyle(
                          color: Colors.white,
                          fontSize: tx_16,
                          fontWeight: FontWeight.w600),
                      animationType: AnimationType.fade,
                      autoDisposeControllers: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.phone,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(px_5),
                        fieldHeight: 50,
                        fieldWidth: 45,
                        borderWidth: 1,
                        activeColor: borderLineColor,
                        inactiveColor: borderLineColor,
                        selectedColor: borderLineColor,
                        inactiveFillColor: Colors.transparent,
                        activeFillColor: Colors.transparent,
                        selectedFillColor: Colors.transparent,
                      ),
                      animationDuration: const Duration(milliseconds: 200),
                      backgroundColor: Colors.transparent,
                      enableActiveFill: true,
                      //onCompleted: (_) => _onSubmitTap(),
                      //onSubmitted: (_) => _onSubmitTap(),
                      onChanged: (_) => {},
                    ),
                  );
          },
          loading: () => const FDCircularLoader(),
          error: (_, __) => FDErrorWidget(
            onPressed: () => context.refresh(settlementCodeProvider),
          ),
        );
      },
    );
  }

  Future _getUnsettledOrderList() {
    return context.read(unsettledOrderProvider.notifier).getUnsettledOrders();
  }
}
