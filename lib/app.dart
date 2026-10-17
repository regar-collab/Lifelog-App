import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/core/constants/app_constants.dart';
import 'package:lifelog/core/router/app_router.dart';
import 'package:lifelog/core/theme/app_theme.dart';
import 'package:lifelog/data/services/reminder_service.dart';
import 'package:lifelog/data/services/share_intent_service.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/schedule/application/schedule_providers.dart';
import 'package:lifelog/features/steps/application/step_tracker.dart';

class LifelogApp extends ConsumerStatefulWidget {
  const LifelogApp({super.key});

  @override
  ConsumerState<LifelogApp> createState() => _LifelogAppState();
}

class _LifelogAppState extends ConsumerState<LifelogApp> {
  ShareIntentService? _shareIntent;

  @override
  void initState() {
    super.initState();
    // 首帧之后再启动这些后台服务，确保数据库和 Provider 都已就绪
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repository = ref.read(inboxRepositoryProvider);
      _shareIntent = ShareIntentService(repository)..start();

      // 计步：跟着 App 启动就跑，这样全天步数才连续。
      // 它自己会申请「身体活动」权限，被拒也只是不计数，不影响其它功能。
      ref.read(stepTrackerProvider.notifier).start();

      // 日程提醒：监听日程表变化，自动维护定时通知。
      final scheduleDao = ref.read(scheduleDaoProvider);
      try {
        await ReminderService.instance.start(scheduleDao);
      } catch (_) {
        // 提醒初始化失败不影响其它功能
      }
    });
  }

  @override
  void dispose() {
    _shareIntent?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      // 日程模块要用日期/时间选择器，必须挂中文代理，否则弹出来是英文
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      locale: const Locale('zh', 'CN'),
    );
  }
}
