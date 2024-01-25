import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraazo_delivery/helpers/error/error_reporter.dart';
import 'package:fraazo_delivery/models/user/document_list_model.dart';
import 'package:fraazo_delivery/services/api/user/user_service.dart';

class DocumentListProvider extends StateNotifier<AsyncValue<List<Document>?>> {
  DocumentListProvider(
      [AsyncValue<List<Document>> state = const AsyncLoading()])
      : super(state);

  final _userService = UserService();

  Future getRiderDocumentList() async {
    try {
      state = const AsyncLoading();
      final documentList = await _userService.getRiderDocument();
      state = AsyncData(documentList);
    } catch (e, st) {
      state = AsyncError(e, st);
      ErrorReporter.error(
          e, st, "DocumentListProvider: getRiderDocumentList()");
    }
  }
}
