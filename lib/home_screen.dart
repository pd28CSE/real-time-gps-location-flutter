import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationData? locationData;
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      PermissionStatus requestPermissionStatus =
          await Location.instance.requestPermission();

      PermissionStatus hasPermissionStatus =
          await Location.instance.hasPermission();
      if (requestPermissionStatus == PermissionStatus.granted ||
          hasPermissionStatus == PermissionStatus.granted) {
        await configLocationSetting();
        await getCurrentLocation();
      } else {
        log('Permission Denied.');
        if (mounted) {
          SystemNavigator.pop();
        }
      }
    });
  }

  Future<void> configLocationSetting() async {
    await Location.instance.changeSettings(
      distanceFilter: 10,
      accuracy: LocationAccuracy.high,
      interval: 1000, //? 1 second
    );
  }

  Future<void> getCurrentLocation() async {
    locationData = await Location.instance.getLocation();
    if (mounted) {
      setState(() {});
    }
  }

  void listenToCurrentLocation() {
    _locationSubscription =
        Location.instance.onLocationChanged.listen((location) {
      // if (location != locationData) {
      locationData = location;
      log(location.toString());
      if (mounted) {
        setState(() {});
      }
      //  }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GPS Location'),
        actions: [
          IconButton(
            tooltip: 'Stop Live Location',
            onPressed: () {
              _locationSubscription?.cancel();
            },
            icon: const Icon(Icons.stop),
          )
        ],
      ),
      body: Center(
        child: Text(
          '${locationData?.latitude} | ${locationData?.longitude}',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: listenToCurrentLocation,
        tooltip: 'find your location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
