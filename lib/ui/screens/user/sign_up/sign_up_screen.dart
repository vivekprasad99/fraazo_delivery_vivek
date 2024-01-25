import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/providers/user/login/signup_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/basic_user_details_widget.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);
  final _signupProvider =
      StateNotifierProvider.autoDispose((_) => SignupProvider());
  final _userDetailsProvider = StateProvider.autoDispose<User?>((_) => null);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: primaryBlackColor,
      appBar: const NewAppBar(
        isShowLogout: true,
        inPop: true,
      ),
      body: Container(
          padding: const EdgeInsets.only(left: px_24, right: px_24, top: px_24),
          height: Get.height,
          width: Get.width,
          decoration: const BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(px_16),
                  topRight: Radius.circular(px_16))),
          child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      //padding: padding15,
      child: Column(
        children: [
          BasicUserDetailsWidget(),
          sizedBoxH40,
          Consumer(
            builder: (_, watch, __) {
              final bool isValid = watch(_userDetailsProvider).state != null;
              //final signupAsyncValue = watch(_signupProvider);
              return NewPrimaryButton(
                isActive: isValid,
                activeColor: buttonColor,
                inactiveColor: buttonInActiveColor,
                buttonRadius: px_8,
                onPressed: isValid ? () => onSubmitTap(context) : null,
                //isLoading: signupAsyncValue is AsyncLoading,
                buttonTitle: "SUBMIT",
              );
            },
          ),
          sizedBoxH40,
        ],
      ),
    );
  }

  void onDetailsValidated(BuildContext context, User? user) {
    context.read(_userDetailsProvider).state = user;
  }

  void onSubmitTap(BuildContext context) {
    final User? user = context.read(_userDetailsProvider).state;
    if (user != null) {
      context.read(_signupProvider.notifier).signUpUser(user: user);
    }
  }
}
