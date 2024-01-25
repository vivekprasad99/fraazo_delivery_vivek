import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/date/date_formatter.dart';
import 'package:fraazo_delivery/helpers/extensions/BitmapDescriptorHelper.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/helpers/route/routes.dart';
import 'package:fraazo_delivery/models/delivery/location.dart';
import 'package:fraazo_delivery/models/delivery/task_model.dart';
import 'package:fraazo_delivery/providers/delivery/order/order_update_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/container_divider.dart';
import 'package:fraazo_delivery/ui/screens/delivery/steps/local_widgets/new_slide_button.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/constants.dart';
import 'package:fraazo_delivery/utils/device_app_launcher.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/stop_watch_timer.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewMapScreen extends StatefulWidget {
  final Task? task;

  const NewMapScreen(
    this.task, {
    Key? key,
  }) : super(key: key);

  @override
  _NewMapScreenState createState() => _NewMapScreenState();
}

class _NewMapScreenState extends State<NewMapScreen>
    with TickerProviderStateMixin {
  // Initial location of the Map view
  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(0.0, 0.0));

// For controlling the view of the Map
  GoogleMapController? mapController;
  final List<Marker> _marker = [];
  final List<Marker> _list = [];
  ValueNotifier<LatLng> updateLocation = ValueNotifier(const LatLng(0.0, 0.0));
  ValueNotifier<bool> isDelayed = ValueNotifier(false);

  bool _isTimerStart = false;
  AnimationController? _controller;

  int travelTimeExpire = 0;
  int travelTime = 0;
  OrderSeq? orderSeq;
  Location? riderLocation;

  StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
  );

  @override
  void initState() {
    // setEATTimer();
    setRiderMarker();
    getRiderCurrentLocation();
    setMarkerIcon();
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    isDelayed.value =
        DateFormatter().isPassedTime(widget.task?.orderSeq?.single.etaDelivery);
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => setRiderMarker());
    WidgetsBinding.instance?.addPostFrameCallback((_) => setEATTimer());
    _stopWatchTimer.secondTime.listen((value) {
      print('secondTime $value');
      if (value != 0) {
        _isTimerStart = true;
      }
      if (value == 0 && !isDelayed.value && _isTimerStart) {
        isDelayed.value = true;
        setState(() {
          _stopWatchTimer.dispose();
          _stopWatchTimer = StopWatchTimer();
          _stopWatchTimer.clearPresetTime();
          _stopWatchTimer.setPresetSecondTime(0);
          _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
          setEATTimer();
        });
      }
    });
  }

  Future<void> setRiderMarker() async {
    riderLocation = await Globals.getAssignedLocation();
    if (riderLocation != null) {}
    // setMarkerIcon(LatLng(riderLocation!.latitude!, riderLocation!.longitude!),
    //     'rider_pin'.svgImageAsset);
  }

  // Future<void> setMarkerIcon(LatLng latLng, String makerIconPath) async {
  //   BitmapDescriptor bitmapDescriptor =
  //       await BitmapDescriptorHelper.bitmapDescriptorFromSvgAsset(
  //           context, makerIconPath);
  //   _list.add(Marker(
  //       markerId: MarkerId(makerIconPath.hashCode.toString()),
  //       icon: bitmapDescriptor,
  //       position: latLng));
  //   if (_marker.length == 2) {
  //     _marker[1] = Marker(
  //         markerId: MarkerId(makerIconPath.hashCode.toString()),
  //         icon: bitmapDescriptor,
  //         position: latLng);
  //   } else {
  //     _marker.addAll(_list);
  //   }
  // }

  void setEATTimer() {
    travelTimeExpire = DateFormatter()
        .parseDateTimeToSecond(widget.task?.orderSeq?.single.etaDelivery);
    _stopWatchTimer.setPresetSecondTime(travelTimeExpire);
    if (isDelayed.value) {
      _stopWatchTimer.mode = StopWatchMode.countUp;
    } else {
      _stopWatchTimer.mode = StopWatchMode.countDown;
    }

    // _calculatingExpiryTime();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        RouteHelper.pop(args: true);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: _buildBody(),
      ),
    );
  }

  BitmapDescriptor? destinationMarker, sourceMarker;

  void setMarkerIcon() async {
    destinationMarker =
        await BitmapDescriptorHelper.bitmapDescriptorFromSvgAsset(
            context, 'pin'.svgImageAsset);
    sourceMarker = await BitmapDescriptorHelper.bitmapDescriptorFromSvgAsset(
        context, 'rider_pin'.svgImageAsset);
  }

  Widget _buildBody() {
    orderSeq = widget.task?.orderSeq?.single;

    travelTimeExpire =
        DateFormatter().parseDateTimeToSecond(orderSeq?.etaDelivery);
    // _calculatingExpiryTime();

    final _orderSeqLat = orderSeq?.lat ?? 0.0;
    final _orderSeqLng = orderSeq?.lng ?? 0.0;

    // setMarkerIcon(
    //   LatLng(_orderSeqLat, _orderSeqLng),
    //   'pin'.svgImageAsset,
    // );

    return SafeArea(
        child: ValueListenableBuilder(
            valueListenable: isDelayed,
            builder: (BuildContext context, isDelay, Widget? child) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        color: bgColor,
                        child: ListTile(
                          title: Text("ORDER #${orderSeq?.orderNumber}",
                              style: commonTextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              )),
                          subtitle: Text("Task ID: ${orderSeq?.taskId}",
                              style: commonTextStyle(
                                color: subText,
                                fontSize: 13,
                              )),
                          trailing: Container(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D3D3D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${(orderSeq?.isCod ?? false) ? "COD ORDER: " : "PAID ORDER: "} ₹${orderSeq?.amount}",
                              style: commonTextStyle(
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: ValueListenableBuilder(
                          valueListenable: updateLocation,
                          builder:
                              (BuildContext context, value, Widget? child) {
                            return Stack(
                              children: [
                                if (updateLocation.value.latitude == 0)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                          updateLocation.value.latitude,
                                          updateLocation.value.longitude),
                                      zoom: 13.5,
                                    ),
                                    // markers: Set<Marker>.of(_marker),
                                    markers: {
                                      Marker(
                                          markerId: const MarkerId('source'),
                                          icon: sourceMarker ??
                                              BitmapDescriptor.defaultMarker,
                                          position: LatLng(
                                              orderSeq!.lat!, orderSeq!.lng!)),
                                      Marker(
                                        markerId: const MarkerId("destination"),
                                        icon: destinationMarker ??
                                            BitmapDescriptor.defaultMarker,
                                        position: LatLng(
                                            updateLocation.value.latitude,
                                            updateLocation.value.longitude),
                                      ),
                                    },
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: false,
                                    mapType: MapType.normal,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: false,
                                    polylines:
                                        Set<Polyline>.of(polyLines.values),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      mapController = controller;
                                    },
                                  ),
                                Positioned(
                                  bottom: 20,
                                  left: 15,
                                  right: 15,
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF464444),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                                'Use Google maps for easy navigation',
                                                style: commonTextStyle(
                                                    color: textColor,
                                                    fontSize: 13.0)),
                                          ),
                                          sizedBoxW5,
                                          InkWell(
                                            onTap: () {
                                              DeviceAppLauncher().launchByUrl(
                                                "http://maps.google.com/maps?daddr=$_orderSeqLat,$_orderSeqLng",
                                              );
                                            },
                                            child: Container(
                                              height: 30,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff00A1F2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                    'location_arrow'
                                                        .svgImageAsset,
                                                    height: 14,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  sizedBoxW5,
                                                  Text(
                                                    "Navigate",
                                                    style: commonTextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 75,
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: const BoxDecoration(
                          color: travelBgColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Travel Time",
                                  style: commonTextStyle(
                                    color: textColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                RichText(
                                    text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: getTravelTime(),
                                      style: commonTextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: textColor),
                                    ),
                                    TextSpan(
                                      text: ' min',
                                      style: commonTextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: textColor),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Distance",
                                  style: commonTextStyle(
                                    color: textColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                RichText(
                                    text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: widget
                                          .task!.orderSeq![0].darkstoreDistance!
                                          .toStringAsFixed(2),
                                      style: commonTextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: textColor),
                                    ),
                                    TextSpan(
                                      text: ' kms',
                                      style: commonTextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: textColor),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                          ),
                          color: bgColor,
                          child: ListView(
                            children: [
                              sizedBoxH30,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'customer'.svgImageAsset,
                                      ),
                                      sizedBoxW10,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Customer",
                                            style: commonTextStyle(
                                              color: const Color(0xffAAAAAA),
                                              fontSize: 13,
                                            ),
                                          ),
                                          sizedBoxH6,
                                          Text(orderSeq?.custName ?? '',
                                              style: commonTextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  sizedBoxH20,
                                  const ContainerDivider(),
                                  sizedBoxH20,
                                  Row(
                                    children: [
                                      Container(
                                        height: px_10,
                                        width: px_10,
                                        decoration: const BoxDecoration(
                                            color: buttonColor,
                                            shape: BoxShape.circle),
                                      ),
                                      sizedBoxW10,
                                      Text(
                                        "Customer Location",
                                        style: commonTextStyle(
                                          color: const Color(0xffAAAAAA),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 10),
                                    child: Text(orderSeq?.address ?? '',
                                        style: commonTextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        )),
                                  )
                                ],
                              ),
                              sizedBoxH30,
                              const ContainerDivider(),
                              sizedBoxH40,
                              NewSlideButton(
                                action: () => _onReachedCusterLocation(),
                                backgroundColor: buttonColor,
                                height: 54,
                                radius: 10,
                                dismissible: false,
                                label: Text(
                                  "  Reached Customer Location",
                                  style: commonTextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width * 0.95,
                                alignLabel: const Alignment(0.4, 0),
                              ),
                              sizedBoxH20
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                      top: (MediaQuery.of(context).size.height / 3.3) + 140,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 12, bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF464444),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                  color: isDelayed.value
                                      ? const Color(0xffE34646)
                                      : Colors.transparent),
                            ),
                            child: StreamBuilder<int>(
                              stream: _stopWatchTimer.rawTime,
                              initialData: _stopWatchTimer.rawTime.value,
                              builder: (context, snap) {
                                final value = snap.data!;
                                final displayTime =
                                    StopWatchTimer.getDisplayTime(value,
                                        hours: false);
                                return Column(
                                  children: <Widget>[
                                    Visibility(
                                      visible: isDelayed.value,
                                      child: Text(
                                        'Delay By',
                                        style: commonTextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Text(
                                      displayTime,
                                      style: commonTextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8),
                                    //   child: Text(
                                    //     value.toString(),
                                    //     style: const TextStyle(
                                    //         fontSize: 16,
                                    //         fontFamily: 'Helvetica',
                                    //         fontWeight: FontWeight.w400),
                                    //   ),
                                    // ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      )),
                  Positioned(
                    top: (MediaQuery.of(context).size.height / 3.3) + 110,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: SvgPicture.asset(
                          isDelayed.value
                              ? 'clock_red'.svgImageAsset
                              : 'clock'.svgImageAsset,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }));
  }

  // void _calculatingExpiryTime() {
  //   travelTime = 0;
  //   if (travelTimeExpire < 0) {
  //     travelTime = DateFormatter().parseDateTimeToSecond(orderSeq?.etaDelivery);
  //     // _isDelay = true;
  //   } else {
  //     travelTime = travelTimeExpire;
  //   }
  //   // _startTimer(travelTime);
  // }

  // void _startTimer(int travelTimeExpire) {
  //   _controller = null;
  //   _controller = AnimationController(
  //     vsync: this,
  //     duration: isDelayed.value
  //         ? const Duration(minutes: 60)
  //         : Duration(seconds: travelTimeExpire),
  //   );
  //   if (isDelayed.value) {
  //     print('addListener ${_controller?.duration}');
  //     _controller?.reverse();
  //   } else {
  //     _controller?.forward();
  //   }
  //   _controller?.addListener(() {
  //     // print('addListener ${_controller?.value}');
  //     if (_controller?.value == 1.0 && !isDelayed.value) {
  //       setState(() {
  //         travelTimeExpire = 0;
  //         _calculatingExpiryTime();
  //       });
  //     }
  //   });
  //   _controller!.addStatusListener((AnimationStatus status) {
  //     print('addListener--1 ${_controller?.status}');
  //   });
  // }

  Future<void> _onReachedCusterLocation() async {
    await Toast.popupLoadingFuture(
      future: () =>
          context.read(orderUpdateProvider.notifier).updateOrderStatus(
                Constants.OS_REACHED_CUSTOMER,
                orderSeq: widget.task?.orderSeq?.single,
              ),
      onSuccess: (_) async {
        OrderSeq orderSeq =
            context.read(orderUpdateProvider.notifier).currentOrder;
        widget.task?.orderSeq?.clear();
        widget.task?.orderSeq?.add(orderSeq);
        Globals.isSupportEnable = orderSeq.supportEnabled ?? false;
        String? qrCode;
        if (Globals.user!.batchingQr!) {
          qrCode = await RouteHelper.push(
            Routes.QR_CODE_SCANNER,
            args: {
              'task': widget.task,
              'order': widget.task?.orderSeq?.single,
              'isPicked': true
            },
          );
        } else {
          qrCode = "";
        }

        if (qrCode != null) {
          _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          RouteHelper.pushReplacement(
            Routes.DELIVERY_COMPLETED_SCREEN,
            args: widget.task,
          );
        }
      },
      onFailure: () async {},
    );

    /* context.read(orderUpdateProvider.notifier).updateOrderStatus(
          Constants.OS_REACHED_CUSTOMER,
          orderSeq: widget.task?.orderSeq?.single,
        );*/

    // RouteHelper.pop();
  }

  Future<void> _startOrderDelivery() async {
    await context.read(orderUpdateProvider.notifier).updateOrderStatus(
          Constants.OS_DELIVERY_STARTED,
          orderSeq: widget.task?.orderSeq?.single,
        );
    orderSeq = context.read(orderUpdateProvider.notifier).currentOrder;
    print('orderSeq ${orderSeq?.etaDelivery}');
    setState(() {});
  }

  void getRiderCurrentLocation() {
    Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
      intervalDuration: const Duration(seconds: 10),
    ).listen(
      (Position? position) {
        try {
          // Toast.normal('Rider current location');
          if (position != null) {
            final LatLng latLng = LatLng(
              // Will be fetching in the next step
              position.latitude,
              position.longitude,
            );
            // _initialCameraPosition = CameraPosition(
            //   target: latLng,
            //   zoom: 12,
            // );
            if (mapController != null) {
              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: latLng,
                    zoom: 12.0,
                  ),
                ),
              );
            }
            //
            // _createPolyLines(latLng.latitude, latLng.longitude, orderSeq!.lat!,
            //     orderSeq!.lng!);

            if (polylineCoordinates.isEmpty) {
              _createPolyLines(
                latLng.latitude,
                latLng.longitude,
                widget.task!.orderSeq!.single.lat!,
                widget.task!.orderSeq!.single.lng!,
              );
            }
            updateLocation.value = latLng;
            //isDelayed.value = true;
          } else {
            debugPrint("Print after else 10 seconds");
          }
        } catch (e) {
          print(e);
        }
      },
      onError: (err) {
        print('Error! $err');
      },
      cancelOnError: false,
      onDone: () {
        print('Done!');
      },
    );
  }

  // Create the polyLines for showing the route between two places

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];

  Future<void> _createPolyLines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   'AIzaSyDifNjfVBKFaa6-WXvZAEUmvOd8QUeoHAU', // Google Maps API Key
    //   PointLatLng(startLatitude, startLongitude),
    //   PointLatLng(destinationLatitude, destinationLongitude),
    // );
    //
    // if (result.points.isNotEmpty) {
    //   result.points.forEach((PointLatLng point) {
    polylineCoordinates.add(LatLng(startLatitude, startLongitude));
    polylineCoordinates.add(LatLng(destinationLatitude, destinationLongitude));
    //   });
    // }

    const PolylineId id = PolylineId('poly');
    final Polyline polyline = Polyline(
      polylineId: id,
      color: pollylineColors,
      points: polylineCoordinates,
      width: 5,
    );
    polyLines[id] = polyline;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    super.dispose();
    _stopWatchTimer.dispose();
  }

  String getTravelTime() {
    Duration clockTimer = Duration(seconds: orderSeq!.etaInSeconds!.toInt());

    return '${clockTimer.inMinutes.remainder(60).toString().length == 1 ? '0${clockTimer.inMinutes.remainder(60).toString()}' : clockTimer.inMinutes.remainder(60).toString()}:${(clockTimer.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')}';
  }
}
