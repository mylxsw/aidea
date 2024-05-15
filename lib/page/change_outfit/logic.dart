import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../helper/pb.dart';
import '../change_outfits/cloth.dart';
final dio = Dio();

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

  Future<void> work() async {
    var response;
    String clothUrl="";
    String modelUrl="";
    modelList.forEach((element) {
      if(element.selected){
        modelUrl=element.url;
      }
    });
    clothList.forEach((element) {
      if(element.selected){
        clothUrl=element.url;
      }
    });

    response= await dio.post("https://ott-api.nicegpt.net/work",data: {"models":modelUrl,"clothes":clothUrl});
    print(response);
    // HttpClient().get(,que);
  }
}
