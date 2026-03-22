import 'package:flutter/material.dart';
import 'package:movie_list/models/media_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_list/screens/home_screen.dart';
import 'package:movie_list/services/hive_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:movie_list/services/backup_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TypeOfMediaAdapter());
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(MediaStatusAdapter());
  final hiveService = HiveService();
  await hiveService.init();
  await Permission.ignoreBatteryOptimizations.request();

  // inizializza timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Rome'));

  // inizializza notifiche
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // richiedi permesso notifiche
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'release_channel',
          'Uscite',
          description: 'Notifiche per i media in uscita',
          importance: Importance.high,
        ),
      );

  runApp(MainApp(hiveService: hiveService));
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'weeklyBackup',
    'weeklyBackup',
    frequency: const Duration(days: 7),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  await Workmanager().registerPeriodicTask(
    'dailyCheck',
    'dailyCheck',
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'weeklyBackup') {
      await Hive.initFlutter();
      Hive.registerAdapter(TypeOfMediaAdapter());
      Hive.registerAdapter(MediaStatusAdapter());
      Hive.registerAdapter(MediaItemAdapter());
      final box = await Hive.openBox<MediaItem>('mediaItems');
      final items = box.values.toList();
      final backupService = BackupService();
      await backupService.createBackup(items);
    }

    return Future.value(true);
  });
}

class MainApp extends StatelessWidget {
  final HiveService hiveService;
  const MainApp({required this.hiveService, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D0D0D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF1A1A1A),
          primary: const Color(0xFF3C3489),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          labelStyle: TextStyle(color: Color(0xFF666666), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          ),
        ),
      ),
      home: HomeScreen(hiveService: hiveService),
    );
  }
}
