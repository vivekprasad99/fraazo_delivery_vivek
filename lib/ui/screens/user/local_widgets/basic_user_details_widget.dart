import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/extensions/text_editing_controller_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/user/basic_details.dart';
import 'package:fraazo_delivery/models/user/profile/user_model.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_dropdown.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/id_name_list_dialog.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/profile_pic_widget.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/enums.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class BasicUserDetailsWidget extends StatefulWidget {
  final User? user;

  const BasicUserDetailsWidget({Key? key, this.user}) : super(key: key);

  @override
  _BasicUserDetailsWidgetState createState() => _BasicUserDetailsWidgetState();
}

class _BasicUserDetailsWidgetState extends State<BasicUserDetailsWidget> {
  final _firstNameTEC = TextEditingController(text: Globals.user?.firstName),
      _lastNameTEC = TextEditingController(text: Globals.user?.lastName),
      _mobileNoTEC = TextEditingController(text: Globals.user?.mobile),
      _alternatemobileNoTEC = TextEditingController(text: Globals.user?.mobile),
      _cityTEC = TextEditingController(text: Globals.user?.city);

  final _presentAddressTEC = TextEditingController(),
      _pincodeTEC = TextEditingController(),
      _contactNameTEC = TextEditingController(),
      _contactNumberTEC = TextEditingController(),
      _relationTEC = TextEditingController();
  final _basicInfoSubmitProvider = StateProvider.autoDispose((_) => false);

  late IdName? _selectedCity = null;
  final selectedAvatarIndex = StateProvider.autoDispose((_) => -1);
  final profileImage = StateProvider.autoDispose((_) => '');
  final genderSelectionProvider = StateProvider.autoDispose((_) => Gender.MALE);
  AutoDisposeFutureProvider? basicDetailsProvider;

  bool _isSignUp = false;
  late Gender _gender;
  AutoDisposeFutureProvider? avatarProvider;
  int selectedIndex = 0;
  AsyncData? basicDetails;
  bool isAllFilled = false, isLoading = false;
  final buttonEnableDisable = StateProvider.autoDispose((_) => false);
  String selectMaritalStatus = 'Single';
  String noChild = '0';

  String imagePath = '';
  @override
  void initState() {
    super.initState();
    _isSignUp = Globals.user!.isVerified;

    getBasicInfo();

    _firstNameTEC.addListener(_onTextChangeListener);
    _lastNameTEC.addListener(_onTextChangeListener);
    _mobileNoTEC.addListener(_onTextChangeListener);

    _alternatemobileNoTEC.addListener(_onTextChangeListener);
    _cityTEC.addListener(_onTextChangeListener);

    _presentAddressTEC.addListener(_onTextChangeListener);
    _pincodeTEC.addListener(_onTextChangeListener);
    _contactNameTEC.addListener(_onTextChangeListener);

    _contactNumberTEC.addListener(_onTextChangeListener);
    _relationTEC.addListener(_onTextChangeListener);
  }

  void _getUpdatedProfileAvatar(String avatarType) async {
    avatarProvider = FutureProvider.autoDispose(
      (ref) =>
          ref.read(userProfileProvider.notifier).getProfileAvatar(avatarType),
    );
  }

  void getBasicInfo() {
    basicDetailsProvider = FutureProvider.autoDispose(
      (ref) => ref.read(userProfileProvider.notifier).getBasicDetails(),
    );
    context
        .read(basicDetailsProvider!.future)
        .then((value) => _setFields(value));
  }

