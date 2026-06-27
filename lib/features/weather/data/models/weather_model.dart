import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.temperature,
    required super.rainTodayMm,
    required super.weatherCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>?;
    final precipitationSum = daily?['precipitation_sum'] as List?;

    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      rainTodayMm: precipitationSum != null && precipitationSum.isNotEmpty
          ? (precipitationSum.first as num).toDouble()
          : (current['precipitation'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }
}
