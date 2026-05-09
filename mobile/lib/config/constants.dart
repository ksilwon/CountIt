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
