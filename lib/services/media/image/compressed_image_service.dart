import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressedImageService {
  Future<String?> compressAndGetFilePath(String path) async {
    final Directory tempDir = await getTemporaryDirectory();
    path.replaceAll(".png", ".jpg");
    final String targetTempPath = tempDir.path + path.split("/").last;
    final File? result = await FlutterImageCompress.compressAndGetFile(
        path, targetTempPath.replaceAll(".png", ".jpg"));
    return result?.path;
  }
}
