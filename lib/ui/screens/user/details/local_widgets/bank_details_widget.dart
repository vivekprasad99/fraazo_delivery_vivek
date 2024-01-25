import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/user/bank_details_model.dart';
import 'package:fraazo_delivery/providers/user/details/bank_details_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/id_name_list_dialog.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';


class BankDetailsWidget extends StatefulWidget {
  @override
  _BankDetailsWidgetState createState() => _BankDetailsWidgetState();
}

class _BankDetailsWidgetState extends State<BankDetailsWidget> {
  final _bankDetailsSubmitProvider = StateProvider.autoDispose((_) => false);
  final _bankDetailsProvider = StateNotifierProvider.autoDispose<
      BankDetailsProvider,
      AsyncValue<BankDetails>>((_) => BankDetailsProvider());

  final /*_panTEC = TextEditingController(),*/
      _bankNameTEC = TextEditingController(),
      _accountNumberTEC = TextEditingController(),
      _ifscTEC = TextEditingController(),
      _recipientNameTEC = TextEditingController();

  late final RemoveListener _bankRemoveListener;
  String bankLogo = '';

  @override
  void initState() {
    super.initState();
    _getBankDetails();
    _fillFieldsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlackColor,
      appBar: const NewAppBar(
        isShowLogout: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: px_24, right: px_24, top: px_24),
        // height: Get.height,
        // width: Get.width,
        decoration: const BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(px_16),
                topRight: Radius.circular(px_16))),
        child: Consumer(builder: (_, watch, __) {
          return watch(_bankDetailsProvider).when(
            data: (BankDetails bankDetails) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextView(
                              title: 'Bank Details',
                              textStyle: commonTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(
                            height: 5,
                          ),
                          TextView(
                              title:
                                  'Your salary will be deposited to this account',
                              textStyle: commonTextStyle(
                                  fontSize: 14,
                                  color: lightBlackTxtColor,
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildBankDetails(bankDetails),
                          const SizedBox(
                            height: 25,
                          ),
                          TextView(
                              title:
                                  'Your Bank account will be verified with a transaction',
                              textStyle: commonTextStyle(
                                  fontSize: 13,
                                  color: lightBlackTxtColor,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                  ),
                  Consumer(
                    builder: (_, watch, __) {
                      final bool isBankVerified;
                      if (bankDetails.verificationStatus == "NOT_VERIFIED" ||
                          bankDetails.verificationStatus == "") {
                        isBankVerified = false;
                      } else {
                        isBankVerified = true;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: px_30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: NewPrimaryButton(
                                activeColor: buttonColor,
                                inactiveColor: buttonInActiveColor,
                                buttonTitle: "Continue & Verify",
                                buttonRadius: px_8,
                                isActive: !isBankVerified,
                                fontInActiveColor: inActiveTextColor,

                                // color: AppColors.secondary,
                                // isLoading:
                                //     watch(_bankDetailsSubmitProvider).state,
                                onPressed: _onSubmitButtonTap,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              );
            },
            loading: () => const FDCircularLoader(),
            error: (_, __) => FDErrorWidget(
              onPressed: _getBankDetails,
              canShowImage: false,
            ),
          );
        }),
      ),
    );
  }

  Future _openBanListSelectorDialog() async {
    final IdName? bankType = await showDialog(
      context: context,
      builder: (_) => const SelectorListDialog(
          type: "Bank Name", searchHit: 'Search Bank Name'),
    );
    if (bankType != null) {
      _bankNameTEC.text = bankType.name!;
      bankLogo = bankType.logo!;
      setState(() {});
    }
  }

  Widget _buildBankDetails(BankDetails bankDetails) {
    return Wrap(
      runSpacing: 15,
      children: [
        /* FDTextField(
          labelText: "PAN",
          controller: _panTEC,
          maxLength: 10,
          textCapitalization: TextCapitalization.characters,
        ),*/
        NewFDTextField(
          labelText: "Bank Name*",
          controller: _bankNameTEC,
          textCapitalization: TextCapitalization.words,
          fontSize: tx_14,
          showDropDownIcon: true,
          onTap: _openBanListSelectorDialog,
        ),
        NewFDTextField(
          labelText: "Account Holder Name*",
          controller: _recipientNameTEC,
          textCapitalization: TextCapitalization.words,
          fontSize: tx_14,
        ),
        NewFDTextField(
          labelText: "Account Number*",
          controller: _accountNumberTEC,
          isNumber: true,
          maxLength: 18,
          fontSize: tx_14,
        ),
        NewFDTextField(
          labelText: "IFSC*",
          controller: _ifscTEC,
          textCapitalization: TextCapitalization.characters,
          maxLength: 11,
          fontSize: tx_14,
        ),
        // Consumer(
        //   builder: (_, watch, __) {
        //     final bool isBankVerified;
        //     if (bankDetails.verificationStatus == "NOT_VERIFIED" ||
        //         bankDetails.verificationStatus == "") {
        //       isBankVerified = false;
        //     } else {
        //       isBankVerified = true;
        //     }
        //
        //     return Container(
        //       margin: const EdgeInsets.only(bottom: px_30),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Expanded(
        //             child: NewPrimaryButton(
        //               activeColor: buttonColor,
        //               inactiveColor: buttonInActiveColor,
        //               buttonTitle: "Continue & Verify",
        //               buttonRadius: px_8,
        //               isActive: !isBankVerified,
        //               fontInActiveColor: inActiveTextColor,
        //               // color: AppColors.secondary,
        //               // isLoading:
        //               //     watch(_bankDetailsSubmitProvider).state,
        //               onPressed: _onSubmitButtonTap,
        //             ),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // )
      ],
    );
  }

  void _getBankDetails() {
    context.read(_bankDetailsProvider.notifier).getRiderBankDetails();
  }

  void _fillFieldsData() {
    _bankRemoveListener =
        context.read(_bankDetailsProvider.notifier).addListener((asyncValue) {
      final BankDetails? bankDetails = asyncValue.data?.value;
      if (bankDetails != null) {
        // _panTEC.text = bankDetails.pan!;
        _bankNameTEC.text = bankDetails.bankName!;
        _accountNumberTEC.text = bankDetails.accountNumber ?? "";
        _ifscTEC.text = bankDetails.ifscCode!;
        _recipientNameTEC.text = bankDetails.recipientName!;
      }
    });
  }

  Future _onSubmitButtonTap() async {
    if (_isAllFieldsValid()) {
      context.read(_bankDetailsSubmitProvider).state = true;
      final bankDetails = BankDetails(
          // pan: _panTEC.trim,
          bankName: _bankNameTEC.trim,
          accountNumber: _accountNumberTEC.trim,
          ifscCode: _ifscTEC.trim,
          recipientName: _recipientNameTEC.trim);

      final bool isSuccess = await context
          .read(_bankDetailsProvider.notifier)
          .setRiderBankDetails(bankDetails);
      if (isSuccess) {
        await _onVerifyTap();
      }
      context.read(_bankDetailsSubmitProvider).state = false;
    } else {
      Toast.normal("Please fill all the details");
    }
  }

  bool _isAllFieldsValid() {
    if (/*_panTEC.isEmpty ||*/
        _bankNameTEC.isEmpty ||
            _accountNumberTEC.isEmpty ||
            _ifscTEC.isEmpty ||
            _recipientNameTEC.isEmpty) {
      return false;
    }
    return true;
  }

  Future _onVerifyTap() {
    return Toast.popupLoadingFuture(
      future: () =>
          context.read(_bankDetailsProvider.notifier).verifyBankDetails(),
      onSuccess: (dynamic response) {
        if (response is Map) {
          try {
            final String errorMsg = response['data']['data']['error'];
            Toast.info(errorMsg);
          } catch (e) {
            if (e is! DioError && e is! SocketException) {
              Toast.normal("Submitted successfully.");
            }
          }
        }
        _getBankDetails();
      },
    );
  }

  @override
  void dispose() {
    _bankRemoveListener();
    _bankNameTEC.dispose();
    _accountNumberTEC.dispose();
    _ifscTEC.dispose();
    _recipientNameTEC.dispose();
    super.dispose();
  }
}
