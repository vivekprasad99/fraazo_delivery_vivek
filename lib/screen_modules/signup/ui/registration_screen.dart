import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/user/registration_list_model.dart';
import 'package:fraazo_delivery/models/user/testimonial_model.dart';
import 'package:fraazo_delivery/providers/user/login/registration_list_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/registration_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/home/local_widgets/new_terms_condition.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class RegistrationScreen extends StatefulWidget {
  final bool value;

  const RegistrationScreen({this.value = true, Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _registrationListProvider = StateNotifierProvider.autoDispose<
          RegistrationListProvider, AsyncValue<RegistrationListModel>>(
      (_) => RegistrationListProvider(const AsyncLoading()));

  final checkedProvider =
      ChangeNotifierProvider((ref) => RegistrationProvider());
  AutoDisposeFutureProvider? testimonialProvider;
  bool acceptTC = false;
  late List<bool> _isChecked;
  final List<String> _registrationData = [
    'Basic Details',
    'Documents',
    'Service Details',
    'Bank Details',
    'Set your password',
  ];

  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(_registrationData.length, false);
    if (!widget.value) {
      _registrationData[4] = 'Update your password';
    }
    _getRegistration();
    _getTestimonial();
  }

  void _getTestimonial() {
    testimonialProvider = FutureProvider.autoDispose(
      (ref) => ref.read(userProfileProvider.notifier).getTestimonialDetails(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    return Scaffold(
        backgroundColor: primaryBlackColor,
        appBar: NewAppBar(
          isShowLogout: widget.value,
          isShowBack: !widget.value,
        ),
        body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: !widget.value
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0))),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Visibility(
                  visible: widget.value,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: width * 0.061,
                        right: width * 0.061,
                        top: height * 0.030),
                    child: Column(
                      children: [
                        TextView(
                            title: 'Registration',
                            textStyle: commonTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        sizedBoxH5,
                        TextView(
                            title:
                                'Hello Partner, Please provide the required details',
                            textStyle: commonTextStyle(
                                fontSize: 14,
                                color: lightBlackTxtColor,
                                fontWeight: FontWeight.w400)),
                        sizedBoxH20,
                      ],
                    ),
                  ),
                ),
                Consumer(
                  builder: (_, watch, __) {
                    return watch(_registrationListProvider).when(
                      data: (RegistrationListModel registrationListModel) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _registrationData.length,
                          itemBuilder: (context, index) {
                            return _buildRegistrationDetailsList(
                                index, registrationListModel);
                          },
                          separatorBuilder: (_, __) => const ContainerDivider(),
                        );
                      },
                      loading: () => const FDCircularLoader(),
                      error: (e, __) => FDErrorWidget(
                        onPressed: _getRegistration,
                      ),
                    );
                  },
                ),
                sizedBoxH20,
                Consumer(
                  builder: (_, watch, __) {
                    return watch(testimonialProvider!).when(
                      data: (dynamic value) {
                        TestimonialModel testimonialModel = value;
                        return CarouselSlider(
                          options: CarouselOptions(
                              height: height * 0.198,
                              viewportFraction: 1,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5)),
                          items: testimonialModel.data?.map((element) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        width: width * 0.853,
                                        height: height * 0.198,
                                        color: const Color(0xFFD6517D),
                                        padding: EdgeInsets.only(
                                          left: width * 0.063,
                                          right: width * 0.152,
                                          top: height * 0.0396,
                                          bottom: height * 0.0665,
                                        ),
                                        child: TextView(
                                            title: element.textBody!,
                                            textStyle: commonTextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                      ),
                                    ),
                                    Positioned(
                                      top: height * 0.140,
                                      left: width * 0.063,
                                      child: TextView(
                                          title: element.name!,
                                          textStyle: commonTextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                    ),
                                    Positioned(
                                        right: width * 0.038,
                                        top: 25,
                                        bottom: 25,
                                        left: width * 0.730,
                                        child: Container(
                                          width: width * 0.336,
                                          height: height * 0.1459,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    element.image!
                                                            .startsWith('http')
                                                        ? element.image!
                                                        : "https://picsum.photos/200",
                                                  ))),
                                        ))
                                  ],
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const FDCircularLoader(
                        progressColor: Colors.white,
                      ),
                      error: (_, __) => FDErrorWidget(
                        onPressed: () => context.refresh(testimonialProvider!),
                      ),
                    );
                  },
                ),
                sizedBoxH20,
                if (widget.value) ...[
                  Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 24.0),
                    child: Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: isAllFilled
                                ? Colors.white
                                : buttonInActiveColor,
                          ),
                          child: Checkbox(
                            value: acceptTC,
                            activeColor: buttonColor,
                            checkColor: primaryBlackColor,
                            onChanged: (bool? value) => setState(() {
                              acceptTC = value!;
                            }),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: 'You agree to our ',
                                style: commonTextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: lightBlackTxtColor)),
                            TextSpan(
                                text: 'Terms & privacy policy',
                                recognizer: TapGestureRecognizer()
                                  ..onTap =
                                      () => _openTermsAndConditionsDialog(),
                                style: commonTextStyle(
                                    fontSize: 15, color: tcTxtColor)),
                          ])),
                        )
                      ],
                    ),
                  ),
                  sizedBoxH10,
                  Container(
                    padding: EdgeInsets.only(
                        left: width * 0.061, right: width * 0.061),
                    child: NewPrimaryButton(
                      activeColor: buttonColor,
                      inactiveColor: buttonInActiveColor,
                      buttonRadius: px_8,
                      buttonTitle: 'Submit for verification',
                      isActive: isAllFilled && acceptTC,
                      onPressed: _onAcceptTap,
                    ),
                  ),
                  sizedBoxH20,
                ],
              ],
            ),
          ),
        ));
  }

  bool isAllFilled = false;

  Widget _buildRegistrationDetailsList(
    int index,
    RegistrationListModel registrationListModel,
  ) {
    final bool? _isEnabled =
        _getRegistrationDoneInfo(index, registrationListModel);
    final bool? _isCheckedBox =
        _getCheckedBoxInfo(index, registrationListModel);
    isAllFilled = _getCheckedAllInfoFilled(registrationListModel);
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: buttonColor,
        disabledColor: (_isEnabled ?? true)
            ? ((_isCheckedBox ?? true) ? buttonColor : Colors.white)
            : buttonInActiveColor,
      ),
      child: InkWell(
        onTap: () {
          // Toast.normal(_registrationData[index]);
          if (_isEnabled ?? true) {
            pageNavigation(index);
          }
        },
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          checkColor: primaryBlackColor,
          tileColor: Colors.white,
          activeColor: buttonColor,
          title: TextView(
            title: _registrationData[index],
            textStyle: commonTextStyle(
              color: (_isEnabled ?? true) ? Colors.white : buttonInActiveColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          secondary: Icon(
            (_isEnabled ?? true) ? Icons.arrow_forward_rounded : Icons.lock,
            color: (_isEnabled ?? true) ? Colors.white : buttonInActiveColor,
            size: 20,
          ),
          value: _isCheckedBox,
          onChanged: null,
        ),
      ),
    );
  }

  Future _openTermsAndConditionsDialog() {
    return showDialog(
      context: context,
      builder: (_) => const NewTermsAndConditionsScreen(),
    );
  }

  void pageNavigation(int index) async {
    switch (index) {
      case 0:
        await RouteHelper.push(Routes.BASIC_DETAILS);
        _getRegistration();
        break;
      case 1:
        await RouteHelper.push(Routes.DOCUMENT_DETAILS);
        _getRegistration();
        break;
      case 2:
        await RouteHelper.push(Routes.SERVICE_DETAILS);
        _getRegistration();
        break;
      case 3:
        await RouteHelper.push(Routes.BANK_DETAILS);
        _getRegistration();
        break;
      case 4:
        if (widget.value) {
          await RouteHelper.push(Routes.SET_PASSWORD_SCREEN);
        } else {
          await RouteHelper.push(Routes.PASSWORD_RESET,
              args: Globals.user!.mobile);
        }

        _getRegistration();
        break;
    }
  }

  bool? _getRegistrationDoneInfo(
    int index,
    RegistrationListModel registrationListModel,
  ) {
    switch (index) {
      case 1:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.basicInfoFlag;
      case 2:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.documentFlag;
      case 3:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.serviceInfoFlag;
      case 4:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.bankDetailsVerifiedFlag;
    }
    return true;
  }

  bool? _getCheckedBoxInfo(
    int index,
    RegistrationListModel registrationListModel,
  ) {
    switch (index) {
      case 0:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.basicInfoFlag;
      case 1:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.documentFlag;
      case 2:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.serviceInfoFlag;
      case 3:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.bankDetailsVerifiedFlag;
      case 4:
        return Globals.user!.isVerified
            ? true
            : registrationListModel.data!.passwordVerified;
    }
    return true;
  }

  void _onAcceptTap() {
    Toast.popupLoadingFuture(
      future: () => context.read(userProfileProvider.notifier).acceptTNC(),
      onSuccess: (_) =>
          RouteHelper.pushAndPopOthers(Routes.SUCCESSFUL_REGISTRATION_SCREEN),
    );
  }

  bool _getCheckedAllInfoFilled(RegistrationListModel registrationListModel) {
    if (registrationListModel.data!.basicInfoFlag! &&
        registrationListModel.data!.documentVerified! &&
        registrationListModel.data!.serviceInfoFlag! &&
        registrationListModel.data!.bankDetailsVerifiedFlag! &&
        registrationListModel.data!.passwordVerified!) {
      return true;
    } else {
      return false;
    }
  }

  Future _getRegistration() {
    return context
        .read(_registrationListProvider.notifier)
        .getRegistrationListApiFetch();
  }
}
