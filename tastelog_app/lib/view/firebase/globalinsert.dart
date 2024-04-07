import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class GlobalInsert extends StatefulWidget {
  const GlobalInsert({super.key});

  @override
  State<GlobalInsert> createState() => _GlobalInsertState();
}

class _GlobalInsertState extends State<GlobalInsert> {
  
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  // late Position currentPosition;
  late double latData; // 위도
  late double longData; // 경도
  late bool _isloading;

  // Gallery에서 사진 가져오기
  ImagePicker picker = ImagePicker();
  XFile? imageFile;
  File? imgFile;

  @override
  void initState() {
    super.initState();
    latData = 0;
    longData = 0;
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    checkLocationPermission();

    _isloading = false;
  }

  checkLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  
  // 거절
  if(permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // 다신 사용하지 않음
  if(permission == LocationPermission.deniedForever) {
    return;
  }

  // 앱을 사용 중 or 항상 허용 일때,
  if(permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    getCurrentLocation();
	}
}

  // getCurrentLocation()
  getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true
    ).then((position) {
      latData = position.latitude;
      longData = position.longitude;

      setState(() {});
    }).catchError((e) {
      // print(e);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Row(
            children: [
               Text(
                  "      World-wide Taste Log 입력 " ,
                  style: TextStyle(
                    fontWeight: FontWeight.normal
                  ),
                ),
                Icon(Icons.food_bank_outlined)
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: ElevatedButton(
                          onPressed: () {
                            getImageFromDevice(ImageSource.gallery);
                          },
                          child: const Text('사진 추가하기')
                        ),
                      ),
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/6,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 188, 186, 186),
                          ),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width/3*2,
                          height: 150,
                          child: imageFile == null
                          ? Center(
                              child: Text(
                                '이미지를 선택해 주세요!',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer
                                ),
                              )
                            )
                          : Image.file(File(imageFile!.path)),
                        ),
                      ),
                      Padding( // 위치 (위도 경도)
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                              child: Row(
                                children: [
                                  const Text(
                                   '위도 : '
                                  ),
                                  Text(
                                    '$latData'
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                              child: Row(
                                children: [
                                  const Text(
                                   '경도 : '
                                  ),
                                  Text(
                                    '$longData'
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding( // 이름 textField
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: ' 이름을 입력해 주세요',
                            border: OutlineInputBorder()
                          ),
                        ),
                      ),
                      Padding( // 전화번호 textField
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: '전화번호를 입력해 주세요',
                            border: OutlineInputBorder()
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      Padding( // 평가 textField
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        child: SizedBox(
                          width: 400,
                          height: 150,
                          child: TextField(
                            controller: estimateController,
                            decoration: const InputDecoration(
                              labelText: '리뷰를 작성해 주세요',
                              border: OutlineInputBorder(
                                borderSide: BorderSide()
                              ),
                            ),
                            maxLength: 50,
                            // keyboardType: TextInputType.multiline,
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          insertFirebase();
                        },
                        child: const Text('저장하기')
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getImageFromDevice(imageSource) async {
  final XFile? pickedFile = await picker.pickImage(source: imageSource);
  if(pickedFile == null) {
    imageFile = null;
  }
  else {
    imageFile = XFile(pickedFile.path);
    imgFile = File(imageFile!.path);
  }
  setState(() {});
}

  _showDiaglog() {
    Get.defaultDialog(
      title: '완료',
      middleText: '맛집 리스트가 추가되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('확인')
        )
      ]
    );
  }

  insertFirebase() async {
    setState(() {
      _isloading = true;
      _loadingDialog();
    });

    String time = DateTime.now().toString();
    String imagePath = await preparingImage(time);
    await FirebaseFirestore.instance.collection('musteatplace').add(
      {
        'name' : nameController.text,
        'phone' : phoneController.text,
        'lat' : latData,
        'lng' : longData,
        'image' : imagePath,
        'initdate' : time,
        'estimate' : estimateController.text
      }
    );

    setState(() {
      _isloading = false;
      Get.back();
    });

    _showDiaglog();
  }

  Future<String> preparingImage(String time) async {
    final firebaseStorage = FirebaseStorage.instance.ref().child('musteatplaceimage').child('${nameController.text}_${latData}_${longData}_$time.png');

    await firebaseStorage.putFile(imgFile!);
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  _loadingDialog() {
    if(_isloading) {
      Get.defaultDialog(
        barrierDismissible: false,
        title: '안내',
        middleText: '저장 중 입니다. 잠시만 기다려주세요.',
      );
    }
  }

}