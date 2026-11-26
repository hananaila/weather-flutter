import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'widgets/weather_3d_art.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF63B4F6), // Soft Sky Cyan
              Color(0xFFA58BEB), // Soft Lilac Purple
              Color(0xFFFDE896), // Soft Sunlight Warm
            ],
            stops: [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Back/Info Button (if navigated from inside app)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                  ],
                ),
              ),

              // Cute 3D Weather Illustration in center
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'weather_hero_art',
                    child: Weather3DArt(
                      type: Weather3DType.sunRain,
                      size: size.width * 0.65,
                    ),
                  ),
                ),
              ),

              // Bottom White Rounded Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 36, 32, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 30,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot Page Indicators (Pill + Dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Title
                    const Text(
                      'Weather App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'Discover the weather in your city and plan your day correctly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Circular Next Arrow Button
                    GestureDetector(
                      onTap: () => _completeOnboarding(context),
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38B6FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0072FF).withValues(alpha: 0.38),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
