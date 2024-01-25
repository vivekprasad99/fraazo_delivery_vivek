import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_helper.dart';
import 'package:fraazo_delivery/helpers/shared_pref/pref_keys.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/cash_or_qr_code_widget.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class CollectCashWidget extends StatefulWidget {
  final String collectedCash;
  final Function() onMarkDeliveredTap;
  final int tab;
  final Function() firstTabSelected;
  final Function() secondTabSelected;
  final OrderSeq orderSeq;

  const CollectCashWidget({
    Key? key,
    required this.collectedCash,
    required this.onMarkDeliveredTap,
    required this.tab,
    required this.firstTabSelected,
    required this.secondTabSelected,
    required this.orderSeq,
  }) : super(key: key);

  @override
  State<CollectCashWidget> createState() => _CollectCashWidgetState();
}

class _CollectCashWidgetState extends State<CollectCashWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: menuTitleColor,
            blurRadius: 6,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff302F2F),
              borderRadius: BorderRadius.circular(25.5),
            ),
            child: Text(
              //"Please Collect",
              "Please Collect ₹${widget.collectedCash}",
              style: commonTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          sizedBoxH12,
          Expanded(child: _buildCodFlowButton()),
          sizedBoxH12,
          NewSlideButton(
            action: () {
              if (widget.tab != -1) {
                widget.onMarkDeliveredTap.call();
              }
            },
            backgroundColor: buttonColor,
            height: 54,
            radius: 10,
            dismissible: false,
            label: Text(
              "Mark Delivered",
              style: commonTextStyle(
                fontSize: 15,
                color: textColor,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            alignLabel: const Alignment(0.1, 0),
          ),
          sizedBoxH5,
        ],
      ),
    );
  }

  Widget _buildCodFlowButton() {
    final orderProvider = context.read(orderUpdateProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              widget.firstTabSelected();
            },
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 12, bottom: 12),
              decoration: BoxDecoration(
                  // color: Colors.white,
                  color: (widget.tab == 0)
                      ? const Color.fromRGBO(38, 188, 38, 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (widget.tab == 0)
                        ? buttonColor
                        : const Color(0xffC2C2C2),
                  )),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.money),
                    Expanded(
                      child: Text(
                        "Partial Cash Collected",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: commonTextStyle(
                          color: cardLightBlack,
                          fontSize: 13,
                        ),
                        /*style: TextStyle(
                          color: Color(0xff4A4A4A),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),*/
                      ),
                    ),
                  ]),
            ),
          ),
        ),
        Visibility(
          visible: Globals.user!.qrEnable,
          child: Expanded(
            child: Row(
              children: [
                sizedBoxW10,
                InkWell(
                  onTap: () {
                    widget.secondTabSelected();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: (widget.tab == 1)
                          ? const Color.fromRGBO(38, 188, 38, 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (widget.tab == 1)
                            ? buttonColor
                            : const Color(0xffC2C2C2),
                      ),
                    ),
                    child: CashOrQrCodeWidget(
                      orderProvider.currentOrder,
                      amount: num.parse(widget.collectedCash),
                      onGenerateTap: () {
                        context
                            .read(orderUpdateProvider.notifier)
                            .endOrderDelivery(
                              PrefHelper.getInt(PrefKeys.CURRENT_TASK_ID) ?? 0,
                              orderSeq: widget.orderSeq,
                            );
                      },
                      shouldShowQRIcon: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
