import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fraazo_delivery/helpers/type_aliases/json.dart';

class FirebaseFirestoreService {
  Future<JsonMap?> getAppVersions() async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance
            .collection("app-versions")
            .doc(const String.fromEnvironment("env", defaultValue: "prod"));
    final DocumentSnapshot<JsonMap> documentSnapshot =
        await documentReference.get();

    return documentSnapshot.data();
  }

  Future<JsonMap?> getAssetManagementConfig() async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance
            .collection("asset-management")
            .doc(const String.fromEnvironment("env", defaultValue: "prod"));
    final DocumentSnapshot<JsonMap> documentSnapshot =
        await documentReference.get();

    return documentSnapshot.data();
  }

  Future<JsonMap?> getCallFeatureConfig() async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance
            .collection("call_feature")
            .doc(const String.fromEnvironment("env", defaultValue: "prod"));
    final DocumentSnapshot<JsonMap> documentSnapshot =
        await documentReference.get();

    return documentSnapshot.data();
  }
}
