import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';
import 'package:fraazo_delivery/services/media/image/compressed_image_service.dart';
import 'package:fraazo_delivery/utils/globals.dart';

class DocumentUploadProvider extends StateNotifier<AsyncValue<String>> {
  DocumentUploadProvider([AsyncValue<String> state = const AsyncLoading()])
      : super(state);

  final _userService = UserService();
  late final _compressedImageService = CompressedImageService();
  String imagePath = '';

  Future uploadFile(String filePath, String documentType) async {
    state = const AsyncLoading();
    try {
      String? newFilePath = filePath;
      if (!filePath.endsWith(".pdf")) {
        newFilePath =
            await _compressedImageService.compressAndGetFilePath(filePath);
      }

      Globals.linkUrl =
          await _userService.postRiderDocument(newFilePath, documentType);
      state = AsyncData(filePath);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(e, st, "DocumentUploadProvider: uploadFiles()");
      rethrow;
    }
  }
}
