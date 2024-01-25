import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/services/api/delivery/delivery_service.dart';
import 'package:fraazo_delivery/services/location/gps_service.dart';
import 'package:fraazo_delivery/services/media/image/compressed_image_service.dart';

class UploadTaskImagesProvider extends StateNotifier<AsyncValue<String>?> {
  UploadTaskImagesProvider([AsyncValue<String>? state]) : super(state);

  final _deliveryService = DeliveryService();
  final _compressedImageService = CompressedImageService();

  Future uploadImage(String filePath, int? orderId) async {
    state = const AsyncLoading();
    try {
      await GPSService().checkGPSServiceAndSetCurrentLocation();
      final newFilePath =
          await _compressedImageService.compressAndGetFilePath(filePath);

      await _deliveryService.postOrderImage(newFilePath, orderId);
      state = AsyncData(filePath);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "UploadTaskImagesProvider: uploadImage()");
      rethrow;
    }
  }
}
