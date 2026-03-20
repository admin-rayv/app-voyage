import 'package:latlong2/latlong.dart';

import '../models/point.dart' as models;

class PoiDetailRouteData {
  const PoiDetailRouteData({
    required this.poi,
    this.userPosition,
  });

  final models.Point poi;
  final LatLng? userPosition;
}
