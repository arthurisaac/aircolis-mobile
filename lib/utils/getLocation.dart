import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class GetLocation {
  double latitude;
  double longitude;
  String cityCode;
  //Get current location
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permantly denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error(
              'Location permissions are denied (actual value: $permission).');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      latitude = position.latitude;
      longitude = position.longitude;

      cityCode = await getCityName(position.latitude, position.longitude);
    } catch (e) {
      print(e);
    }
  }

  //Get current best location
  Future<void> getCurrentLocationBest() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permantly denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error(
              'Location permissions are denied (actual value: $permission).');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      latitude = position.latitude;
      longitude = position.longitude;

      cityCode = await getCityName(position.latitude, position.longitude);
    } catch (e) {
      print(e);
    }
  }

  Future<String> getCityName(double lat, double lon) async {
    final coordinates = Coordinates(lat, lon);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    return first.countryCode;
  }
}
