import 'dart:convert';
import 'package:flutter/services.dart';

class CityData {
  final String name;
  final String nameJa;
  final double latitude;
  final double longitude;
  final String country;
  final String timezone;

  CityData({
    required this.name,
    required this.nameJa,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.timezone,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      name: json['name'] ?? '',
      nameJa: json['name_ja'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      country: json['country'] ?? '',
      timezone: json['timezone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ja': nameJa,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'timezone': timezone,
    };
  }
}

class CityDataService {
  static List<CityData>? _cities;

  // 都市データを読み込む
  static Future<List<CityData>> loadCities() async {
    if (_cities != null) {
      return _cities!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/cities.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final citiesList = jsonData['cities'] as List<dynamic>;
      
      _cities = citiesList
          .map((cityJson) => CityData.fromJson(cityJson as Map<String, dynamic>))
          .toList();
      
      return _cities!;
    } catch (e) {
      print('都市データの読み込みエラー: $e');
      return [];
    }
  }

  // 都市名で検索
  static Future<CityData?> findCityByName(String name) async {
    final cities = await loadCities();
    return cities.firstWhere(
      (city) => city.name.toLowerCase() == name.toLowerCase() || 
                 city.nameJa == name,
      orElse: () => throw StateError('都市が見つかりません'),
    );
  }

  // 都市名の候補を取得
  static Future<List<String>> getCitySuggestions(String query) async {
    if (query.isEmpty) return [];
    
    final cities = await loadCities();
    final suggestions = <String>[];
    
    for (final city in cities) {
      if (city.name.toLowerCase().contains(query.toLowerCase()) ||
          city.nameJa.contains(query)) {
        suggestions.add(city.nameJa.isNotEmpty ? city.nameJa : city.name);
      }
    }
    
    return suggestions.take(10).toList();
  }

  // お気に入り都市のリストを取得
  static Future<List<CityData>> getFavoriteCities(List<String> cityNames) async {
    final cities = await loadCities();
    final favoriteCities = <CityData>[];
    
    for (final cityName in cityNames) {
      try {
        final city = cities.firstWhere(
          (city) => city.name.toLowerCase() == cityName.toLowerCase() ||
                     city.nameJa == cityName,
        );
        favoriteCities.add(city);
      } catch (e) {
        print('お気に入り都市が見つかりません: $cityName');
      }
    }
    
    return favoriteCities;
  }

  // 都市データをJSON文字列として取得
  static Future<String> getCitiesAsJson() async {
    try {
      final cities = await loadCities();
      final citiesJson = cities.map((city) => city.toJson()).toList();
      return const JsonEncoder.withIndent('  ').convert({
        'cities': citiesJson,
      });
    } catch (e) {
      return 'エラー: $e';
    }
  }
} 