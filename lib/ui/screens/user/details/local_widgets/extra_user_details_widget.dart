import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/user/profile/extra_user_details_model.dart';
import 'package:fraazo_delivery/providers/user/details/extra_user_details_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/flex_separated.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/id_name_list_dialog.dart';
import 'package:fraazo_delivery/ui/utils/app_colors.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class ExtraUserDetailsWidget extends StatefulWidget {
  const ExtraUserDetailsWidget({Key? key}) : super(key: key);
  @override
  _ExtraUserDetailsWidgetState createState() => _ExtraUserDetailsWidgetState();
}

class _ExtraUserDetailsWidgetState extends State<ExtraUserDetailsWidget> {
  final _extraUserDetailsProvider = StateNotifierProvider.autoDispose<
      ExtraUserDetailsProvider,
      AsyncValue<ExtraUserDetails>>((_) => ExtraUserDetailsProvider());
  final _extraDetailsSubmitProvider = StateProvider.autoDispose((_) => false);
  final _altMobileNoTEC = TextEditingController(),
      _emailTEC = TextEditingController(),
      _fatherNameTEC = TextEditingController(),
      _fatherMobileNoTEC = TextEditingController(),
      _addressTEC = TextEditingController(),
      _pincodeTEC = TextEditingController(),
      _vehicleTypeTEC = TextEditingController(),
      _vehicleNoTEC = TextEditingController(),
      _shiftTEC = TextEditingController(),
      _shiftTimingTEC = TextEditingController();
  String? _selectedMartialStatus = "single";
  IdName? _selectedBVehicleType;
  @override
  void initState() {
    super.initState();
    _getExtraDetails();
    context.read(_extraUserDetailsProvider.notifier).addListener((state) {
      if (state is AsyncData) {
        _setFields(state.data?.value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, watch, __) {
        return watch(_extraUserDetailsProvider).when(
          data: (ExtraUserDetails extraUserDetail) =>
              buildConsumer(extraUserDetail),
          loading: () => const FDCircularLoader(),
          error: (e, __) => FDErrorWidget(
            onPressed: _getExtraDetails,
            errorType: e,
          ),
        );
      },
    );
  }

  Widget buildConsumer(ExtraUserDetails extraUserDetail) {
    return FlexSeparated(
      direction: Axis.vertical,
      spacing: 15,
      children: [
        FDTextField(
          labelText: "Alternate Mobile No*",
          controller: _altMobileNoTEC,
          isNumber: true,
          maxLength: 10,
        ),
        FDTextField(
          labelText: "Email*",
          controller: _emailTEC,
          keyboardType: TextInputType.emailAddress,
        ),
        FDTextField(
          labelText: "Father Name",
          controller: _fatherNameTEC,
        ),
        FDTextField(
          labelText: "Father Mobile No",
          controller: _fatherMobileNoTEC,
          isNumber: true,
          maxLength: 10,
        ),
        buildMartialStatusRadio(),
        FDTextField(
          labelText: "Address*",
          controller: _addressTEC,
          keyboardType: TextInputType.streetAddress,
        ),
        FDTextField(
          labelText: "Pincode*",
          controller: _pincodeTEC,
          maxLength: 6,
          isNumber: true,
        ),
        FDTextField(
          labelText: "Vehicle Type*",
          controller: _vehicleTypeTEC,
          onTap: _openVehicleTypeSelectorDialog,
          isReadOnly: true,
        ),
        FDTextField(
          labelText: "Vehicle Number*",
          controller: _vehicleNoTEC,
        ),
        Consumer(builder: (_, watch, __) {
          return PrimaryButton(
            text: "Submit",
            color: AppColors.secondary,
            isLoading: watch(_extraDetailsSubmitProvider).state,
            onPressed:
                (Globals.user?.isVerified ?? false) ? null : _onSubmitButtonTap,
          );
        })
      ],
    );
  }

  Widget buildMartialStatusRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Martial Status",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile(
                value: "single",
                groupValue: _selectedMartialStatus,
                onChanged: _onMartialRadioTap,
                title: const Text("Single"),
                toggleable: false,
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile(
                value: "Married",
                groupValue: _selectedMartialStatus,
                onChanged: _onMartialRadioTap,
                title: const Text("Married"),
                dense: true,
              ),
            )
          ],
        ),
      ],
    );
  }

  void _onMartialRadioTap(String? value) {
    setState(() {
      _selectedMartialStatus = value;
    });
  }

  void _getExtraDetails() {
    context.read(_extraUserDetailsProvider.notifier).getExtraUserDetails();
  }

  void _setFields(ExtraUserDetails? extraUserDetails) {
    if (extraUserDetails != null) {
      _altMobileNoTEC.anyText = extraUserDetails.altMobile;
      _emailTEC.anyText = extraUserDetails.email;
      _fatherNameTEC.anyText = extraUserDetails.fatherName;
      _fatherMobileNoTEC.anyText = extraUserDetails.fatherNo;
      _addressTEC.anyText = extraUserDetails.address;
      _pincodeTEC.anyText =
          extraUserDetails.pincode == 0 ? "" : extraUserDetails.pincode;
      _vehicleTypeTEC.anyText = extraUserDetails.vehicleType;
      _vehicleNoTEC.anyText = extraUserDetails.vehicleNo;
      _selectedMartialStatus = extraUserDetails.martialStatus;
      _selectedBVehicleType = IdName(
        id: extraUserDetails.vehicleTypeId,
        name: extraUserDetails.vehicleType,
      );
    }
  }

  Future _openVehicleTypeSelectorDialog() async {
    final IdName? vehicleType = await showDialog(
      context: context,
      builder: (_) => const SelectorListDialog(
        type: "Vehicle Type",
      ),
    );
    if (vehicleType != null) {
      _selectedBVehicleType = vehicleType;
      _vehicleTypeTEC.text = vehicleType.name ?? "";
    }
  }

  Future _onSubmitButtonTap() async {
    if (areFieldsValid()) {
      context.read(_extraDetailsSubmitProvider).state = true;
      final extraUserDetails = _getExtraUserDetailsToSubmit();
      final bool isSuccess = await context
          .read(_extraUserDetailsProvider.notifier)
          .sendExtraUserDetails(extraUserDetails);
      if (isSuccess) {
        Toast.normal("Submitted successfully.");
      }
      context.read(_extraDetailsSubmitProvider).state = false;
    } else {
      Toast.normal("Please fill all required * fields.");
    }
  }

  bool areFieldsValid() {
    if (_altMobileNoTEC.isEmpty ||
        _emailTEC.isEmpty ||
        _addressTEC.isEmpty ||
        _pincodeTEC.isEmpty ||
        _vehicleTypeTEC.isEmpty ||
        _vehicleNoTEC.isEmpty) {
      return false;
    }
    return true;
  }

  ExtraUserDetails _getExtraUserDetailsToSubmit() {
    return ExtraUserDetails(
      altMobile: _altMobileNoTEC.trim,
      email: _emailTEC.trim,
      fatherName: _fatherNameTEC.trim,
      fatherNo: _fatherMobileNoTEC.trim,
      martialStatus: _selectedMartialStatus,
      address: _addressTEC.trim,
      pincode: int.parse(_pincodeTEC.trim),
      aadharCard: _addressTEC.trim,
      vehicleTypeId: _selectedBVehicleType?.id,
      vehicleNo: _vehicleNoTEC.trim,
    );
  }

  @override
  void dispose() {
    _altMobileNoTEC.dispose();
    _emailTEC.dispose();
    _fatherNameTEC.dispose();
    _fatherMobileNoTEC.dispose();
    _addressTEC.dispose();
    _pincodeTEC.dispose();
    _vehicleTypeTEC.dispose();
    _vehicleNoTEC.dispose();
    super.dispose();
  }
}
