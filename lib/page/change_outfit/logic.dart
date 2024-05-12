import 'dart:convert';

import 'package:get/get.dart';

import '../../helper/pb.dart';
import '../change_outfits/cloth.dart';

class Change_outfitLogic extends GetxController {
  late List<Cloth> clothList=[];
  Future getData() async {
    // Cloth cloth=Cloth(id: "id", collectionId: "collectionId", collectionName: "collectionName", expand: Expand(), name: "name", url: "https://gfs17.gomein.net.cn/T1f.KWBTW_1RCvBVdK_800_pc.jpg");
    // clothList.add(cloth);
    var records = await PB.instance.collection('clothes').getFullList();
    // 反序列化
    List<dynamic> jsonList = json.decode(records.toString());
    List<Cloth> persons = jsonList.map((json) => Cloth.fromJson(json)).toList();
    clothList=persons;
    for (var element in persons) {
      print(element.id);
    }
    print(clothList.length);

    update();
    // String clothToJson(List<Cloth> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

    print(records);
  }
}
