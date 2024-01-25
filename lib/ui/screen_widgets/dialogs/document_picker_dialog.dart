import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/helpers/route/route_helper.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

import '../../../values/custom_colors.dart';

class DocumentPickerDialog extends StatefulWidget {
  final Function(String) onImagePicked;
  final bool canShowPDF;
  final bool shouldDirectlyOpenCamera;

  const DocumentPickerDialog({
    Key? key,
    required this.onImagePicked,
    this.canShowPDF = false,
    this.shouldDirectlyOpenCamera = false,
  }) : super(key: key);

  @override
  State<DocumentPickerDialog> createState() => _DocumentPickerDialogState();
}

class _DocumentPickerDialogState extends State<DocumentPickerDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldDirectlyOpenCamera) {
      _onTileTap(ImageSource.camera);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.only(
            left: px_24, right: px_24, top: px_16, bottom: px_14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextView(
              title: "Complete action using",
              textStyle: commonTextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: lightBlackTxtColor),
            ),
            sizedBoxH30,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  // height: 70,
                  onTap: () {
                    _onTileTap(ImageSource.camera);
                  },
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Column(
                      children: [
                        Container(
                          height: px_50,
                          width: px_50,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black),
                          child: Padding(
                            padding: const EdgeInsets.all(px_14),
                            child: SvgPicture.asset(
                              'camera'.svgImageAsset,
                            ),
                          ),
                        ),
                        TextView(
                            title: 'Camera',
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: px_10),
                            textStyle: commonTextStyle(
                                color: inActiveTextColor, fontSize: 15))
                      ],
                    ),
                  ),
                ),
                if (!widget.shouldDirectlyOpenCamera) ...[
                  InkWell(
                    // height: 70,
                    onTap: () {
                      _onTileTap(ImageSource.gallery);
                    },
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Column(
                        children: [
                          Container(
                            height: px_50,
                            width: px_50,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black),
                            child: Padding(
                              padding: const EdgeInsets.all(px_14),
                              child: SvgPicture.asset(
                                'gallery'.svgImageAsset,
                              ),
                            ),
                          ),
                          TextView(
                              title: 'Gallery',
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: px_10),
                              textStyle: commonTextStyle(
                                  color: inActiveTextColor, fontSize: 15))
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.canShowPDF,
                    child: InkWell(
                      // height: 70,
                      onTap: () {
                        _onSelectPDFTap();
                      },
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Column(
                          children: [
                            Container(
                              height: px_50,
                              width: px_50,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.black),
                              child: Padding(
                                padding: const EdgeInsets.all(px_14),
                                child: SvgPicture.asset(
                                  'gallery'.svgImageAsset,
                                ),
                              ),
                            ),
                            TextView(
                                title: 'Files (PDF)',
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: px_10),
                                textStyle: commonTextStyle(
                                    color: inActiveTextColor, fontSize: 15))
                          ],
                        ),
                      ),
                    ),
                  ),
                ]

                // ListTile(
                //   leading: const Icon(Icons.camera),
                //   title: const Text("Camera"),
                //   onTap: () => _onTileTap(ImageSource.camera),
                // ),
                // if (!widget.shouldDirectlyOpenCamera) ...[
                //   ListTile(
                //     leading: const Icon(Icons.image),
                //     title: const Text("Gallery"),
                //     onTap: () => _onTileTap(ImageSource.gallery),
                //   ),
                //   if (widget.canShowPDF)
                //     ListTile(
                //       leading: const Icon(Icons.picture_as_pdf),
                //       title: const Text("Files (PDF)"),
                //       onTap: _onSelectPDFTap,
                //     )
                // ],
              ],
            )
          ],
        ),
      ),
    );
  }

  Future _onTileTap(ImageSource imageSource) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: imageSource);
      if (pickedFile != null) {
        RouteHelper.pop();
        widget.onImagePicked(pickedFile.path);
        return;
      }
    } on PlatformException catch (e, st) {
      Toast.normal(e.message!);
      ErrorReporter.error(e, st,
          "DocumentPickerDialog:_onTileTap() - PlatformException ${e.message}");
    } catch (e, st) {
      Toast.normal("Something went wrong. Please try again.");
      ErrorReporter.error(e, st, "DocumentPickerDialog:_onTileTap()");
    }
    if (widget.shouldDirectlyOpenCamera) {
      RouteHelper.pop();
    }
  }

  Future _onSelectPDFTap() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (result != null) {
        final File file = File(result.files.single.path);
        RouteHelper.pop();
        widget.onImagePicked(file.path);
      }
    } on PlatformException catch (e, st) {
      Toast.normal(e.message!);
      ErrorReporter.error(e, st,
          "DocumentPickerDialog:_onSelectPDFTap() - PlatformException ${e.message}");
    } catch (e, st) {
      Toast.normal("Something went wrong. Please try again.");
      ErrorReporter.error(e, st, "DocumentPickerDialog:_onSelectPDFTap()");
    }
  }
}
