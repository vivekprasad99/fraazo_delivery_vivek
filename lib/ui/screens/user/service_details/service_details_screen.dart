import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/models/misc/id_name_list_model.dart';
import 'package:fraazo_delivery/models/user/basic_details.dart';
import 'package:fraazo_delivery/models/user/profile/shift_time_model.dart';
import 'package:fraazo_delivery/models/user/profile/store_list_model.dart';
import 'package:fraazo_delivery/models/user/service_details_model.dart';
import 'package:fraazo_delivery/providers/user/profile/id_name_list_provider.dart';
import 'package:fraazo_delivery/providers/user/profile/service_detail_provider.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_fd_textfield.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_primary_button.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/id_name_list_dialog.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/shift_time_list_dialog.dart';
import 'package:fraazo_delivery/ui/screens/user/local_widgets/store_selector_list_dialog.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

import '../../../../providers/user/profile/user_profile_provider.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({Key? key}) : super(key: key);

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _idNameListProvider =
      StateNotifierProvider<IdNameListProvider, AsyncValue<List<IdName>>>(
          (_) => IdNameListProvider());

  final _isButtonEnabled = StateProvider.autoDispose<bool>((ref) => false);

  final _vehicleTypeProvider = StateProvider<int>((ref) => 0);

  final _serviceDetailProvider = StateNotifierProvider<ServiceDetailProvider,
          AsyncValue<ServiceDetailModel>>(
      (_) => ServiceDetailProvider(const AsyncLoading()));

  final _shiftPreferanceProvider = StateProvider<String>((ref) => "");
  final _shiftTextProvider = StateProvider<String>((ref) => "");
  final _shiftTimeProvider = StateProvider<String>((ref) => "");

  final _serviceAreaTEC = TextEditingController(),
      _timingTEC = TextEditingController(),
      _vehicleNoTEC = TextEditingController(),
      _darkStoreTEC = TextEditingController(),
      _deliveryPartnerTEC = TextEditingController();

  late Store? _selectedStore = null;
  late IdName? _selectedDeliveryPartner = null, _selectedCity = null;
  int? _vehicleId;
  int? _shiftId;
  List<int> storeId = [];
  String vehicleName = "";
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
    getBasicInfo();
    _getList();
    _getServiceDetailsList();
    _serviceAreaTEC.addListener(_onTextChangeListener);
    _deliveryPartnerTEC.addListener(_onTextChangeListener);
    _darkStoreTEC.addListener(_onTextChangeListener);
    _timingTEC.addListener(_onTextChangeListener);
    _vehicleNoTEC.addListener(_onTextChangeListener);
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
        height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(px_16),
            topRight: Radius.circular(px_16),
          ),
        ),
        child: _buildBody(context),
      ),
    );
  }

  int vehicleTypeId = -1;

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: ProviderListener(
        provider: _serviceDetailProvider,
        onChange:
            (BuildContext context, AsyncValue<ServiceDetailModel> asyncValue) {
          if (asyncValue is AsyncData) {
            final serviceDetail = asyncValue.data?.value.serviceDetail;
            _vehicleNoTEC.text = serviceDetail!.vehicleNumber.toString();
            _darkStoreTEC.text = serviceDetail.storeName.toString();
            _shiftId = serviceDetail.shiftId;
            _timingTEC.text = serviceDetail.shiftTime.toString();
            _deliveryPartnerTEC.text = serviceDetail.deliveryPartner.toString();
            context.read(_vehicleTypeProvider).state =
                serviceDetail.vehicleTypeId ?? -1;
            _vehicleId = serviceDetail.vehicleTypeId;
            context.read(_shiftPreferanceProvider).state =
                serviceDetail.shift.toString();
            context.read(_shiftTextProvider).state =
                serviceDetail.shiftText.toString();
            context.read(_shiftTimeProvider).state =
                serviceDetail.shiftTime.toString();
          }
        },
        child: Consumer(
          builder: (_, watch, __) {
            return watch(_serviceDetailProvider).when(
              data: (ServiceDetailModel serviceDetail) {
                return Column(
                  children: [
                    TextView(
                      title: "Service Details",
                      textStyle: commonTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    sizedBoxH6,
                    TextView(
                      title: "Please fill the required details",
                      textStyle: commonTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: lightBlackTxtColor,
                      ),
                    ),
                    sizedBoxH20,
                    // NewFDTextField(
                    //   labelText: "Service Area*",
                    //   controller: _serviceAreaTEC,
                    //   onTap: _openCitySelectorDialog,
                    //   showDropDownIcon: true,
                    //   isReadOnly: true,
                    // ),
                    // sizedBoxH18,
                    NewFDTextField(
                      labelText: "Delivery Partner Type*",
                      controller: _deliveryPartnerTEC,
                      onTap: _openDeliveryPartnerDialog,
                      showDropDownIcon: true,
                      isReadOnly: true,
                    ),
                    sizedBoxH18,
                    NewFDTextField(
                      labelText: "DarkStore*",
                      controller: _darkStoreTEC,
                      onTap: _openStoreSelectorDialog,
                      showDropDownIcon: true,
                      isReadOnly: true,
                    ),
                    sizedBoxH18,
                    Column(
                      children: [
                        TextView(
                          title: "Shift Preferance*",
                          textStyle: commonTextStyle(
                            color: lightBlackTxtColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: _openShiftPreferanceDialog,
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: borderLineColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer(
                                      builder: (_, watch, __) {
                                        return TextView(
                                          title: watch(_shiftPreferanceProvider)
                                              .state,
                                          textStyle: commonTextStyle(
                                            color: Colors.white,
                                            fontSize: tx_16,
                                          ),
                                        );
                                      },
                                    ),
                                    sizedBoxW15,
                                    Consumer(
                                      builder: (_, watch, __) {
                                        return TextView(
                                          title:
                                              watch(_shiftTimeProvider).state,
                                          textStyle: commonTextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: inActiveTextColor,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    // sizedBoxH18,
                    // NewFDTextField(
                    //   labelText: "Timing*",
                    //   controller: _timingTEC,
                    //   showDropDownIcon: true,
                    //   isReadOnly: true,
                    // ),
                    sizedBoxH18,
                    TextView(
                        title: "Vehicle Type *",
                        textStyle: commonTextStyle(
                            color: lightBlackTxtColor,
                            fontWeight: FontWeight.w400)),
                    sizedBoxH10,
                    Consumer(
                      builder: (_, watch, __) {
                        return watch(_idNameListProvider).when(
                          data: (List<IdName> idNameList) => _buildSelectorList(
                            idNameList,
                          ),
                          loading: () => const FDCircularLoader(),
                          error: (e, __) => FDErrorWidget(
                            onPressed: _getList,
                          ),
                        );
                      },
                    ),
                    sizedBoxH18,
                    NewFDTextField(
                      labelText: "Vehicle number*",
                      controller: _vehicleNoTEC,
                    ),
                    sizedBoxH18,
                    Consumer(builder: (_, watch, __) {
                      return NewPrimaryButton(
                        buttonTitle: "Continue",
                        isActive: watch(_isButtonEnabled).state,
                        activeColor: buttonColor,
                        inactiveColor: buttonInActiveColor,
                        buttonRadius: px_8,
                        buttonHeight: 45,
                        buttonWidth: Get.width,
                        onPressed: _onContinueTap,
                      );
                    }),
                    sizedBoxH18,
                  ],
                );
              },
              loading: () => const FDCircularLoader(
                progressColor: Colors.white,
              ),
              error: (e, _) => SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: FDErrorWidget(
                  onPressed: _getServiceDetailsList,
                  textColor: Colors.white,
                  errorType: e,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectorList(List<IdName> idNameList) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: idNameList.length,
        itemBuilder: (_, int index) => _buildVehicleType(idNameList[index]),
      ),
    );
  }

  Widget _buildVehicleType(
    IdName idName,
  ) {
    return Consumer(
      builder: (_, watch, __) {
        final vehicleType = watch(_vehicleTypeProvider);
        vehicleTypeId = vehicleType.state;
        return InkWell(
          onTap: () {
            context.read(_vehicleTypeProvider).state = idName.id ?? 0;
            _vehicleId = idName.id ?? 0;
          },
          child: Container(
            margin: const EdgeInsets.only(right: 11.0),
            padding: const EdgeInsets.symmetric(vertical: 5),
            width: MediaQuery.of(context).size.width * 0.292,
            height: MediaQuery.of(context).size.height * 0.066,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2C2C),
              borderRadius: BorderRadius.circular(px_5),
              border: Border.all(
                color: (vehicleTypeId == idName.id)
                    ? buttonColor
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: idName.img!.isNotEmpty,
                  child: CachedNetworkImage(imageUrl: idName.img!),
                ),
                TextView(
                  padding: const EdgeInsets.all(5),
                  title: idName.name!,
                  textStyle: commonTextStyle(
                    fontSize: (vehicleTypeId == idName.id) ? 18 : 15,
                    color: (vehicleTypeId == idName.id)
                        ? textColor
                        : const Color(0xFFA7A7A7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _openDeliveryPartnerDialog() async {
    final IdName? deliveryPartner = await showDialog(
      context: context,
      builder: (_) => const SelectorListDialog(
        type: "Delivery Partner",
      ),
    );
    if (deliveryPartner != null) {
      _selectedDeliveryPartner = deliveryPartner;
      _deliveryPartnerTEC.text = deliveryPartner.name ?? "";
    }
  }

  Future _openShiftPreferanceDialog() async {
    final ShiftTime shiftPreference = await showDialog(
      context: context,
      builder: (_) => const ShiftTimeListDialog(
        type: "Shift Preferance",
      ),
    );
    _timingTEC.text = shiftPreference.shiftTiming ?? "";
    _shiftId = shiftPreference.id ?? _shiftId;
    context.read(_shiftPreferanceProvider).state = shiftPreference.shift ?? "";
    context.read(_shiftTextProvider).state = shiftPreference.shiftText ?? "";
    context.read(_shiftTimeProvider).state = shiftPreference.shiftTiming ?? "";
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
      _serviceAreaTEC.text = city.name ?? "";
      _selectedStore = null;
      _darkStoreTEC.clear();
    }
  }

  Future _openStoreSelectorDialog() async {
    if (_selectedCity != null) {
      final Store? store = await showDialog(
        context: context,
        builder: (_) => StoreSelectorListDialog(
          cityCode: _selectedCity!.code!,
        ),
      );
      if (store != null) {
        _selectedStore = store;
        _darkStoreTEC.text = store.storeName ?? "";
        storeId.add(store.storeId ?? 0);
        _onTextChangeListener();
      }
    } else {
      Toast.normal("Please select city first.");
    }
  }

  Future _onTextChangeListener() async {
    if (_deliveryPartnerTEC.text.isNotEmpty &&
        _darkStoreTEC.text.isNotEmpty &&
        _timingTEC.text.isNotEmpty &&
        _vehicleNoTEC.text.isNotEmpty) {
      context.read(_isButtonEnabled).state = true;
    } else {
      context.read(_isButtonEnabled).state = false;
    }
  }

  Future _onContinueTap() async {
    final Map<String, dynamic> serviceDetailData = {
      "delivery_partner": _deliveryPartnerTEC.text,
      "store_id": storeId,
      "shift_id": _shiftId,
      "vehicle_type_id": _vehicleId,
      "vehicle_number": _vehicleNoTEC.text
    };
    await context
        .read(_serviceDetailProvider.notifier)
        .postServiceDetail(serviceDetailData);
    Toast.info("Service Details added Successfully");
    RouteHelper.pop();
  }

  void clearData() {
    _serviceAreaTEC.clear();
    _vehicleNoTEC.clear();
    _timingTEC.clear();
    _darkStoreTEC.clear();
    _deliveryPartnerTEC.clear();
  }

  void _getList() {
    context.read(_idNameListProvider.notifier).getList("Vehicle Type");
  }

  Future _getServiceDetailsList() {
    return context
        .read(_serviceDetailProvider.notifier)
        .getServiceDetailFetch();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    context.read(_vehicleTypeProvider).dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    _serviceAreaTEC.dispose();
    _vehicleNoTEC.dispose();
    _timingTEC.dispose();
    _darkStoreTEC.dispose();
    _deliveryPartnerTEC.dispose();
    super.dispose();
  }

  Future getBasicInfo() async {
    context
        .read(userProfileProvider.notifier)
        .getBasicDetails()
        .then((value) => getCityId(value.data));
  }

  Future getCityId(Data data) async {
    List<IdName>? idNameList = await UserService().getCities();

    IdName cityInfo =
        idNameList.firstWhere((element) => element.name == data.city);
    _selectedCity = cityInfo;
    setState(() {});
  }
}
