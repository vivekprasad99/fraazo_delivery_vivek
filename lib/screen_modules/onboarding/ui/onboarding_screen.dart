import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/base_directory/base_get_state.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/models/user/landing_page_model.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_outline_button.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../helpers/route/route_helper.dart';
import '../../../helpers/route/routes.dart';
import '../../../ui/utils/widgets_and_attributes.dart';
import '../../../values/custom_colors.dart';
import '../controller/onboarding_controller.dart';

class OnBoardingScreen extends StatefulWidget {
  final LandingPageModel landingPageModel;
  const OnBoardingScreen({Key? key, required this.landingPageModel})
      : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends BaseGetState<OnBoardingScreen> {
  final controller = PageController();

  final pages = List.generate(
    3,
    (index) => Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SvgPicture.asset('ill_1'.svgImageAsset),
      ],
    ),
  );
  OnBoardingController boardingController = Get.put(OnBoardingController());

  @override
  Widget getBuildWidget(BuildContext context) {
    return Obx(() {
      return Container(
        color: primaryBlackColor,
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlackColor, gradientBlackColor],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
                child: PageView.builder(
                  controller: controller,
                  itemCount: widget.landingPageModel.data!.length,
                  itemBuilder: (_, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image(
                            image: NetworkImage(
                              widget.landingPageModel.data![index].imageUrl!,
                            ),
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        )
                        // SvgPicture.asset('ill_1'.svgImageAsset),
                      ],
                    );
                  },
                  onPageChanged: (index) {
                    print('onPageChanged $index');
                    boardingController.currentIndex.value = index;
                    // boardingController.currentIndex.value = index;
                    if (index == widget.landingPageModel.data!.length - 1) {
                      boardingController.isLastPage.value = true;
                    } else {
                      boardingController.isLastPage.value = false;
                    }
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    TextView(
                      title: widget.landingPageModel
                          .data![boardingController.currentIndex.value].text!,
                      alignment: Alignment.center,
                      textStyle: commonTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: pages.length,
                        effect: const ScaleEffect(
                          dotHeight: 5,
                          dotWidth: 5,
                          activeStrokeWidth: 5.0,
                          dotColor: Colors.white,
                          paintStyle: PaintingStyle.stroke,
                          activeDotColor: Colors.white,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: boardingController.isLastPage.value,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            NewPrimaryButton(
                              activeColor: buttonColor,
                              inactiveColor: buttonColor,
                              buttonRadius: px_8,
                              buttonHeight: 45,
                              buttonWidth: Get.width,
                              buttonTitle: 'Register Now',
                              onPressed: () {
                                RouteHelper.push(Routes.SIGN_UP);
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            NewOutlineButton(
                              activeColor: buttonColor,
                              inactiveColor: Colors.transparent,
                              buttonRadius: px_8,
                              buttonHeight: 45,
                              borderWidth: 1,
                              // borderColor: buttonColor,
                              buttonWidth: Get.width,
                              buttonTitle: 'Login',
                              onPressed: () {
                                RouteHelper.push(Routes.LOGIN);
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                //color: primaryBlackColor,
              ),
            )
          ],
        ),
      );
    });
  }

  @override
  void onScreenReady(BuildContext context) {
    // TODO: implement onScreenReady
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  PreferredSizeWidget? getToolBar(BuildContext context) {
    // TODO: implement getToolBar
    return null;
  }

  @override
  Widget? getFloatingButton(BuildContext context) {
    // TODO: implement getFloatingButton
    return Obx(() {
      return Visibility(
        visible: !boardingController.isLastPage.value,
        child: MaterialButton(
          onPressed: () {
            if (boardingController.currentIndex.value !=
                widget.landingPageModel.data!.length - 1) {
              boardingController.currentIndex.value++;
            }
            controller.animateToPage(boardingController.currentIndex.value,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutSine);
          },
          shape: const CircleBorder(),
          color: buttonColor,
          height: 55,
          elevation: 2,
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}
