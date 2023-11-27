import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:askaide/helper/constant.dart';
import 'package:askaide/helper/helper.dart';
import 'package:askaide/helper/platform.dart';
import 'package:askaide/repo/api_server.dart';
import 'package:askaide/repo/settings_repo.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:isolate_image_compress/isolate_image_compress.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';

class ImageUploader {
  QiniuUploader? _qiniuUploader;

  ImageUploader(SettingRepository setting) {
    _qiniuUploader = QiniuUploader(setting);
  }

  final _compressWidth = 1024;
  final _compressHeight = 1024;

  /// 上传文件
  Future<UploadedFile> upload(String path, {String? usage}) async {
    Uint8List? data = await _imageCompress(path);
    if (data == null || data.isEmpty) {
      throw Exception('图片读取失败');
    }

    return _qiniuUploader!.upload(path, data, usage: usage);
  }

  /// 文件压缩后转为 base64
  Future<String> base64({
    String? path,
    Uint8List? imageData,
    int? compressWidth,
    int? compressHeight,
    int? maxSize,
  }) async {
    if (imageData != null) {
      Uint8List? data = await _imageDataCompress(
        imageData,
        compressWidth: compressWidth,
        compressHeight: compressHeight,
        maxSize: maxSize ?? 1024 * 1024 * 2,
      );
      if (data == null || data.isEmpty) {
        throw Exception('图片读取失败');
      }

      return 'data:image/png;base64,${base64Encode(data)}';
    }

    Uint8List? data = await _imageCompress(
      path!,
      compressWidth: compressWidth,
      compressHeight: compressHeight,
      maxSize: maxSize ?? 1024 * 1024 * 2,
    );
    if (data == null || data.isEmpty) {
      throw Exception('图片读取失败');
    }

    return 'data:image/png;base64,${base64Encode(data)}';
  }

  // 上传文件数据
  Future<UploadedFile> uploadData(Uint8List imageData, {String? usage}) async {
    Uint8List? data = await _imageDataCompress(imageData);
    if (data == null || data.isEmpty) {
      throw Exception('图片读取失败');
    }

    return _qiniuUploader!.upload("${randomId()}.jpg", data, usage: usage);
  }

  Future<Uint8List?> _imageDataCompress(Uint8List imageData,
      {int? compressWidth,
      int? compressHeight,
      int quality = 80,
      int maxSize = 1024 * 1024 * 2}) async {
    Uint8List? data = imageData;
    // 优先使用平台支持的压缩工具
    if (PlatformTool.isAndroid() || PlatformTool.isIOS()) {
      try {
        data = await FlutterImageCompress.compressWithList(
          data,
          quality: quality,
          minWidth: compressWidth ?? _compressWidth,
          minHeight: compressHeight ?? _compressHeight,
        );
      } catch (e) {
        // ignore
      }

      if (data == null || data.isEmpty) {
        try {
          data = await IsolateImage.data(data!).compress(
            maxResolution: ImageResolution(compressWidth ?? _compressWidth,
                compressHeight ?? _compressHeight),
            maxSize: maxSize,
          );
        } catch (e) {
          // ignore
        }
      }
    } else {
      try {
        data = await IsolateImage.data(data).compress(
          maxResolution: ImageResolution(
            compressWidth ?? _compressWidth,
            compressHeight ?? _compressHeight,
          ),
          maxSize: maxSize,
        );
      } catch (e) {
        // ignore
      }
    }

    // 压缩失败，尝试 Dart 内置的图片压缩库
    if (data == null || data.isEmpty) {
      try {
        Image? img = decodeImage(data!);
        if (img != null) {
          Image thumbnail = copyResize(
            img,
            width:
                img.width > img.height ? compressWidth ?? _compressWidth : null,
            height: img.width <= img.height
                ? compressHeight ?? _compressHeight
                : null,
          );

          data = encodeJpg(thumbnail, quality: quality);
        }
      } catch (e) {
        // ignore
      }
    }

    // 再次压缩失败，返回原始数据
    if (data == null || data.isEmpty) {
      data = imageData;
    }

    return data;
  }

