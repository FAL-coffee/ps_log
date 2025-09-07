import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:url_launcher/url_launcher.dart';

/// ページ: 近隣ホール検索
class HallSearchPage extends StatefulWidget {
  const HallSearchPage({super.key, required this.apiKey});
  final String apiKey;

  @override
  State<HallSearchPage> createState() => _HallSearchPageState();
}

class _HallSearchPageState extends State<HallSearchPage> {
  late GoogleMapsPlaces _places;
  final List<PlacesSearchResult> _results = [];
  final Set<String> _favorites = {};
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: widget.apiKey);
    _searchNearby();
  }

  Future<void> _searchNearby([String keyword = 'パチンコ']) async {
    try {
      final response = await _places.searchNearbyWithRadius(
        Location(lat: 35.6812, lng: 139.7671),
        1500,
        keyword: keyword,
        type: 'establishment',
      );
      setState(() {
        _results
          ..clear()
          ..addAll(response.results);
      });
    } catch (e) {
      debugPrint('検索に失敗しました: $e');
    }
  }

  void _toggleFavorite(String placeId) {
    setState(() {
      if (_favorites.contains(placeId)) {
        _favorites.remove(placeId);
      } else {
        _favorites.add(placeId);
      }
    });
  }

  @override
  void dispose() {
    _places.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホール検索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      labelText: 'キーワード',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchNearby(_queryController.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final r = _results[index];
                final isFav = _favorites.contains(r.placeId);
                return ListTile(
                  title: Text(r.name ?? ''),
                  subtitle: Text(r.vicinity ?? ''),
                  trailing: IconButton(
                    icon: Icon(isFav ? Icons.star : Icons.star_border),
                    onPressed: () => _toggleFavorite(r.placeId),
                  ),
                  onTap: () async {
                    final detail = await _places.getDetailsByPlaceId(r.placeId);
                    if (!detail.isOkay || detail.result == null) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HallDetailPage(
                          place: detail.result!,
                          isFavorite: isFav,
                          onFavoriteChanged: (v) {
                            if (v) {
                              _favorites.add(r.placeId);
                            } else {
                              _favorites.remove(r.placeId);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ページ: ホール詳細
class HallDetailPage extends StatefulWidget {
  const HallDetailPage({
    super.key,
    required this.place,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  final PlaceDetails place;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;

  @override
  State<HallDetailPage> createState() => _HallDetailPageState();
}

class _HallDetailPageState extends State<HallDetailPage> {
  late bool _fav;
  final List<String> _machines = [];

  @override
  void initState() {
    super.initState();
    _fav = widget.isFavorite;
  }

  void _addMachine() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('機種を追加'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '機種名'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  setState(() => _machines.add(name));
                }
                Navigator.pop(context);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.place.geometry?.location;
    final latLng = LatLng(loc?.lat ?? 0, loc?.lng ?? 0);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name ?? '店舗詳細'),
        actions: [
          IconButton(
            icon: Icon(_fav ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() => _fav = !_fav);
              widget.onFavoriteChanged(_fav);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.place.formattedAddress != null)
            ListTile(
              title: const Text('住所'),
              subtitle: Text(widget.place.formattedAddress!),
            ),
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
              markers: {
                Marker(markerId: const MarkerId('hall'), position: latLng),
              },
            ),
          ),
          if (widget.place.openingHours != null)
            ...widget.place.openingHours!.weekdayText
                .map((t) => Text(t))
                .toList(),
          const Divider(),
          ListTile(
            title: const Text('設置機種'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addMachine,
            ),
          ),
          if (_machines.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('機種情報はありません'),
            )
          else
            ..._machines.map((m) => ListTile(title: Text(m))).toList(),
          if (widget.place.website != null)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(widget.place.website!)),
              child: const Text('外部リンク'),
            ),
        ],
      ),
    );
  }
}

