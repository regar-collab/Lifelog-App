import 'package:flutter/material.dart';

/// 左侧时间坐标轴。
///
/// 这是整个周视图的「尺子」：只画刻度和时间文字，不带背景块 ——
/// 刻意不用课表那种一格一格的网格，让右边的日程能按真实时刻连续定位。
class TimeAxis extends StatelessWidget {
  const TimeAxis({
    super.key,
    required this.hourHeight,
    required this.width,
    this.startHour = 0,
    this.endHour = 24,
  });

  final double hourHeight;
  final double width;
  final int startHour;
  final int endHour;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int hours = endHour - startHour;

    return SizedBox(
      width: width,
      height: hours * hourHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i <= hours; i++)
            Positioned(
              top: i * hourHeight - 7,
              right: 10,
              child: Text(
                '${(startHour + i).toString().padLeft(2, '0')}:00',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 10,
                  height: 1.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
