import 'package:latlong2/latlong.dart';

/// دسته‌بندی مکان‌ها (POI) مطابق صفحه‌ی جستجو.
enum PlaceCategory {
  home,
  work,
  restaurant,
  cafe,
  shopping,
  hotel,
  park,
  fuel,
  parking,
  hospital,
  pharmacy,
  bank,
  evCharge,
  family,
  friends,
  travel,
  other,
}

/// موجودیت مکان — لایه‌ی دامنه (Clean Architecture).
class Place {
  final String id;
  final String title;
  final String subtitle;
  final LatLng location;
  final PlaceCategory category;
  final double? distanceKm;
  final bool isFavorite;

  const Place({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    this.category = PlaceCategory.other,
    this.distanceKm,
    this.isFavorite = false,
  });

  Place copyWith({bool? isFavorite}) => Place(
        id: id,
        title: title,
        subtitle: subtitle,
        location: location,
        category: category,
        distanceKm: distanceKm,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'lat': location.latitude,
        'lon': location.longitude,
        'category': category.name,
        'isFavorite': isFavorite,
      };

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        location: LatLng(j['lat'] as double, j['lon'] as double),
        category: PlaceCategory.values.firstWhere(
          (e) => e.name == j['category'],
          orElse: () => PlaceCategory.other,
        ),
        isFavorite: (j['isFavorite'] as bool?) ?? false,
      );
}

/// دسته‌ی علاقه‌مندی‌ها (خانه، محل کار، خانواده، ...).
class FavoriteCategory {
  final String id;
  final String name;
  final PlaceCategory icon;
  final int placeCount;

  const FavoriteCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.placeCount,
  });
}