  void _setFields(BasicDetails value) {
    //print('_setFields $value');
    _firstNameTEC.text = value.data.firstName;
    _lastNameTEC.text = value.data.lastName;
    _mobileNoTEC.text = value.data.mobile;
    _alternatemobileNoTEC.text = value.data.altMobile;
    _gender = value.data.gender.isNotEmpty
        ? value.data.gender == 'Male'.toUpperCase()
            ? Gender.MALE
            : Gender.FEMALE
        : Gender.MALE;
    context.read(genderSelectionProvider).state = _gender;
    _getUpdatedProfileAvatar(
        _gender == Gender.MALE ? 'male_avatar' : 'female_avatar');

    selectMaritalStatus = value.data.martialStatus.isNotEmpty
        ? value.data.martialStatus.capitalizeOnlyFirstLater
        : 'Single';
    noChild = value.data.noOfChildren.toString();
    selectedIndex = value.data.avatarId;
    _contactNumberTEC.text = value.data.contactNumber;
    _contactNameTEC.text = value.data.contactName;
    _relationTEC.text = value.data.relation;
    _pincodeTEC.text = value.data.pincode.toString();
    _cityTEC.text = value.data.city;
    _presentAddressTEC.text = value.data.address;
    context.read(selectedAvatarIndex).state = selectedIndex;
    context.read(profileImage).state = value.data.link;
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
            topRight: Radius.circular(px_16),
          ),
        ),
        child: SingleChildScrollView(
          child: Consumer(
            builder: (BuildContext context,
                T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
              selectedIndex = watch(selectedAvatarIndex).state;
              isAllFilled = watch(buttonEnableDisable).state;
              imagePath = watch(profileImage).state;
              _gender = watch(genderSelectionProvider).state;
              isLoading = watch(_basicInfoSubmitProvider).state;
              basicDetails =
                  basicDetails ?? watch(basicDetailsProvider!).data?.data;
              if (basicDetails != null) {
                return _setBasicInfoView();
              } else {
                return SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: const FDCircularLoader(),
                );
              }
              // watch(basicDetailsProvider!).when(
              //   data: (dynamic basicDetails) {
              //     return
              //       ;
              //   },
              //   loading: () => const FDCircularLoader(
              //         progressBarColor: Colors.white,
              //       ),
              //   error: (e, _) => FDErrorWidget(
              //         onPressed: () {
              //           _getUserProfileAvatar('male_avatar');
              //         },
              //         errorType: e,
              //       ));
            },
          ),
        ),
      ),
    );
  }

  void _onTextChangeListener() {
    if (_firstNameTEC.isNotEmpty &&
        _lastNameTEC.isNotEmpty &&
        _mobileNoTEC.isEqLength(10) &&
        _alternatemobileNoTEC.isEqLength(10) &&
        selectedIndex > -1 &&
        _presentAddressTEC.isNotEmpty &&
        _cityTEC.isNotEmpty &&
        _pincodeTEC.isEqLength(6) &&
        _contactNumberTEC.isEqLength(10) &&
        _contactNameTEC.isNotEmpty &&
        _relationTEC.isNotEmpty &&
        imagePath.isNotEmpty) {
      context.read(buttonEnableDisable).state = true;
    } else {
      context.read(buttonEnableDisable).state = false;
    }
  }

  Future _openCitySelectorDialog() async {
    final IdName? city = await showDialog(
      context: context,
      builder: (_) => const SelectorListDialog(
        type: "City",
      ),
    );
    if (city != null) {
      _selectedCity = city;
      _cityTEC.text = city.name ?? "";
    }
  }

  Future _openRelationSelectorDialog() async {
    final IdName? releation = await showDialog(
      context: context,
      builder: (_) => const SelectorListDialog(
        type: "Relation",
      ),
    );
    if (releation != null) {
      _relationTEC.text = releation.name ?? "";
    }
  }

  Widget _setBasicInfoView() {
    return Column(
      children: [
        TextView(
            title: "Basic Details",
            textStyle: commonTextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        sizedBoxH6,
        TextView(
            title: "Please fill the required details",
            textStyle: commonTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: lightBlackTxtColor)),
        sizedBoxH30,
        NewFDTextField(
          controller: _firstNameTEC,
          labelText: "First Name *",
        ),
        sizedBoxH18,
        NewFDTextField(
          controller: _lastNameTEC,
          labelText: "Last Name *",
        ),
        sizedBoxH18,
        Row(
          children: [
            Expanded(
              child: NewFDTextField(
                controller: _mobileNoTEC,
                labelText: "Mobile Number *",
                isReadOnly: true,
                isNumber: true,
              ),
            ),
            sizedBoxW15,
            Expanded(
              child: NewFDTextField(
                controller: _alternatemobileNoTEC,
                labelText: "Alternate Number *",
                maxLength: 10,
                isNumber: true,
              ),
            ),
          ],
        ),
        sizedBoxH18,
        Column(
          children: [
            TextView(
                title: "Gender *",
                textStyle: commonTextStyle(
                    fontSize: 12,
                    color: lightBlackTxtColor,
                    fontWeight: FontWeight.w400)),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read(genderSelectionProvider).state = Gender.MALE;
                      _getUpdatedProfileAvatar('male_avatar');
                    },
                    child: Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.grey[600],
                          ),
                          child: Radio(
                              value: Gender.MALE,
                              groupValue: _gender,
                              activeColor: Colors.white,
                              onChanged: (Gender? value) {
                                context.read(genderSelectionProvider).state =
                                    Gender.MALE;
                                _getUpdatedProfileAvatar('male_avatar');
                              }),
                        ),
                        Expanded(
                          child: TextView(
                            title: 'Male',
                            textStyle: commonTextStyle(
                                fontSize: 15,
                                color: _gender == Gender.MALE
                                    ? Colors.white
                                    : inActiveTextColor),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.read(genderSelectionProvider).state =
                          Gender.FEMALE;
                      _getUpdatedProfileAvatar('female_avatar');
                    },
                    child: Row(
                      children: [
                        Theme(
                          data: ThemeData(
                              unselectedWidgetColor: Colors.grey[600]),
                          child: Radio(
                              value: Gender.FEMALE,
                              groupValue: _gender,
                              activeColor: Colors.white,
                              onChanged: (Gender? value) {
                                context.read(genderSelectionProvider).state =
                                    Gender.FEMALE;
                                _getUpdatedProfileAvatar('female_avatar');
                              }),
                        ),
                        Expanded(
                          child: TextView(
                            title: 'Female',
                            textStyle: commonTextStyle(
                                fontSize: 15,
                                color: _gender == Gender.FEMALE
                                    ? Colors.white
                                    : inActiveTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            sizedBoxH10,
            TextView(
                title: 'Pick your Avatar',
                textStyle: commonTextStyle(
                    fontSize: 12,
                    color: lightBlackTxtColor,
                    fontWeight: FontWeight.w400)),
            sizedBoxH10,
            SizedBox(
              height: px_60,
              child: Consumer(
                builder: (_, watch, __) {
                  return watch(avatarProvider!).when(
                    data: (dynamic value) {
                      List<IdName> avatarList = value;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            height: px_60,
                            width: px_60,
                            margin: const EdgeInsets.only(right: px_26),
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.read(selectedAvatarIndex).state =
                                        avatarList[index].id!;
                                  },
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: avatarList[index].name!,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    ),

                                    //  Image(
                                    //   image:
                                    //       NetworkImage(avatarList[index].name!),
                                    //   fit: BoxFit.fill,
                                    //   loadingBuilder: (BuildContext context,
                                    //       Widget child,
                                    //       ImageChunkEvent? loadingProgress) {
                                    //     if (loadingProgress == null) {
                                    //       return child;
                                    //     }
                                    //     return const Center(
                                    //       child: CircularProgressIndicator(
                                    //           color: Colors.white),
                                    //     );
                                    //   },
                                    // ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      selectedIndex == avatarList[index].id,
                                  child: Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: SvgPicture.asset(
                                        'check'.svgImageAsset,
                                      )),
                                )
                              ],
                            ),
                          );
                        },
                        itemCount: avatarList.length,
                      );
                    },
                    loading: () => const FDCircularLoader(),
                    error: (_, __) => FDErrorWidget(
                      onPressed: () => context.refresh(avatarProvider!),
                    ),
                  );
                },
              ),
            )
          ],
        ),
        sizedBoxH18,
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  NewFDDropDown(
                    labelText: "Marital Status *",
                    defaultValue: selectMaritalStatus,
                    dropDownValue: const [
                      'Single',
                      'Married',
                      'Widowed',
                      'Separated',
                      'Divorced'
                    ],
                    fontSize: tx_14,
                    showDropDownIcon: true,
                    onSelect: (String value) {
                      selectMaritalStatus = value;
                    },
                  ),
                ],
              ),
            ),
            sizedBoxW15,
            Expanded(
              child: NewFDDropDown(
                labelText: "No of Children *",
                fontSize: tx_14,
                showDropDownIcon: true,
                defaultValue: noChild,
                dropDownValue: const ['0', '1', '2', '3', '4', '5'],
                onSelect: (String value) {
                  noChild = value;
                },
              ),
            ),
          ],
        ),
        sizedBoxH18,
        NewFDTextField(
          controller: _presentAddressTEC,
          labelText: "Present Address *",
        ),
        sizedBoxH18,
        Row(
          children: [
            Expanded(
              child: NewFDTextField(
                labelText: "City *",
                controller: _cityTEC,
                textCapitalization: TextCapitalization.words,
                fontSize: tx_14,
                showDropDownIcon: true,
                onTap: _openCitySelectorDialog,
                isReadOnly: true,
              ),
            ),
            sizedBoxW15,
            Expanded(
              child: NewFDTextField(
                labelText: "Pincode *",
                controller: _pincodeTEC,
                fontSize: tx_14,
                maxLength: 6,
                isNumber: true,
                showDropDownIcon: false,
              ),
            ),
          ],
        ),
        sizedBoxH18,
        Column(
          children: [
            TextView(
                title: "Photos *",
                textStyle: commonTextStyle(
                    color: lightBlackTxtColor, fontWeight: FontWeight.w400)),
            sizedBoxH5,
            ProfilePicWidget(imagePath, updateProfilePic),
          ],
        ),
        sizedBoxH18,
        const Divider(
          color: borderLineColor,
        ),
        sizedBoxH10,
        TextView(
            title: "Emergency Contact",
            textStyle: commonTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        sizedBoxH10,
        TextView(
            title:
                "Add the details of the person to be contacted in case of any Emergency ",
            textStyle: commonTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: lightBlackTxtColor)),
        sizedBoxH10,
        NewFDTextField(
          controller: _contactNameTEC,
          labelText: "Contact Name *",
        ),
        sizedBoxH18,
        Row(
          children: [
            Expanded(
              child: NewFDTextField(
                labelText: "Contact Number *",
                controller: _contactNumberTEC,
                isNumber: true,
                maxLength: 10,
              ),
            ),
            sizedBoxW15,
            Expanded(
              child: NewFDTextField(
                labelText: "Relation *",
                controller: _relationTEC,
                textCapitalization: TextCapitalization.words,
                fontSize: tx_14,
                showDropDownIcon: true,
                isReadOnly: true,
                onTap: _openRelationSelectorDialog,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(bottom: px_30, top: px_50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: NewPrimaryButton(
                  activeColor: buttonColor,
                  inactiveColor: buttonInActiveColor,
                  buttonTitle: "Continue & Verify",
                  buttonRadius: px_8,
                  isActive: !_isSignUp && isAllFilled,
                  fontInActiveColor: inActiveTextColor,
                  isLoading: isLoading,
                  // color: AppColors.secondary,
                  // isLoading:
                  //     watch(_bankDetailsSubmitProvider).state,
                  onPressed: () {
                    submitBasicInfo();
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void submitBasicInfo() async {
    context.read(_basicInfoSubmitProvider).state = true;
    final Data basicDetails = Data(
        firstName: _firstNameTEC.text,
        lastName: _lastNameTEC.text,
        mobile: _mobileNoTEC.text,
        altMobile: _alternatemobileNoTEC.text,
        gender: _gender.name,
        avatarId: selectedIndex,
        martialStatus: selectMaritalStatus,
        noOfChildren: int.parse(noChild),
        address: _presentAddressTEC.text,
        city: _cityTEC.text,
        pincode: int.parse(_pincodeTEC.text),
        link: imagePath,
        contactName: _contactNameTEC.text,
        contactNumber: _contactNumberTEC.text,
        relation: _relationTEC.text);
    final bool isSuccess = await context
        .read(userProfileProvider.notifier)
        .saveBasicInfo(basicDetails);
    if (isSuccess) {
      Toast.normal("Submitted successfully.");
      RouteHelper.pop(args: true);
    }
    context.read(_basicInfoSubmitProvider).state = false;
  }

  void updateProfilePic(String profileUrl) {
    setState(() {
      imagePath = profileUrl;
      context.read(profileImage).state = profileUrl;
      _onTextChangeListener();
    });
  }

  //
  // Future _openStoreSelectorDialog() async {
  //   if (_selectedCity != null) {
  //     final Store? store = await showDialog(
  //       context: context,
  //       builder: (_) => StoreSelectorListDialog(
  //         cityCode: _selectedCity?.code ?? "",
  //       ),
  //     );
  //     if (store != null) {
  //       _selectedStore = store;
  //       _darkStoreTEC.text = store.storeName ?? "";
  //       _onTextChangeListener();
  //     }
  //   } else {
  //     Toast.normal("Please select city first.");
  //   }
  // }
  //
  // Future _openDeliveryPartnerDialog() async {
  //   final IdName? deliveryPartner = await showDialog(
  //     context: context,
  //     builder: (_) => const SelectorListDialog(
  //       type: "Delivery Partner",
  //     ),
  //   );
  //   if (deliveryPartner != null) {
  //     _selectedDeliveryPartner = deliveryPartner;
  //     _deliveryPartnerTEC.text = deliveryPartner.name ?? "";
  //     _onTextChangeListener();
  //   }
  // }

  @override
  void dispose() {
    _firstNameTEC.dispose();
    _lastNameTEC.dispose();
    _mobileNoTEC.dispose();
    _cityTEC.dispose();

    super.dispose();
  }
}
