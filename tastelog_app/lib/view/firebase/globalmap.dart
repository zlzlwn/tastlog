import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';


class GlobalMap extends StatefulWidget {
  const GlobalMap({super.key});

  @override
  State<GlobalMap> createState() => _GlobalMapState();
}

class _GlobalMapState extends State<GlobalMap> {
  
  late MapController mapController;
  var argument = Get.arguments;
  late LatLng latlng;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    latlng = LatLng(argument.lat, argument.long);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Center(
          child: SizedBox(
            
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "         World-wide Taste Log  " ,
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
                        argument.name,
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