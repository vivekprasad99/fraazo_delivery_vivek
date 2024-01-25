import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fraazo_delivery/helpers/extensions/string_extension.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/document_picker_dialog.dart';
import 'package:fraazo_delivery/ui/utils/toast.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class QualityIssueAttachments extends StatefulWidget {
  const QualityIssueAttachments({Key? key}) : super(key: key);

  @override
  State<QualityIssueAttachments> createState() =>
      QualityIssueAttachmentsState();
}

class QualityIssueAttachmentsState extends State<QualityIssueAttachments> {
  final List<String> imagePathList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding5,
      decoration: BoxDecoration(
        border: Border.all(
          color: settleCashListTitle,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Photo of the item with quality issue",
            style: commonTextStyle(
              fontSize: 11,
              color: cardLightBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          sizedBoxH5,
          InkWell(
            onTap: () => imagePathList.length <= 4
                ? _onImageTileTap()
                : Toast.info('You cannot choose more than 5 attachments!'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: settleCashListTitle),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  child: SvgPicture.asset(
                    'ic_camera'.svgImageAsset,
                    width: 16,
                    height: 16,
                  ),
                ),
                sizedBoxW5,
                SizedBox(
                  height: 53,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: imagePathList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(
                              imagePathList[index],
                            ),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      );
                      /*return SvgPicture.asset(
                        'gallery'.svgImageAsset,
                        height: 54,
                        width: 54,
                      );*/
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

  void _onImageTileTap() {
    showDialog(
      context: context,
      builder: (_) => DocumentPickerDialog(
        onImagePicked: (String path) {
          setState(() {
            imagePathList.add(path);
          });
        },
        shouldDirectlyOpenCamera: true,
      ),
    );
  }
}
