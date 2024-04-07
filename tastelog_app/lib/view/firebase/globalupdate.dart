import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class GlobalUpdate extends StatefulWidget {
  const GlobalUpdate({super.key});

  @override
  State<GlobalUpdate> createState() => _GlobalUpdateState();
}

class _GlobalUpdateState extends State<GlobalUpdate> {
  
  var argument = Get.arguments;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController estimateController;
  late double latData; // 위도
  late double longData; // 경도

  // Gallery에서 사진 가져오기
  ImagePicker picker = ImagePicker();
  XFile? imageFile;
  File? imgFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    estimateController = TextEditingController();
    alreadyExistData();
  }

  alreadyExistData() {
    nameController.text = argument.name;
    phoneController.text = argument.phone;
    estimateController.text = argument.estimate;

    latData = argument.lat;
    longData = argument.long;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Row(
            children: [
                Text(
                  "    World-wide Taste Log 수정 " ,
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
        child: GestureDetector(
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
                      ? Image.network(argument.image)
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
                        labelText: '이름을 입력해 주세요',
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
                    onPressed: () async {
                      _showDiaglog();
                    },
                    child: const Text('저장하기')
                  )
                ],
              ),
            ),
          ),
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
      title: '확인',
      middleText: '정말로 수정하시겠습니까?',
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('취소')
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            await _loadingDialog();
            String image = '';
            if(imageFile == null) {
              image = argument.image;
            }
            else {
              image = await preparingImage();
            }

            FirebaseFirestore.instance.collection('musteatplace').doc(argument.id).update({
              'name' : nameController.text,
              'phone' : phoneController.text,
              'estimate' : estimateController.text,
              'image' : image,
            });
            Get.back();
            updateDialog();
          },
          child: const Text('확인')
        ),
      ]
    );
  }

  Future<String> preparingImage() async {
    FirebaseStorage.instance.ref().child('musteatplaceimage').child('${argument.name}_${latData}_${longData}_${argument.initdate}.png').delete();

    final firebaseStorage = FirebaseStorage.instance.ref().child('musteatplaceimage').child('${nameController.text}_${latData}_${longData}_${argument.initdate}.png');
    await firebaseStorage.putFile(imgFile!);

    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }
  

  updateDialog() {
    Get.defaultDialog(
      title: '완료',
      middleText: '맛집 리스트가 수정되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () async {
            Get.back();
            Get.back();
          },
          child: const Text('확인')
        )
      ]
    );
  }

  _loadingDialog() {
    Get.defaultDialog(
      barrierDismissible: false,
      title: '안내',
      middleText: '저장 중 입니다. 잠시만 기다려주세요.',
    );
  }

  

}