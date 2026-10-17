import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifelog/core/router/home_shell.dart';
import 'package:lifelog/features/ai_chat/presentation/ai_chat_page.dart';
import 'package:lifelog/features/ai_chat/presentation/ai_chat_settings_page.dart';
import 'package:lifelog/features/ai_organize/presentation/organize_page.dart';
import 'package:lifelog/features/inbox/presentation/inbox_compose_page.dart';
import 'package:lifelog/features/inbox/presentation/inbox_page.dart';
import 'package:lifelog/features/schedule/presentation/schedule_edit_page.dart';
import 'package:lifelog/features/schedule/presentation/schedule_page.dart';
import 'package:lifelog/features/settings/presentation/settings_page.dart';
import 'package:lifelog/features/track/presentation/track_health_page.dart';
import 'package:lifelog/features/track/presentation/track_page.dart';

/// 全局路由表。
///
/// 四个 Tab 挂在 [StatefulShellRoute] 下（各自独立栈，切 Tab 不重建）；
/// 设置页和「记一笔」是顶层路由，会盖住底部导航栏。
final GoRouter appRouter = GoRouter(
  initialLocation: '/inbox',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) => HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/inbox', builder: (_, _) => const InboxPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/organize', builder: (_, _) => const OrganizePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/ai', builder: (_, _) => const AiChatPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/schedule', builder: (_, _) => const SchedulePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/track', builder: (_, _) => const TrackPage()),
          ],
        ),
      ],
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
    GoRoute(
      path: '/ai/settings',
      builder: (_, _) => const AiChatSettingsPage(),
    ),
    GoRoute(
      path: '/compose',
      builder: (BuildContext context, GoRouterState state) {
        final String? id = state.uri.queryParameters['id'];
        return InboxComposePage(itemId: id == null ? null : int.tryParse(id));
      },
    ),
    GoRoute(path: '/track/health', builder: (_, _) => const TrackHealthPage()),
    GoRoute(path: '/schedule/new', builder: (_, _) => const ScheduleEditPage()),
    GoRoute(
      path: '/schedule/edit',
      builder: (BuildContext context, GoRouterState state) {
        final String? id = state.uri.queryParameters['id'];
        return ScheduleEditPage(scheduleId: int.tryParse(id ?? ''));
      },
    ),
  ],
);
