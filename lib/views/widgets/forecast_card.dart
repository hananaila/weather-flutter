import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_codes.dart';

class ForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final int index;
  final bool isGlassmorphic;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.index,
    this.isGlassmorphic = false,
  });

  String _formatDate(String dateStr) {
    if (index == 0) return 'Hari ini';
    if (index == 1) return 'Besok';

    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, d MMM', 'id_ID').format(date);
    } catch (_) {
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('EEE, d MMM').format(date);
      } catch (_) {
        return dateStr;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeHelper.getCondition(forecast.weatherCode);

    if (isGlassmorphic) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: index == 0
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: index == 0
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(forecast.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    condition.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              condition.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            if (forecast.precipitationProbability > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop, size: 11, color: Color(0xFF7DD3FC)),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast.precipitationProbability}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7DD3FC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              flex: 2,
              child: Text(
                '${forecast.maxTemp.round()}° / ${forecast.minTemp.round()}°',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Clean Floating White Card (Sky Blue Theme)
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: index == 0
            ? const Color(0xFFF0F9FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: index == 0
              ? const Color(0xFF7DD3FC)
              : const Color(0xFFE2E8F0),
          width: index == 0 ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day & Condition
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(forecast.date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: index == 0
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  condition.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Weather Icon in circle badge
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: condition.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              condition.icon,
              color: condition.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Rain probability badge
          if (forecast.precipitationProbability > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop, size: 11, color: Color(0xFF0284C7)),
                  const SizedBox(width: 2),
                  Text(
                    '${forecast.precipitationProbability}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Max / Min Temp
          Expanded(
            flex: 2,
            child: Text(
              '${forecast.maxTemp.round()}° / ${forecast.minTemp.round()}°',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
