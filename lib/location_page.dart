import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  String? _currentAdress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text("Geolocation"),
              content: const Text("Please enable location service"),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: const Text("Ok")
                )
              ],
            );
          }
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied){
      AlertDialog(
        title: const Text("Geolocation"),
        content: const Text("Please accept location permission"),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: const Text("Ok")
          )
        ],
      );
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async{
    final hasPermission = await _handleLocationPermission();
    if(!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).
      then((Position position){
        setState(() {
          _currentPosition = position;
        });
        _getAddressFromLatLong(_currentPosition);
    }).catchError((e){
       debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLong(Position? position) async{
    await placemarkFromCoordinates(position!.latitude, position.longitude).
    then((List<Placemark> placemarks){
      Placemark place = placemarks[0];
      setState(() {
        _currentAdress = " ${place.subLocality}, ${place.country}";
      });
    }).catchError((e){
      debugPrint("Error fetching placemarks: ${e.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("GPS Location"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Latitude: ${_currentPosition?.latitude ?? ""}"),
            Text("Longitude: ${_currentPosition?.longitude ?? ""}"),
            Text("Altitude: ${_currentPosition?.altitude ?? ""}"),
            Text("Accuracy: ${_currentPosition?.accuracy ?? ""}"),
            Text("Speed: ${_currentPosition?.speed ?? ""}"),
            Text("Address: ${_currentAdress ?? ""}"),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: _getCurrentPosition,
                child: const Text("Get Location")
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
