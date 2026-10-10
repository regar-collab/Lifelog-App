import 'dart:math' as math;

/// 一个经纬度点。
class LatLng {
  const LatLng(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  String toString() =>
      'LatLng(${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)})';

  @override
  bool operator ==(Object other) =>
      other is LatLng && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}

/// WGS84 ⇄ GCJ-02 坐标转换。
///
/// 背景：手机 GPS 芯片给出的是国际标准 WGS84 坐标，而国内地图（高德、腾讯）
/// 用的是国测局加密后的 GCJ-02（俗称「火星坐标」）。两者在国内相差
/// 几百米，直接用 WGS84 在高德地图上画点会整体偏移到隔壁街道。
///
/// 轨迹点两套坐标都存：WGS84 是原始真值（导出 GPX、换地图都靠它），
/// GCJ-02 只用于在高德底图上绘制。
class CoordinateConverter {
  CoordinateConverter._();

  static const double _a = 6378245.0; // 克拉索夫斯基椭球长半轴
  static const double _ee = 0.00669342162296594323; // 偏心率平方

  /// 国境之外不做偏移（境外地图本来就是 WGS84）。
  static bool _outOfChina(double lat, double lng) {
    return lng < 72.004 || lng > 137.8347 || lat < 0.8293 || lat > 55.8271;
  }

  /// WGS84 → GCJ-02
  static LatLng wgs84ToGcj02(double lat, double lng) {
    if (_outOfChina(lat, lng)) return LatLng(lat, lng);

    double dLat = _transformLat(lng - 105.0, lat - 35.0);
    double dLng = _transformLng(lng - 105.0, lat - 35.0);

    final double radLat = lat / 180.0 * math.pi;
    double magic = math.sin(radLat);
    magic = 1 - _ee * magic * magic;
    final double sqrtMagic = math.sqrt(magic);

    dLat = (dLat * 180.0) /
        ((_a * (1 - _ee)) / (magic * sqrtMagic) * math.pi);
    dLng = (dLng * 180.0) /
        (_a / sqrtMagic * math.cos(radLat) * math.pi);

    return LatLng(lat + dLat, lng + dLng);
  }

  /// 两点间距离（米），Haversine 公式。
  ///
  /// 用来算轨迹总里程，也用来做「移动距离过滤」——
  /// 站着不动时 GPS 会飘，不滤掉的话轨迹会变成一团毛线。
  static double distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000.0;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRadians(double deg) => deg * math.pi / 180.0;

  static double _transformLat(double x, double y) {
    double ret = -100.0 +
        2.0 * x +
        3.0 * y +
        0.2 * y * y +
        0.1 * x * y +
        0.2 * math.sqrt(x.abs());
    ret += (20.0 * math.sin(6.0 * x * math.pi) +
            20.0 * math.sin(2.0 * x * math.pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(y * math.pi) +
            40.0 * math.sin(y / 3.0 * math.pi)) *
        2.0 /
        3.0;
    ret += (160.0 * math.sin(y / 12.0 * math.pi) +
            320 * math.sin(y * math.pi / 30.0)) *
        2.0 /
        3.0;
    return ret;
  }

  static double _transformLng(double x, double y) {
    double ret = 300.0 +
        x +
        2.0 * y +
        0.1 * x * x +
        0.1 * x * y +
        0.1 * math.sqrt(x.abs());
    ret += (20.0 * math.sin(6.0 * x * math.pi) +
            20.0 * math.sin(2.0 * x * math.pi)) *
        2.0 /
        3.0;
    ret += (20.0 * math.sin(x * math.pi) +
            40.0 * math.sin(x / 3.0 * math.pi)) *
        2.0 /
        3.0;
    ret += (150.0 * math.sin(x / 12.0 * math.pi) +
            300.0 * math.sin(x / 30.0 * math.pi)) *
        2.0 /
        3.0;
    return ret;
  }
}
