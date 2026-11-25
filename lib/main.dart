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
        title: 'Info Cuaca - Responsi 2',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2193b0),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8FB),
          cardColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF6F8FB),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
