import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/models/user/document_list_model.dart';
import 'package:fraazo_delivery/providers/user/details/document/document_list_provider.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_circular_loader.dart';
import 'package:fraazo_delivery/ui/global_widgets/fd_error_widget.dart';
import 'package:fraazo_delivery/ui/global_widgets/new_app_bar.dart';
import 'package:fraazo_delivery/ui/screen_widgets/dialogs/document_picker_dialog.dart';
import 'package:fraazo_delivery/ui/screen_widgets/empty_image_widget.dart';
import 'package:fraazo_delivery/ui/screens/user/details/local_widgets/document/document_uploading_dialog.dart';
import 'package:fraazo_delivery/ui/utils/textview.dart';
import 'package:fraazo_delivery/ui/utils/widgets_and_attributes.dart';
import 'package:fraazo_delivery/utils/globals.dart';
import 'package:fraazo_delivery/utils/utils.dart';
import 'package:fraazo_delivery/values/custom_colors.dart';
import 'package:get/get.dart';

class DocumentDetails extends StatefulWidget {
  const DocumentDetails({Key? key}) : super(key: key);

  @override
  _DocumentDetailsState createState() => _DocumentDetailsState();
}

class _DocumentDetailsState extends State<DocumentDetails> {
  final _documentListProvider = StateNotifierProvider.autoDispose<
      DocumentListProvider,
      AsyncValue<List<Document>?>>((_) => DocumentListProvider());

  late final bool? _isUserVerified = Globals.user?.isVerified;

  final Map<String, bool> _documentUploadStatusMap = {
    "profile_pic": false,
    "aadhaar": false,
    "aadhaar_back": false,
    "licence": false,
    "licence_back": false,
    "pan": false,
    "address_proof": false,
  };

  final List<Document>? doumentList = [];

