import 'dart:typed_data';

/* 
    Description : SQlite의 Model 
    Author 		: Lcy
    Date 			: 2024.04.06
*/

class MyRestaurants {
  int? seq;
  String name;
  String phone;
  double lat;
  double long;
  Uint8List image;
  String estimate;
  String initdate;
  // String updatedate;

  MyRestaurants ({
    this.seq,
    required this.name,
    required this.phone,
    required this.lat,
    required this.long,
    required this.image,
    required this.estimate,
    required this.initdate,
    // required this.updatedate,
  });

  MyRestaurants.fromMap(Map<String, dynamic> res)
    : seq = res['seq'],
      name = res['name'],
      phone = res['phone'],
      lat = res['lat'],
      long = res['long'],
      image = res['image'],
      estimate = res['estimate'],
      initdate = res['initdate'];
      // updatedate = res['updatedate'];

}