import 'dart:math' as math;
import 'package:flutter/material.dart';

enum Weather3DType {
  sunRain,
  partlyCloudyNight,
  partlyCloudyDay,
  sunny,
  snowy,
  thunder,
  cloudy,
}

class Weather3DArt extends StatelessWidget {
  final Weather3DType type;
  final double size;

  const Weather3DArt({
    super.key,
    required this.type,
    this.size = 140,
  });

  factory Weather3DArt.fromWeatherCode(int code, {double size = 140}) {
    if (code == 0) {
      return Weather3DArt(type: Weather3DType.sunny, size: size);
    } else if (code == 1 || code == 2) {
      return Weather3DArt(type: Weather3DType.partlyCloudyDay, size: size);
    } else if (code == 3 || code == 45 || code == 48) {
      return Weather3DArt(type: Weather3DType.cloudy, size: size);
    } else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return Weather3DArt(type: Weather3DType.sunRain, size: size);
    } else if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return Weather3DArt(type: Weather3DType.snowy, size: size);
    } else if (code >= 95) {
      return Weather3DArt(type: Weather3DType.thunder, size: size);
    }
    return Weather3DArt(type: Weather3DType.partlyCloudyDay, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: _buildArtwork(size),
      ),
    );
  }

  Widget _buildArtwork(double s) {
    switch (type) {
      case Weather3DType.sunny:
        return _buildSunny(s);
      case Weather3DType.partlyCloudyNight:
        return _buildPartlyCloudyNight(s);
      case Weather3DType.partlyCloudyDay:
        return _buildPartlyCloudyDay(s);
      case Weather3DType.sunRain:
        return _buildSunRain(s);
      case Weather3DType.snowy:
        return _buildSnowy(s);
      case Weather3DType.thunder:
        return _buildThunder(s);
      case Weather3DType.cloudy:
        return _buildCloudy(s);
    }
  }

  // 1. Cute 3D Smiling Golden Sun with Rays
  Widget _buildSunny(double s) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sun rays
        for (int i = 0; i < 8; i++)
          Transform.rotate(
            angle: (i * 45) * math.pi / 180,
            child: Container(
              width: s * 0.1,
              height: s * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(s * 0.05),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD54F).withValues(alpha: 0.8),
                    const Color(0xFFFFB300).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        // Outer glowing orb
        Container(
          width: s * 0.65,
          height: s * 0.65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFF176), Color(0xFFFFB300), Color(0xFFFF8F00)],
              stops: [0.2, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB300).withValues(alpha: 0.45),
                blurRadius: s * 0.18,
                spreadRadius: s * 0.02,
                offset: Offset(0, s * 0.04),
              ),
            ],
          ),
        ),
        // Glossy reflection highlight on top-left of sun
        Positioned(
          top: s * 0.22,
          left: s * 0.26,
          child: Container(
            width: s * 0.2,
            height: s * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(s * 0.1),
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
        // Cute kawaii face: two eyes and a smile
        Positioned(
          top: s * 0.45,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: s * 0.055,
                height: s * 0.075,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D4037),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: s * 0.12),
              Container(
                width: s * 0.055,
                height: s * 0.075,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D4037),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: s * 0.54,
          child: CustomPaint(
            size: Size(s * 0.1, s * 0.05),
            painter: _SmilePainter(color: const Color(0xFF5D4037)),
          ),
        ),
        // Blushing pink cheeks
        Positioned(
          top: s * 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: s * 0.06,
                height: s * 0.03,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(s * 0.02),
                ),
              ),
              SizedBox(width: s * 0.22),
              Container(
                width: s * 0.06,
                height: s * 0.03,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(s * 0.02),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. 3D Puffy Cloud with Golden Sun & Rain Drops
  Widget _buildSunRain(double s) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Sun peeking behind cloud
        Positioned(
          top: s * 0.08,
          left: s * 0.15,
          child: Container(
            width: s * 0.4,
            height: s * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFF59D), Color(0xFFFFCA28), Color(0xFFFF9800)],
                stops: [0.1, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                  blurRadius: s * 0.15,
                  spreadRadius: s * 0.01,
                ),
              ],
            ),
          ),
        ),
        // 3D Puffy Cloud
        Positioned(
          top: s * 0.18,
          left: s * 0.1,
          child: _buildClayCloud(s * 0.8),
        ),
        // Glossy Raindrops (pill capsules with reflection)
        Positioned(
          bottom: s * 0.02,
          left: s * 0.22,
          child: _buildRainPill(s, -25),
        ),
        Positioned(
          bottom: s * 0.06,
          left: s * 0.44,
          child: _buildRainPill(s, -25),
        ),
        Positioned(
          bottom: s * 0.01,
          left: s * 0.65,
          child: _buildRainPill(s, -25),
        ),
      ],
    );
  }

  // 3. 3D Cloud with Crescent Moon & Stars / Wind (Toronto style from reference)
  Widget _buildPartlyCloudyNight(double s) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Crescent purple/indigo moon behind cloud
        Positioned(
          top: s * 0.08,
          right: s * 0.15,
          child: Container(
            width: s * 0.38,
            height: s * 0.38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8E7CEF), Color(0xFF5D3FBD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E7CEF).withValues(alpha: 0.5),
                  blurRadius: s * 0.12,
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: s * 0.28,
                height: s * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF332065).withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ),
        // Wind swirls under cloud
        Positioned(
          bottom: s * 0.06,
          left: s * 0.08,
          child: CustomPaint(
            size: Size(s * 0.84, s * 0.25),
            painter: _WindSwirlPainter(
              color: Colors.white.withValues(alpha: 0.75),
              strokeWidth: s * 0.035,
            ),
          ),
        ),
        // 3D Puffy Cloud on top
        Positioned(
          top: s * 0.18,
          left: s * 0.1,
          child: _buildClayCloud(s * 0.8),
        ),
        // Little cute star dots
        Positioned(
          top: s * 0.15,
          left: s * 0.18,
          child: _buildStarDot(s * 0.05),
        ),
        Positioned(
          top: s * 0.25,
          left: s * 0.12,
          child: _buildStarDot(s * 0.035),
        ),
      ],
    );
  }

  // 4. Partly Cloudy Day: Sun + Cloud
  Widget _buildPartlyCloudyDay(double s) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: s * 0.1,
          right: s * 0.14,
          child: Container(
            width: s * 0.42,
            height: s * 0.42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFF9C4), Color(0xFFFFCA28), Color(0xFFFF9800)],
                stops: [0.1, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                  blurRadius: s * 0.15,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: s * 0.24,
          left: s * 0.1,
          child: _buildClayCloud(s * 0.8),
        ),
      ],
    );
  }

  // 5. Snowy: Cloud + 3D Snowflakes and Wind
  Widget _buildSnowy(double s) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Wind swirl
        Positioned(
          bottom: s * 0.05,
          left: s * 0.15,
          child: CustomPaint(
            size: Size(s * 0.75, s * 0.28),
            painter: _WindSwirlPainter(
              color: const Color(0xFFE0F7FA).withValues(alpha: 0.8),
              strokeWidth: s * 0.035,
            ),
          ),
        ),
        // Cloud
        Positioned(
          top: s * 0.16,
          left: s * 0.1,
          child: _buildClayCloud(s * 0.8),
        ),
        // Cute 3D Snowflakes
        Positioned(
          bottom: s * 0.08,
          left: s * 0.2,
          child: Icon(Icons.ac_unit_rounded, size: s * 0.24, color: Colors.white),
        ),
        Positioned(
          bottom: s * 0.18,
          right: s * 0.12,
          child: Icon(Icons.ac_unit_rounded, size: s * 0.16, color: const Color(0xFFB2EBF2)),
        ),
      ],
    );
  }

  // 6. Thunderstorm: Cloud + Lightning
  Widget _buildThunder(double s) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Darker Puffy Cloud
        Positioned(
          top: s * 0.15,
          left: s * 0.1,
          child: _buildClayCloud(s * 0.8, isDark: true),
        ),
        // Golden Lightning Bolt
        Positioned(
          bottom: s * 0.02,
          left: s * 0.38,
          child: Transform.rotate(
            angle: -0.15,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFEA00).withValues(alpha: 0.7),
                    blurRadius: s * 0.15,
                  ),
                ],
              ),
              child: Icon(
                Icons.flash_on_rounded,
                size: s * 0.38,
                color: const Color(0xFFFFD600),
              ),
            ),
          ),
        ),
        // Raindrops
        Positioned(
          bottom: s * 0.04,
          left: s * 0.18,
          child: _buildRainPill(s * 0.85, -25),
        ),
        Positioned(
          bottom: s * 0.05,
          right: s * 0.18,
          child: _buildRainPill(s * 0.85, -25),
        ),
      ],
    );
  }

  // 7. Cloudy: Multi-layer puffy clouds
  Widget _buildCloudy(double s) {
    return Stack(
      children: [
        Positioned(
          top: s * 0.12,
          left: s * 0.25,
          child: _buildClayCloud(s * 0.65, isDark: true),
        ),
        Positioned(
          top: s * 0.24,
          left: s * 0.08,
          child: _buildClayCloud(s * 0.8),
        ),
      ],
    );
  }

  // Master Claymorphic Cloud Builder
  Widget _buildClayCloud(double width, {bool isDark = false}) {
    final double h = width * 0.58;
    final baseColorTop = isDark ? const Color(0xFFECEFF1) : Colors.white;
    final baseColorBottom = isDark ? const Color(0xFFB0BEC5) : const Color(0xFFE2E8F0);
    final shadowColor = isDark
        ? const Color(0xFF263238).withValues(alpha: 0.35)
        : const Color(0xFF475569).withValues(alpha: 0.25);

    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom base capsule
          Positioned(
            bottom: 0,
            left: width * 0.05,
            child: Container(
              width: width * 0.9,
              height: h * 0.55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(h * 0.3),
                gradient: LinearGradient(
                  colors: [baseColorTop, baseColorBottom],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: width * 0.14,
                    offset: Offset(0, width * 0.08),
                  ),
                ],
              ),
            ),
          ),
          // Large main puff (center-right)
          Positioned(
            top: 0,
            left: width * 0.32,
            child: Container(
              width: h * 0.86,
              height: h * 0.86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.45),
                  radius: 0.9,
                  colors: [baseColorTop, baseColorBottom],
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: width * 0.08,
                    offset: Offset(0, width * 0.04),
                  ),
                ],
              ),
            ),
          ),
          // Medium puff (left)
          Positioned(
            top: h * 0.16,
            left: width * 0.1,
            child: Container(
              width: h * 0.68,
              height: h * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 0.85,
                  colors: [baseColorTop, baseColorBottom],
                ),
              ),
            ),
          ),
          // Glossy highlight on top puff
          Positioned(
            top: h * 0.12,
            left: width * 0.42,
            child: Container(
              width: width * 0.16,
              height: width * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.06),
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3D Glossy Raindrop pill capsule
  Widget _buildRainPill(double s, double angleDeg) {
    return Transform.rotate(
      angle: angleDeg * math.pi / 180,
      child: Container(
        width: s * 0.07,
        height: s * 0.22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(s * 0.04),
          gradient: const LinearGradient(
            colors: [Color(0xFF38EF7D), Color(0xFF11998E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C9FF).withValues(alpha: 0.5),
              blurRadius: s * 0.06,
              offset: Offset(0, s * 0.02),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(s * 0.01),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s * 0.03),
            gradient: const LinearGradient(
              colors: [Color(0xFF80D0C7), Color(0xFF0093E9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarDot(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: s * 1.5,
          ),
        ],
      ),
    );
  }
}

// Smile curve painter for sunny face
class _SmilePainter extends CustomPainter {
  final Color color;
  _SmilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height * 0.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wind swirl wave painter
class _WindSwirlPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _WindSwirlPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.5);
    path1.cubicTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.55,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.45,
    );
    // Loop swirl at end
    path1.arcToPoint(
      Offset(size.width * 0.88, size.height * 0.25),
      radius: Radius.circular(size.width * 0.1),
      clockwise: false,
    );

    final path2 = Path();
    path2.moveTo(size.width * 0.15, size.height * 0.85);
    path2.cubicTo(
      size.width * 0.4,
      size.height * 0.65,
      size.width * 0.65,
      size.height * 0.95,
      size.width * 0.95,
      size.height * 0.7,
    );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
