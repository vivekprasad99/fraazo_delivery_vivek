import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/providers/user/profile/user_profile_provider.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/document_picker_dialog.dart';
import 'package:fraazo_delivery/ui/screen_widgets/empty_image_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/document/document_uploading_dialog.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';

class ProfilePicWidget extends StatefulWidget {
  String imagePath;
  Function(String profileUrl) profilePicMethod;
  ProfilePicWidget(this.imagePath, this.profilePicMethod, {Key? key})
      : super(key: key);

  @override
  State<ProfilePicWidget> createState() => _ProfilePicWidgetState();
}

class _ProfilePicWidgetState extends State<ProfilePicWidget> {
  late String _imageUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageUrl = widget.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    print("checking ${widget.imagePath}");
    return InkWell(
      child: Container(
          height: 137,
          width: double.maxFinite,
          decoration: BoxDecoration(
              border: Border.all(color: borderLineColor),
              borderRadius: BorderRadius.circular(5)),
          child: _imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: _imageUrl,
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                  //   NetworkImage(imagePath),
                  //   fit: BoxFit.cover,
                  //   width: MediaQuery.of(context).size.width,
                  //   loadingBuilder: (BuildContext context, Widget child,
                  //       ImageChunkEvent? loadingProgress) {
                  //     if (loadingProgress == null) {
                  //       return child;
                  //     }
                  //     return const Center(
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   },
                  // ),
                )
              : const EmptyImageWidget(
                  noImageText: "Your photo *",
                )),
      onTap: () {
        if (!Globals.user!.isVerified) {
          _showDocumentPickerDialog('profile_pic');
        }
      },
    );
  }

  void _showDocumentPickerDialog(String docType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(px_16), topLeft: Radius.circular(px_16)),
      ),
      builder: (_) => DocumentPickerDialog(
        onImagePicked: (String pickedFilePath) =>
            _showDocumentUploadingDialog(pickedFilePath, docType),
        canShowPDF: false,
      ),
    );
  }

  Future _showDocumentUploadingDialog(String path, String docType) async {
    await showDialog(
      context: context,
      builder: (_) =>
          DocumentUploadingDialog(filePath: path, documentType: docType),
    );
    // if (isSuccess) {
    _getProfilePic();

    // }
  }

  void _getProfilePic() {
    final basicDetailsProvider = FutureProvider.autoDispose(
      (ref) => ref.read(userProfileProvider.notifier).getBasicDetails(),
    );
    context.read(basicDetailsProvider.future).then((value) => setState(() {
          _imageUrl = value.data.link;
          widget.imagePath = _imageUrl;
          widget.profilePicMethod.call(value.data.link);
        }));
  }
}
