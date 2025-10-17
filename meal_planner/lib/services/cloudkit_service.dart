import 'package:cloud_kit/cloud_kit.dart';

class CloudKitService {
  final CloudKit _cloudKit;

  CloudKitService(String containerId) : _cloudKit = CloudKit(containerId);

  Future<void> saveValue(String key, String value) async {
    await _cloudKit.set(key, value);
  }

  Future<String?> getValue(String key) async {
    return await _cloudKit.get(key);
  }

  Future<void> deleteValue(String key) async {
    await _cloudKit.delete(key);
  }
}