  Future<Uint8List?> _imageCompress(String path,
      {int? compressWidth,
      int? compressHeight,
      int quality = 80,
      int maxSize = 1024 * 1024 * 2}) async {
    Uint8List? data;

    // 优先使用平台支持的压缩工具
    if (PlatformTool.isAndroid() || PlatformTool.isIOS()) {
      try {
        data = await FlutterImageCompress.compressWithFile(
          path,
          quality: quality,
          minWidth: compressWidth ?? _compressWidth,
          minHeight: compressHeight ?? _compressHeight,
        );
      } catch (e) {
        // ignore
      }

      if (data == null || data.isEmpty) {
        try {
          data = await IsolateImage.path(path).compress(
            maxResolution: ImageResolution(compressWidth ?? _compressWidth,
                compressHeight ?? _compressHeight),
            maxSize: maxSize,
          );
        } catch (e) {
          // ignore
        }
      }
    } else {
      try {
        data = await IsolateImage.path(path).compress(
          maxResolution: ImageResolution(
            compressWidth ?? _compressWidth,
            compressHeight ?? _compressHeight,
          ),
          maxSize: maxSize,
        );
      } catch (e) {
        // ignore
      }
    }

    // 压缩失败，尝试 Dart 内置的图片压缩库
    if (data == null || data.isEmpty) {
      try {
        Image? img = decodeImage(File(path).readAsBytesSync());
        if (img != null) {
          Image thumbnail = copyResize(
            img,
            width:
                img.width > img.height ? compressWidth ?? _compressWidth : null,
            height: img.width <= img.height
                ? compressHeight ?? _compressHeight
                : null,
          );

          var n = path.toLowerCase();
          if (n.endsWith('.jpg') || n.endsWith('.jpeg')) {
            data = encodeJpg(thumbnail, quality: quality);
          } else if (n.endsWith('.png')) {
            data = encodePng(thumbnail, level: 4);
          } else {
            data = encodeNamedImage(path, thumbnail);
          }
        }
      } catch (e) {
        // ignore
      }
    }

    // 再次压缩失败，返回原始数据
    if (data == null || data.isEmpty) {
      data = await File(path).readAsBytes();
    }
    return data;
  }
}

class UploadedFile {
  final String name;
  final String url;

  UploadedFile(this.name, this.url);
}

class ImglocUploader {
  late final String secretKey;

  ImglocUploader(SettingRepository setting) {
    secretKey = setting.stringDefault(settingImglocToken, '');
  }
  Future<UploadedFile> upload(
    String path,
    Uint8List data, {
    String? usage,
  }) async {
    String imageBase64 = base64.encode(data);

    var resp = await http.post(
      Uri.parse('https://imgloc.com/api/1/upload'),
      headers: <String, String>{
        'X-API-Key': secretKey,
      },
      body: {
        'source': imageBase64,
        'expiration': 'P1D',
        'format': 'json',
        'nsfw': "1",
      },
    );

    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200 || parsed['status_code'] != 200) {
      throw Exception(parsed['status_text'] ?? parsed['error']['message']);
    }

    return UploadedFile(parsed['image']['name'], parsed['image']['url']);
  }
}

class QiniuUploader {
  final SettingRepository setting;

  QiniuUploader(this.setting);

  Future<UploadedFile> upload(
    String path,
    Uint8List data, {
    String? usage,
  }) async {
    try {
      var filename = path.substring(path.lastIndexOf('/') + 1);
      final initResp =
          await APIServer().uploadInit(filename, data.length, usage: usage);

      var storage = Storage(config: Config(retryLimit: 3));

      await storage.putBytes(
        data,
        initResp.token,
        options: PutOptions(
          key: initResp.key,
        ),
      );

      return UploadedFile(filename, initResp.url);
    } catch (ex) {
      return Future.error(ex);
    }
  }
}