  @override
  void initState() {
    super.initState();
    _getUploadedDocuments();
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
                topRight: Radius.circular(px_16))),
        child: Consumer(
          builder: (_, watch, __) {
            return watch(_documentListProvider).when(
              data: (List<Document>? documentList) =>
                  _buildDocumentList(documentList),
              loading: () => const FDCircularLoader(
                progressColor: Colors.white,
              ),
              error: (_, __) => FDErrorWidget(onPressed: _getUploadedDocuments),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentList(List<Document>? documentList) {
    _setDocumentStatus(documentList);
    return SingleChildScrollView(
      child: Column(
        children: [
          TextView(
              title: 'Documents',
              textStyle: commonTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(
            height: 5,
          ),
          TextView(
              title: 'Please upload the required documents',
              textStyle: commonTextStyle(
                  fontSize: 14,
                  color: lightBlackTxtColor,
                  fontWeight: FontWeight.w400)),
          const SizedBox(
            height: 20,
          ),
          // _buildDocumentCard("Profile Photo*", "profile_pic", ""),
          // sizedBoxH15,
          _buildDocumentCard("Aadhaar Card*", "aadhaar", "aadhaar_back"),
          sizedBoxH18,
          _buildDocumentCard("PAN Card*", "pan", ""),
          sizedBoxH18,
          _buildDocumentCard("Driving Licence*", "licence", "licence_back"),
          sizedBoxH18,
          _buildDocumentCard("Address Proof*", "address_proof", ""),
          sizedBoxH18,
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String label, String docType, String backDocType) {
    final bool isDocUploaded = _documentUploadStatusMap[docType]!;
    final bool isBackDocUploaded =
        backDocType.isNotEmpty ? _documentUploadStatusMap[backDocType]! : false;
    final Document? _documentInfo = doumentList!.isNotEmpty
        ? doumentList!.firstWhere(
            (element) => element.type == docType,
            orElse: () => Document(),
          )
        : null;
    final Document? _backDocumentInfo = doumentList!.isNotEmpty
        ? doumentList!.firstWhere(
            (element) => element.type == backDocType,
            orElse: () => Document(),
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(
                title: label,
                textStyle: commonTextStyle(fontSize: 15, color: Colors.white),
              ),
              TextView(
                title: _documentInfo != null
                    ? _documentInfo.isVerified != null
                        ? _documentInfo.isVerified!
                            ? 'Verified'
                            : 'Not Verified'
                        : 'Not uploaded'
                    : 'Not uploaded',
                //isDocUploaded ? "Uploaded" : "Not uploaded",
                textStyle: commonTextStyle(
                  color: _documentInfo != null
                      ? _documentInfo.isVerified != null
                          ? _documentInfo.isVerified!
                              ? buttonColor
                              : Colors.red
                          : Colors.red
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          sizedBoxH10,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: InkWell(
                  onTap: !isDocUploaded || !_isUserVerified!
                      ? () {
                          _showDocumentPickerDialog(docType);
                        }
                      : null,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: inActiveTextColor),
                      borderRadius: BorderRadius.circular(px_5),
                    ),
                    child: isDocUploaded &&
                            _documentInfo != null &&
                            _documentInfo.link != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: CachedNetworkImage(
                              imageUrl: _documentInfo.link!,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error,color: Colors.red,),
                            ),
                            // Image(
                            //   image: NetworkImage(_documentInfo.link!),
                            //   fit: BoxFit.fill,
                            //   loadingBuilder: (BuildContext context,
                            //       Widget child,
                            //       ImageChunkEvent? loadingProgress) {
                            //     if (loadingProgress == null) return child;
                            //     return const Center(
                            //       child: CircularProgressIndicator(),
                            //     );
                            //   },
                            // )
                          )
                        : EmptyImageWidget(
                            noImageText: label == 'Address Proof*'
                                ? 'Electricity/Gas Bill'
                                : 'Front',
                          ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    label == 'Aadhaar Card*' || label == 'Driving Licence*',
                child: Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ),
              Visibility(
                visible:
                    label == 'Aadhaar Card*' || label == 'Driving Licence*',
                child: Expanded(
                  flex: 8,
                  child: InkWell(
                    onTap: !isBackDocUploaded || !_isUserVerified!
                        ? () {
                            _showDocumentPickerDialog(backDocType);
                          }
                        : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: inActiveTextColor),
                              borderRadius: BorderRadius.circular(px_5),
                            ),
                            child: isBackDocUploaded &&
                                    _backDocumentInfo != null &&
                                    _backDocumentInfo.link != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(px_5),

                                    child: CachedNetworkImage(
                                      imageUrl: _backDocumentInfo.link!,
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
                                    // Image(
                                    //   image:
                                    //       NetworkImage(_backDocumentInfo.link!),
                                    //   fit: BoxFit.fill,
                                    //   loadingBuilder: (BuildContext context,
                                    //       Widget child,
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
                                    noImageText: 'Back',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
          // Card(
          //   elevation: 3,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
          //             const Icon(Icons.credit_card_outlined),
          //             sizedBoxW10,
          //             Text(
          //               label,
          //               style: const TextStyle(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //           ],
          //         ),
          //         sizedBoxH5,
          //         Row(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 const Text("Upload Status"),
          //                 Text(
          //                   isDocUploaded ? "Uploaded" : "Not uploaded",
          //                   style: TextStyle(
          //                     color: isDocUploaded ? Colors.green : Colors.red,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             if (!isDocUploaded || !_isUserVerified!) ...[
          //               const Spacer(),
          //               sizedBoxH5,
          //               Align(
          //                 alignment: Alignment.centerRight,
          //                 child: PrimaryButton(
          //                   text: isDocUploaded ? "Re-Upload" : "Upload",
          //                   color: AppColors.secondary,
          //                   height: 40,
          //                   width: 90,
          //                   onPressed: () => _showDocumentPickerDialog(docType),
          //                 ),
          //               )
          //             ],
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _getUploadedDocuments() {
    context.read(_documentListProvider.notifier).getRiderDocumentList();
  }

  void _setDocumentStatus(List<Document>? documentList1) {
    if (documentList1 != null) {
      doumentList!.clear();
      doumentList!.addAll(documentList1);
      if (doumentList != null) {
        for (final document in doumentList!) {
          for (final key in _documentUploadStatusMap.keys) {
            if (document.type == key) {
              _documentUploadStatusMap[key] = true;
            }
          }
        }
      }
    }
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
    final bool isSuccess = await showDialog(
      context: context,
      builder: (_) =>
          DocumentUploadingDialog(filePath: path, documentType: docType),
    );
    if (isSuccess) {
      _documentUploadStatusMap[docType] = true;
      _getUploadedDocuments();
// as not much ui there to update no need to handle by consumer
      setState(() {});
    }
  }
}
