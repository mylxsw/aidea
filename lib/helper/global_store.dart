import 'package:askaide/page/component/chat/file_upload.dart';

class GlobalStore {
  static final GlobalStore _instance = GlobalStore._internal();
  GlobalStore._internal();

  factory GlobalStore() {
    return _instance;
  }

  List<FileUpload> uploadedFiles = [];
}
