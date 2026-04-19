import 'package:riverpod_craft/riverpod_craft.dart';

part 'countries_provider.craft.dart';

@provider
List<String> featuredCountry(Ref ref) => [
  '🇺🇸 United States',
  '🇬🇧 United Kingdom',
  '🇫🇷 France',
  '🇩🇪 Germany',
  '🇯🇵 Japan',
  '🇰🇷 South Korea',
  '🇧🇷 Brazil',
  '🇨🇦 Canada',
  '🇦🇺 Australia',
  '🇮🇳 India',
];

@provider
Future<List<String>> countries(Ref ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return [
    '🇺🇸 United States',
    '🇬🇧 United Kingdom',
    '🇫🇷 France',
    '🇩🇪 Germany',
    '🇯🇵 Japan',
    '🇰🇷 South Korea',
    '🇧🇷 Brazil',
    '🇨🇦 Canada',
    '🇦🇺 Australia',
    '🇮🇳 India',
    '🇮🇹 Italy',
    '🇪🇸 Spain',
    '🇲🇽 Mexico',
    '🇳🇱 Netherlands',
    '🇸🇪 Sweden',
    '🇨🇭 Switzerland',
  ];
}

@provider
Paged<String> countriesPaged(Ref ref, int page) async {
  await Future.delayed(const Duration(seconds: 2));

  final allCountries = [
    '🇺🇸 United States',
    '🇬🇧 United Kingdom',
    '🇫🇷 France',
    '🇩🇪 Germany',
    '🇯🇵 Japan',
    '🇰🇷 South Korea',
    '🇧🇷 Brazil',
    '🇨🇦 Canada',
    '🇦🇺 Australia',
    '🇮🇳 India',
    '🇮🇹 Italy',
    '🇪🇸 Spain',
    '🇲🇽 Mexico',
    '🇳🇱 Netherlands',
    '🇸🇪 Sweden',
    '🇨🇭 Switzerland',
    '🇳🇴 Norway',
    '🇩🇰 Denmark',
    '🇫🇮 Finland',
    '🇵🇹 Portugal',
    '🇦🇷 Argentina',
    '🇨🇱 Chile',
    '🇨🇴 Colombia',
    '🇿🇦 South Africa',
    '🇪🇬 Egypt',
    '🇳🇬 Nigeria',
    '🇹🇷 Turkey',
    '🇸🇦 Saudi Arabia',
    '🇦🇪 UAE',
    '🇮🇱 Israel',
    '🇸🇬 Singapore',
    '🇹🇭 Thailand',
    '🇻🇳 Vietnam',
    '🇮🇩 Indonesia',
    '🇵🇭 Philippines',
    '🇲🇾 Malaysia',
    '🇳🇿 New Zealand',
    '🇵🇱 Poland',
    '🇨🇿 Czech Republic',
    '🇦🇹 Austria',
    '🇧🇪 Belgium',
    '🇮🇪 Ireland',
    '🇬🇷 Greece',
    '🇺🇦 Ukraine',
    '🇷🇴 Romania',
    '🇭🇺 Hungary',
    '🇵🇪 Peru',
    '🇪🇨 Ecuador',
    '🇨🇷 Costa Rica',
    '🇵🇦 Panama',
    '🇯🇲 Jamaica',
    '🇰🇪 Kenya',
    '🇬🇭 Ghana',
    '🇲🇦 Morocco',
    '🇹🇳 Tunisia',
    '🇵🇰 Pakistan',
    '🇧🇩 Bangladesh',
    '🇱🇰 Sri Lanka',
    '🇳🇵 Nepal',
    '🇲🇲 Myanmar',
  ];

  const pageSize = 20;
  const lastPage = 3;
  final start = (page - 1) * pageSize;
  final end = start + pageSize;
  final results = allCountries.sublist(
    start,
    end.clamp(0, allCountries.length),
  );

  return PaginatedResponse(
    results: results,
    currentPage: page,
    total: allCountries.length,
    lastPage: lastPage,
  );
}
