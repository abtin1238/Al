import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoriteLocation {
  final String name;
  final double lat;
  final double lng;

  FavoriteLocation({required this.name, required this.lat, required this.lng});
}

class FavoriteLocationsSheet extends StatefulWidget {
  final Function(FavoriteLocation) onLocationSelected;

  const FavoriteLocationsSheet({super.key, required this.onLocationSelected});

  @override
  State<FavoriteLocationsSheet> createState() => _FavoriteLocationsSheetState();
}

class _FavoriteLocationsSheetState extends State<FavoriteLocationsSheet> {
  late Box _box;
  List<FavoriteLocation> favorites = [];

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('favorites');
    _loadFavorites();
  }

  void _loadFavorites() {
    final List data = _box.get('list', defaultValue: []);
    favorites = data
        .map((e) => FavoriteLocation(
              name: e['name'],
              lat: e['lat'],
              lng: e['lng'],
            ))
        .toList();
    setState(() {});
  }

  Future<void> _addFavorite() async {
    if (_nameCtrl.text.isEmpty ||
        _latCtrl.text.isEmpty ||
        _lngCtrl.text.isEmpty) return;

    final newLoc = {
      'name': _nameCtrl.text,
      'lat': double.tryParse(_latCtrl.text) ?? 0,
      'lng': double.tryParse(_lngCtrl.text) ?? 0,
    };

    final List current = _box.get('list', defaultValue: []);
    current.add(newLoc);
    await _box.put('list', current);

    _nameCtrl.clear();
    _latCtrl.clear();
    _lngCtrl.clear();

    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('مکان‌های مورد علاقه', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // فرم افزودن مکان جدید
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'نام مکان'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _latCtrl,
                  decoration: const InputDecoration(labelText: 'عرض جغرافیایی'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lngCtrl,
                  decoration: const InputDecoration(labelText: 'طول جغرافیایی'),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: _addFavorite,
              ),
            ],
          ),

          const Divider(height: 24),

          // لیست مکان‌ها
          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final loc = favorites[index];
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(loc.name),
                  subtitle: Text('${loc.lat}, ${loc.lng}'),
                  onTap: () {
                    widget.onLocationSelected(loc);
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final List current = _box.get('list', defaultValue: []);
                      current.removeAt(index);
                      await _box.put('list', current);
                      _loadFavorites();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}