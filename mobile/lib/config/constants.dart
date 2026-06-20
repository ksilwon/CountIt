import 'package:flutter/foundation.dart';

final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'; // Chrome (web) używa localhost, Android używa 10.0.2.2

const Map<String, String> categoryEmoji = {
  'jedzenie': '🍕',
  'transport': '🚗',
  'mieszkanie': '🏠',
  'rozrywka': '🎉',
  'zakupy': '🛒',
  'podroze': '✈️',
  'inne': '📦',
};

const Map<String, String> statusLabel = {
  'PENDING': 'Do oddania',
  'CLAIMED': 'Oznaczono jako oddane',
  'CONFIRMED': 'Potwierdzone',
  'REJECTED': 'Odrzucone',
};

const Map<String, String> statusEmoji = {
  'PENDING': '🔴',
  'CLAIMED': '🟡',
  'CONFIRMED': '✅',
  'REJECTED': '❌',
};

class CityLocation {
  final String name;
  final double latitude;
  final double longitude;

  const CityLocation(this.name, this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CityLocation && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

const List<CityLocation> cityLocations = [
  CityLocation('Warszawa', 52.2297, 21.0122),
  CityLocation('Kraków', 50.0647, 19.9450),
  CityLocation('Gdańsk', 54.3520, 18.6466),
  CityLocation('Wrocław', 51.1079, 17.0385),
  CityLocation('Poznań', 52.4064, 16.9252),
  CityLocation('Łódź', 51.7592, 19.4560),
  CityLocation('Katowice', 50.2649, 19.0238),
  CityLocation('Lublin', 51.2465, 22.5684),
];
