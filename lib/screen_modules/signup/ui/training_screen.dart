import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/training_list_model.dart';
import 'package:fraazo_delivery/providers/user/profile/training_list_provider.dart';
import 'package:fraazo_delivery/screen_modules/signup/ui/local_widgets/video_item_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_outline_button.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class TrainingScreen extends StatefulWidget {
  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _trainingListProvider = StateNotifierProvider.autoDispose<
          TrainingListProvider, AsyncValue<TrainingListModel>>(
      (_) => TrainingListProvider(const AsyncLoading()));
  final bool _isVerified = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTraining();
  }

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
        isShowBack: false,
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 28, //30
                  backgroundColor: Colors.white,
                  backgroundImage: Globals.user!.profilePic!.isNotEmpty
                      ? NetworkImage(Globals.user!.profilePic!)
                      : null,
                  child: Visibility(
                    visible: Globals.user!.profilePic!.isEmpty,
                    child: const Text(
                      "🧔🏻",
                      style: TextStyle(fontSize: 38),
                    ),
                  )),
              sizedBoxW10,
              TextView(
                  title:
                      "Hello ${Globals.user?.firstName} ${Globals.user?.lastName}",
                  textStyle: commonTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
          sizedBoxH15,
          TextView(
              title:
                  "Welcome to Fraazo, Complete the following steps to start getting orders.",
              textStyle: commonTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: lightBlackTxtColor,
              )),
          sizedBoxH15,
          Container(
            padding: const EdgeInsets.only(
                left: px_18, right: px_18, top: px_18, bottom: px_18),
            height: px_60,
            width: Get.width,
            decoration: const BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.all(
                Radius.circular(px_4),
              ),
            ),
            child: Row(children: [
              Expanded(
                child: TextView(
                    title: "Verification Status",
                    textStyle: commonTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
              // ignore: prefer_if_elements_to_conditional_expressions
              Globals.user!.isVerified
                  ? const NewPrimaryButton(
                      buttonTitle: 'Verified',
                      fontSize: px_10,
                      activeColor: buttonColor,
                      inactiveColor: buttonColor,
                      buttonRadius: px_4,
                    )
                  : const NewOutlineButton(
                      inactiveColor: Color(0xFF545454),
                      buttonRadius: px_4,
                      borderWidth: 0.5,
                      buttonTitle: 'Pending',
                      fontSize: px_10,
                      fontColor: lightBlackTxtColor,
                      activeColor: Color(0xFF545454),
                    )
            ]),
          ),
          sizedBoxH30,
          TextView(
              title: "Basic Training",
              textStyle: commonTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              )),
          sizedBoxH6,
          TextView(
              title:
                  "Before you start delivering the orders, please watch the basic training videos.",
              textStyle: commonTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: lightBlackTxtColor,
              )),
          sizedBoxH20,
          Container(
            height: px_150,
            width: Get.width,
            decoration: const BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.all(
                Radius.circular(px_8),
              ),
            ),
            child: Consumer(builder: (_, watch, __) {
              return watch(_trainingListProvider).when(
                data: (TrainingListModel trainingModel) {
                  final List<Training>? training = trainingModel.trainingList;
                  return _buildTrainingList(
                    training!,
                  );
                },
                loading: () => const FDCircularLoader(),
                error: (e, __) => FDErrorWidget(
                  onPressed: () {},
                ),
              );
            }),
          ),
          sizedBoxH20,
          TextView(
              title: "For more training videos visit our Training center",
              textStyle: commonTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: lightBlackTxtColor,
              )),
          sizedBoxH10,
          Container(
            padding: const EdgeInsets.only(
                left: px_14, right: px_8, top: px_8, bottom: px_8),
            height: px_50,
            width: Get.width,
            decoration: const BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.all(
                Radius.circular(px_4),
              ),
            ),
            child: Row(children: [
              Expanded(
                child: TextView(
                    title: "Training center",
                    textStyle: commonTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: px_20,
                  )),
            ]),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: px_30, top: px_40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: NewPrimaryButton(
                    activeColor: buttonColor,
                    inactiveColor: buttonInActiveColor,
                    buttonTitle: "Start Delivery",
                    buttonRadius: px_8,
                    fontInActiveColor: inActiveTextColor,
                    isActive: Globals.user!.isVerified,
                    onPressed: () {
                      RouteHelper.pushAndPopOthers(Routes.HOME);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrainingList(List<Training> training) {
    return ListView.builder(
        itemCount: training.length,
        itemBuilder: (_, int index) {
          return VideoItemWidget(
            training: training[index],
          );
        });
  }

  Future _getTraining() {
    return context.read(_trainingListProvider.notifier).getTrainingList();
  }
}
