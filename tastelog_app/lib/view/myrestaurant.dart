import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:tastelog_app/view/sqlite/myinsert.dart';
import 'package:tastelog_app/view/sqlite/mymap.dart';
import 'package:tastelog_app/view/sqlite/myupdate.dart';
import 'package:tastelog_app/vm/database_handler.dart';


class MyRestaurant extends StatefulWidget {
  const MyRestaurant({super.key});

  @override
  State<MyRestaurant> createState() => _MyRestaurantState();
}

class _MyRestaurantState extends State<MyRestaurant> {

  late DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "                  My Taste Log  " ,
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
                Get.to(const MyInsert())!.then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.add)
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: handler.queryReview(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            Get.to(const MyUpdate(), 
                            arguments: snapshot.data![index])!.then((value) => setState(() {}));
                          },
                          icon: Icons.edit,
                          label: '수정하기',
                          backgroundColor: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ]
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            _showDiaglog();
                            await handler.deleteReview(snapshot.data![index].seq);
                          },
                          icon: Icons.delete_outline,
                          label: '삭제하기',
                          backgroundColor: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ]
                    ),
                    child: GestureDetector(
                      onTap: () => Get.to(const MyMap(), arguments: [
                        snapshot.data![index].lat,
                        snapshot.data![index].long,
                        snapshot.data![index].name,
                      ]),
                      child: Card(
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width/3,
                              height: MediaQuery.of(context).size.height/6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  snapshot.data![index].image,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width/3*1.78,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data![index].name,
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
                                        width: MediaQuery.of(context).size.width/3*1.4,
                                        height: MediaQuery.of(context).size.height/20,
                                        child: Text(
                                          "리뷰:  ${snapshot.data![index].estimate}",
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
                                        child: Text("전화번호: ${snapshot.data![index].phone}"))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          else {
            return const Center(
              child: Text(
                '저장된 목록이 없습니다!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              )
            );
          }
        },
      ),
    );
  }


  _showDiaglog() {
    Get.defaultDialog(
      title: "",
      middleText: '나의 기록이 삭제되었습니다.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Get.back();
            setState(() {});
          },
          child: const Text('확인')
        )
      ]
    );
  }
}