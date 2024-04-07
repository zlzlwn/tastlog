import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';


class MyMap extends StatefulWidget {
  const MyMap({super.key});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {

  late MapController mapController;
  var argument = Get.arguments;
  late LatLng latlng;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latlng = LatLng(argument[0], argument[1]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width/2,
            child: const Row(
              children: [
                Text(
                  "My Taste Log Map " ,
                  style: TextStyle(
                    fontWeight: FontWeight.normal
                  ),
                ),
                Icon(Icons.food_bank_outlined)
              ],
            ),
          ),
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: latlng,
          initialZoom: 17.0
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 100,
                point: latlng,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Text(
                        argument[2],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Icon(
                      Icons.fmd_good,
                      size: 50,
                      color: Colors.red,
                    )
                  ],
                )
              ),
            ]
          )  
        ]
      ),
    );
  }
}