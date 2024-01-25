import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class DeliveryPinOtp extends StatefulWidget {
  final Function(String otp) onOTPSent;
  const DeliveryPinOtp({required this.onOTPSent, Key? key}) : super(key: key);

  @override
  State<DeliveryPinOtp> createState() => _DeliveryPinOtpState();
}

class _DeliveryPinOtpState extends State<DeliveryPinOtp> {
  final _isOtpPinValidProvider = StateProvider.autoDispose((_) => false);
  final _otpPinTEC = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _otpPinTEC.addListener(() {
      context.read(_isOtpPinValidProvider.notifier).state =
          _otpPinTEC.isEqLength(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                "Enter Delivery PIN",
                style: commonPoppinsStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1F1F39)),
              ),
              sizedBoxH15,
              Text(
                "Delivery PIN is available in the User App",
                style: commonTextStyle(
                    fontSize: 13, color: const Color(0xff858597)),
              ),
              sizedBoxH20,
              _buildOTPPinField(),
              sizedBoxH20,
              Consumer(
                builder: (_, watch, __) {
                  final isValid = watch(_isOtpPinValidProvider).state;
                  return NewPrimaryButton(
                    isActive: isValid,
                    activeColor: buttonColor,
                    inactiveColor: buttonInActiveColor,
                    buttonTitle: "Submit",
                    buttonRadius: px_12,
                    fontSize: px_16,
                    onPressed: _onSubmitOTPTap,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPPinField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.60,
      child: PinCodeTextField(
        appContext: context,
        controller: _otpPinTEC,
        length: 4,
        cursorWidth: 1,
        autoFocus: true,
        cursorColor: Colors.white,
        textStyle: commonTextStyle(
            color: const Color(0xff2C2C2C),
            fontSize: tx_16,
            fontWeight: FontWeight.w600),
        animationType: AnimationType.fade,
        autoDisposeControllers: false,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.phone,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(px_5),
          fieldHeight: 52,
          fieldWidth: 47,
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
  }

  Future _onSubmitOTPTap() async {
    if (_otpPinTEC.isEqLength(4)) {
      widget.onOTPSent(_otpPinTEC.text);
    } else {
      Toast.normal("Please enter valid 4 digit OTP.");
    }
  }
}
