import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:tastelog_app/model/globalrestaurants.dart';
import 'package:tastelog_app/view/firebase/globalinsert.dart';
import 'package:tastelog_app/view/firebase/globalmap.dart';
import 'package:tastelog_app/view/firebase/globalupdate.dart';
import 'package:url_launcher/url_launcher.dart';


class GlobalRestaurant extends StatefulWidget {
  const GlobalRestaurant({super.key});

  @override
  State<GlobalRestaurant> createState() => _GlobalRestaurantState();
}

class _GlobalRestaurantState extends State<GlobalRestaurant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                 Text(
                  "                  World-wide Taste Log  " ,
                  style: TextStyle(
                    fontWeight: FontWeight.normal
                  ),
                ),
                Icon(Icons.food_bank_outlined)
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Get.to(const GlobalInsert());
              },
              icon: const Icon(Icons.add)
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('musteatplace').snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                final musteatplacelist = snapshot.data!.docs;
                  return ListView(
                    children: musteatplacelist.map((e) => buildEatListWidget(e)).toList()
                );
              }
              else {
                return const Center(child: Text('저장된 목록이 없습니다!'),);
              }
            },
          ),
        ),
      ),
    );
  }


  Widget buildEatListWidget(doc) {
    final eatlist = GlobalRestaurants(id :doc.id,name: doc['name'], phone: doc['phone'], lat: doc['lat'], long: doc['lng'], image: doc['image'], estimate: doc['estimate'], initdate: doc['initdate']);

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Get.to(const GlobalUpdate(), arguments: eatlist);
              },
              icon: Icons.edit,
              label: '수정',
              backgroundColor: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
          ]
        ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              FirebaseFirestore.instance.collection('musteatplace').doc(doc.id).delete();
              _deleteDialog();
            },
            icon: Icons.delete_outline,
            label: '삭제',
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ]
      ),
      child: GestureDetector(
        onTap: () => Get.to(const GlobalMap(), arguments: eatlist),
        child: Card(
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.height / 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    eatlist.image!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3 * 1.78,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        eatlist.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width /3 *1.4,
                          height:MediaQuery.of(context).size.height /20,
                          child: Text(
                            "리뷰 : ${eatlist.estimate}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width/3*1.4,
                                        height: MediaQuery.of(context).size.height/13,
                                        child: Text("전화번호: ${eatlist.phone}"))
                                    ],
                                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  _deleteDialog() {
    Get.defaultDialog(
      middleText: '나의 기록이 삭제되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('확인')
        )
      ]
    );
  }
}