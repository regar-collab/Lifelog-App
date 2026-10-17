import 'package:flutter_test/flutter_test.dart';
import 'package:lifelog/core/utils/coordinate.dart';

void main() {
  group('CoordinateConverter', () {
    test('北京 WGS84 转 GCJ-02 后偏移在合理范围内', () {
      const double lat = 39.9042;
      const double lng = 116.4074;

      final LatLng gcj = CoordinateConverter.wgs84ToGcj02(lat, lng);
      final double offset = CoordinateConverter.distanceMeters(
        lat,
        lng,
        gcj.lat,
        gcj.lng,
      );

      // 国内典型的“火星坐标”偏移是几百米，超过 1 公里通常说明公式写错了
      expect(offset, inInclusiveRange(100, 1000));
    });

    test('同一个点距离为 0', () {
      expect(CoordinateConverter.distanceMeters(30, 120, 30, 120), 0);
    });
  });
}
