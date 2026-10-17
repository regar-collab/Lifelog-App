import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 底部四 Tab 的外壳。
///
/// 用 go_router 的 StatefulShellRoute，每个分支各自保留导航栈和滚动位置，
/// 切 Tab 不会重建页面。
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return ActiveTabScope(
      currentIndex: navigationShell.currentIndex,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (int index) {
            // 再次点击当前 Tab 时回到该分支的根页面
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox),
              label: '收集箱',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_fix_high_outlined),
              selectedIcon: Icon(Icons.auto_fix_high),
              label: '整理',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: '日程',
            ),
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: '轨迹',
            ),
          ],
        ),
      ),
    );
  }
}

/// 当前选中的底部 Tab。
///
/// StatefulShellRoute 会把四个分支都保留在树里，即使没显示也会 build。
/// 页面可以据此决定是否创建重量级内容（典型例子：高德地图的 PlatformView，
/// 常驻时会占掉上百 MB 显存）。
class ActiveTabScope extends InheritedWidget {
  const ActiveTabScope({
    super.key,
    required this.currentIndex,
    required super.child,
  });

  final int currentIndex;

  static int of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ActiveTabScope>()
            ?.currentIndex ??
        0;
  }

  @override
  bool updateShouldNotify(ActiveTabScope oldWidget) {
    return oldWidget.currentIndex != currentIndex;
  }
}
