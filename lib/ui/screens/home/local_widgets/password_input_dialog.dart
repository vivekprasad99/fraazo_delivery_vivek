import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/primary_button.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';

class PasswordInputDialog extends StatefulWidget {
  const PasswordInputDialog({Key? key}) : super(key: key);

  @override
  _PasswordInputDialogState createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<PasswordInputDialog> {
  final _passwordTEC = TextEditingController(),
      _confirmPasswordTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: AlertDialog(
        title: const FittedBox(
          child: Text(
            "Please enter new 6-digit password",
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "This password is used for login in case of OTP issue.",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              sizedBoxH10,
              FDTextField(
                controller: _passwordTEC,
                labelText: "Enter 6-digit Password*",
                maxLength: 6,
                shouldHideText: true,
                spacing: 2,
              ),
              sizedBoxH15,
              FDTextField(
                controller: _confirmPasswordTEC,
                labelText: "Confirm 6-digit Password*",
                maxLength: 6,
                shouldHideText: true,
                spacing: 2,
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
        actions: [
          PrimaryButton(
            onPressed: _onSubmitTap,
            text: "Submit",
            width: 100,
            height: 35,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Future _onSubmitTap() async {
    if (_passwordTEC.isEqLength(6) &&
        _confirmPasswordTEC.isEqLength(6) &&
        _passwordTEC.trim == _confirmPasswordTEC.trim) {
      Toast.popupLoadingFuture(
        future: () => context
            .read(userProfileProvider.notifier)
            .setPassword(_passwordTEC.trim),
        onSuccess: (_) {
          Toast.normal("Great! Now you can login using this password also.");
          RouteHelper.pop();
        },
      );
    } else {
      Toast.normal(
          "Password and Confirm password must be same and 6-digit long.");
    }
  }

  Future<bool> _onBackPressed() {
    Toast.normal("Please enter password to proceed.");
    return Future.value(false);
  }

  @override
  void dispose() {
    _passwordTEC.dispose();
    _confirmPasswordTEC.dispose();
    super.dispose();
  }
}
