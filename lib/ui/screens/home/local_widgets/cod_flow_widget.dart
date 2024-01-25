import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class CodFlowWidget extends StatefulWidget {
  final num orderSeqAmount;
  const CodFlowWidget(this.orderSeqAmount, {Key? key}) : super(key: key);

  @override
  State<CodFlowWidget> createState() => _CodFlowWidgetState();
}

class _CodFlowWidgetState extends State<CodFlowWidget> {
  final _cashTypeProvider = StateProvider<int>((ref) => 0);

  final List<int> _selectedCashType = [1, 2];
  int cashTypeId = -1;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.only(top: 30, bottom: 30, left: 16, right: 16),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xff302F2F),
                borderRadius: BorderRadius.circular(25.5),
              ),
              child: Text(
                //"Please Collect",
                "Please Collect ₹${widget.orderSeqAmount}",
                style: commonTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            sizedBoxH20,
            //const CodFlowButton(),
            _buildCodFlowButton(),
            sizedBoxH30,
            NewSlideButton(
              action: () {},
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
          ],
        ),
      ),
    );
  }

  Widget _buildCodFlowButton() {
    return Consumer(
      builder: (_, watch, __) {
        final cashType = watch(_cashTypeProvider);
        cashTypeId = cashType.state;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  context.read(_cashTypeProvider).state = _selectedCashType[0];
                  cashTypeId = _selectedCashType[0];
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                      color: (cashTypeId == _selectedCashType[0])
                          ? const Color.fromRGBO(38, 188, 38, 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (cashTypeId == _selectedCashType[0])
                            ? buttonColor
                            : const Color(0xffC2C2C2),
                      )),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.money),
                        Text(
                          "Full Cash Collected",
                          style: TextStyle(
                            color: Color(0xff4A4A4A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
            sizedBoxW10,
            Expanded(
              child: InkWell(
                onTap: () {
                  context.read(_cashTypeProvider).state = _selectedCashType[1];
                  cashTypeId = _selectedCashType[1];
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                      color: (cashTypeId == _selectedCashType[1])
                          ? const Color.fromRGBO(38, 188, 38, 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (cashTypeId == _selectedCashType[1])
                            ? buttonColor
                            : const Color(0xffC2C2C2),
                      )),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(Icons.qr_code_scanner),
                        Text(
                          "Generate QR",
                          style: TextStyle(
                            color: Color(0xff4A4A4A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
