import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationManager {
  Future<Position?> getCurrentLocation() async {
    try {
      final permissionStatus = await Permission.location.request();

      if (permissionStatus.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        return position;
      } else {
        return null; // Location permission not granted
      }
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}
