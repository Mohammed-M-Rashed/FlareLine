// Country Code Helper
// Maps country names to emoji flags for display

class CountryCodeHelper {
  // Map of country names to their emoji flags
  static const Map<String, String> _countryNameToFlag = {
    'Afghanistan': '🇦🇫',
    'Albania': '🇦🇱',
    'Algeria': '🇩🇿',
    'Argentina': '🇦🇷',
    'Armenia': '🇦🇲',
    'Australia': '🇦🇺',
    'Austria': '🇦🇹',
    'Azerbaijan': '🇦🇿',
    'Bahrain': '🇧🇭',
    'Bangladesh': '🇧🇩',
    'Belarus': '🇧🇾',
    'Belgium': '🇧🇪',
    'Brazil': '🇧🇷',
    'Bulgaria': '🇧🇬',
    'Canada': '🇨🇦',
    'Chile': '🇨🇱',
    'China': '🇨🇳',
    'Colombia': '🇨🇴',
    'Croatia': '🇭🇷',
    'Cyprus': '🇨🇾',
    'Czech Republic': '🇨🇿',
    'Denmark': '🇩🇰',
    'Egypt': '🇪🇬',
    'Estonia': '🇪🇪',
    'Finland': '🇫🇮',
    'France': '🇫🇷',
    'Georgia': '🇬🇪',
    'Germany': '🇩🇪',
    'Greece': '🇬🇷',
    'Hungary': '🇭🇺',
    'Iceland': '🇮🇸',
    'India': '🇮🇳',
    'Indonesia': '🇮🇩',
    'Iran': '🇮🇷',
    'Iraq': '🇮🇶',
    'Ireland': '🇮🇪',
    'Israel': '🇮🇱',
    'Italy': '🇮🇹',
    'Japan': '🇯🇵',
    'Jordan': '🇯🇴',
    'Kazakhstan': '🇰🇿',
    'Kuwait': '🇰🇼',
    'Latvia': '🇱🇻',
    'Lebanon': '🇱🇧',
    'Libya': '🇱🇾',
    'Lithuania': '🇱🇹',
    'Luxembourg': '🇱🇺',
    'Malaysia': '🇲🇾',
    'Malta': '🇲🇹',
    'Mexico': '🇲🇽',
    'Morocco': '🇲🇦',
    'Netherlands': '🇳🇱',
    'New Zealand': '🇳🇿',
    'Norway': '🇳🇴',
    'Oman': '🇴🇲',
    'Pakistan': '🇵🇰',
    'Palestine': '🇵🇸',
    'Philippines': '🇵🇭',
    'Poland': '🇵🇱',
    'Portugal': '🇵🇹',
    'Qatar': '🇶🇦',
    'Romania': '🇷🇴',
    'Russia': '🇷🇺',
    'Saudi Arabia': '🇸🇦',
    'Singapore': '🇸🇬',
    'Slovakia': '🇸🇰',
    'Slovenia': '🇸🇮',
    'South Africa': '🇿🇦',
    'South Korea': '🇰🇷',
    'Spain': '🇪🇸',
    'Sri Lanka': '🇱🇰',
    'Sweden': '🇸🇪',
    'Switzerland': '🇨🇭',
    'Syria': '🇸🇾',
    'Thailand': '🇹🇭',
    'Tunisia': '🇹🇳',
    'Turkey': '🇹🇷',
    'Ukraine': '🇺🇦',
    'United Arab Emirates': '🇦🇪',
    'United Kingdom': '🇬🇧',
    'United States': '🇺🇸',
    'Uruguay': '🇺🇾',
    'Venezuela': '🇻🇪',
    'Vietnam': '🇻🇳',
    'Yemen': '🇾🇪',
  };

  /// Get emoji flag from country name (case-insensitive)
  /// Returns null if country name is not found
  static String? getCountryFlag(String countryName) {
    // Try exact match first
    if (_countryNameToFlag.containsKey(countryName)) {
      return _countryNameToFlag[countryName];
    }
    
    // Try case-insensitive match
    final lowerCountryName = countryName.toLowerCase();
    for (final entry in _countryNameToFlag.entries) {
      if (entry.key.toLowerCase() == lowerCountryName) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Check if a country flag exists for the given country name (case-insensitive)
  static bool hasCountryFlag(String countryName) {
    // Try exact match first
    if (_countryNameToFlag.containsKey(countryName)) {
      return true;
    }
    
    // Try case-insensitive match
    final lowerCountryName = countryName.toLowerCase();
    for (final key in _countryNameToFlag.keys) {
      if (key.toLowerCase() == lowerCountryName) {
        return true;
      }
    }
    
    return false;
  }

  /// Get all available country names
  static List<String> getAllCountryNames() {
    return _countryNameToFlag.keys.toList();
  }

  /// Get all available country flags
  static List<String> getAllCountryFlags() {
    return _countryNameToFlag.values.toList();
  }
}
