//menu.jsonに代わるもの

/// Data container for the Section loaded in [MenuData.loadFromBundle()].
class IndexEras {
  List<Map<String, dynamic>> eras = [
    {'label': 'Billion', 'eraStart': -15000000000, 'eraEnd': -1000000000},
    {'label': 'Million', 'eraStart': -1000000000, 'eraEnd': -1000000},
    {'label': 'Thousand', 'eraStart': -1000000, 'eraEnd': -5000},
    {'label': 'Historical', 'eraStart': -5000, 'eraEnd': 1900},
    {'label': '20 Century', 'eraStart': 1901, 'eraEnd': 2000},
    {'label': '21 Century', 'eraStart': 2001, 'eraEnd': 2100},
  ];

  IndexEras();

}