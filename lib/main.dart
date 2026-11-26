import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0284C7),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
