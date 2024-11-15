import 'package:flutter/material.dart';
import 'package:flaviapp/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);
  runApp(const FlaviApp());
}

class FlaviApp extends StatefulWidget {
  const FlaviApp({Key? key}) : super(key: key);

  @override
  _FlaviAppState createState() => _FlaviAppState();
}

class _FlaviAppState extends State<FlaviApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Registro de Migraña',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            cardColor: Colors.red[900], // Color rojo oscuro para el Card
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple, // Color para los íconos en modo oscuro
            ),
          ),
          themeMode: currentMode,
          home: HomeScreen(
            onThemeChanged: (isDarkMode) {
              _themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        );
      },
    );
  }
}