import 'package:flutter/material.dart';
import 'package:tastelog_app/view/globalrestaurant.dart';
import 'package:tastelog_app/view/korearestaurant.dart';
import 'package:tastelog_app/view/myrestaurant.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tabController,
        children: const [
          MyRestaurant(),
          // KoreaRestaurant(),
          GlobalRestaurant()
        ]
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: TabBar(
          controller: tabController,
          indicatorPadding: const EdgeInsets.all(2),
          tabs: const [
            Tab(
              icon: Icon(Icons.pin_drop_outlined),
              text: '나의 맛집',
            ),
            // Tab(
            //   icon: Icon(Icons.pin_drop_outlined),
            //   text: '한국의 맛집',
            // ),
            Tab(
              icon: Icon(Icons.pin_drop_outlined),
              text: '전세계의 맛집',
            ),
          ]
        ),
      ),
    );
  }
}