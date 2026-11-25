import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_codes.dart';

class ForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final int index;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.index,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: index == 0
              ? condition.color.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.12),
          width: index == 0 ? 1.5 : 1,
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
                  style: TextStyle(
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: index == 0 ? Theme.of(context).primaryColor : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  condition.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            condition.icon,
            color: condition.color,
            size: 26,
          ),
          const SizedBox(width: 12),
          if (forecast.precipitationProbability > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop, size: 11, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text(
                    '${forecast.precipitationProbability}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
