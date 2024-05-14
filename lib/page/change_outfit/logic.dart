import 'dart:convert';

import 'package:get/get.dart';

import '../../helper/pb.dart';
import '../change_outfits/cloth.dart';

class Change_outfitLogic extends GetxController {
  late List<Cloth> clothList=[];
  late List<Cloth> modelList=[];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getData();

  }
  Future getData() async {
    var records = await PB.instance.collection('clothes').getFullList();
    var models_records = await PB.instance.collection('models').getFullList();
    // 反序列化
    List<dynamic> jsonList = json.decode(records.toString());
    List<dynamic> modelsJsonList = json.decode(models_records.toString());
    List<Cloth> clothsList = jsonList.map((json) => Cloth.fromJson(json)).toList();
    List<Cloth> modelsList = modelsJsonList.map((json) => Cloth.fromJson(json)).toList();
    clothList=clothsList;
    modelList=modelsList;
    update();
    // String clothToJson(List<Cloth> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

    print(records);
    print(models_records);
  }


  void selectCloth(int  clothIndex) {
    print(clothIndex);
    clothList.forEach((element) {
      element.selected=false;
    });
    clothList[clothIndex].selected=true;
    update();
  }

  void clearClothSelect(){
    clothList.forEach((element) {
      element.selected=false;
    });
    update();
  }
  void clearModelSelect(){
    modelList.forEach((element) {
      element.selected=false;
    });
    update();
  }
  void selectModels(int index){
    for (var element in modelList) {
      element.selected=false;
    }
    modelList[index].selected=true;
    update();
  }
}
