// To parse this JSON data, do
//
//     final cloth = clothFromJson(jsonString);

import 'dart:convert';

List<Cloth> clothFromJson(String str) => List<Cloth>.from(json.decode(str).map((x) => Cloth.fromJson(x)));

String clothToJson(List<Cloth> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cloth {
  String id;
  // DateTime created;
  // DateTime updated;
  String collectionId;
  String collectionName;
  Expand expand;
  String name;
  String url;
  bool selected=false;
  // int selectIndex=-1;

  Cloth({
    required this.id,
    // this.selectIndex,
    required this.collectionId,
    required this.collectionName,
    required this.expand,
    required this.name,
    required this.url,
  });

  factory Cloth.fromJson(Map<String, dynamic> json) => Cloth(
    id: json["id"],
    collectionId: json["collectionId"],
    collectionName: json["collectionName"],
    expand: Expand.fromJson(json["expand"]),
    name: json["name"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "collectionId": collectionId,
    "collectionName": collectionName,
    "expand": expand.toJson(),
    "name": name,
    "url": url,
  };
}

class Expand {
  Expand();

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
  );

  Map<String, dynamic> toJson() => {
  };
}
