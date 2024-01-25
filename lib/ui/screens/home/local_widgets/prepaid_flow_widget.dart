import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class PrepaidFlowWidget extends StatefulWidget {
  const PrepaidFlowWidget({Key? key}) : super(key: key);

  @override
  State<PrepaidFlowWidget> createState() => _PrepaidFlowWidgetState();
}

class _PrepaidFlowWidgetState extends State<PrepaidFlowWidget> {
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
            Text(
              "Please select how you delivered the order ",
              style: commonTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            sizedBoxH20,
            //const PrepaidFlowButton(),
            _buildPrepaidFlowButton(),
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

  Widget _buildPrepaidFlowButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            // context.read(_cashTypeProvider).state = _selectedCashType[0];
            // cashTypeId = _selectedCashType[0];
          },
          child: Container(
            width: 100,
            padding:
                const EdgeInsets.only(left: 8, right: 10, top: 12, bottom: 12),
            decoration: BoxDecoration(
                // color: (cashTypeId == _selectedCashType[0])
                //     ? const Color.fromRGBO(38, 188, 38, 0.12)
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  // color: (cashTypeId == _selectedCashType[0])
                  //     ? buttonColor
                  color: const Color(0xffC2C2C2),
                )),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SvgPicture.asset(
                'handed_to_customer'.svgImageAsset,
              ),
              Text(
                "Handed to Customer",
                style: commonTextStyle(
                  fontSize: 11,
                ),
              ),
            ]),
          ),
        ),
        InkWell(
          onTap: () {
            // context.read(_cashTypeProvider).state = _selectedCashType[1];
            // cashTypeId = _selectedCashType[1];
          },
          child: Container(
            width: 100,
            padding:
                const EdgeInsets.only(left: 8, right: 10, top: 12, bottom: 12),
            decoration: BoxDecoration(
                // color: (cashTypeId == _selectedCashType[1])
                //     ? const Color.fromRGBO(38, 188, 38, 0.12)
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  //color: (cashTypeId == _selectedCashType[1])
                  //  ? buttonColor
                  color: const Color(0xffC2C2C2),
                )),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SvgPicture.asset(
                'handed_to_customer'.svgImageAsset,
              ),
              Text(
                "Handed to Security",
                style: commonTextStyle(
                  fontSize: 11,
                ),
              ),
            ]),
          ),
        ),
        InkWell(
          onTap: () {
            // context.read(_cashTypeProvider).state = _selectedCashType[1];
            // cashTypeId = _selectedCashType[1];
          },
          child: Container(
            width: 100,
            padding:
                const EdgeInsets.only(left: 8, right: 10, top: 12, bottom: 12),
            decoration: BoxDecoration(
                // color: (cashTypeId == _selectedCashType[1])
                //     ? const Color.fromRGBO(38, 188, 38, 0.12)
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  // color: (cashTypeId == _selectedCashType[1])
                  //     ? buttonColor
                  color: const Color(0xffC2C2C2),
                )),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SvgPicture.asset(
                'handed_to_customer'.svgImageAsset,
              ),
              Text(
                "Left at Society gate",
                style: commonTextStyle(
                  fontSize: 11,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
