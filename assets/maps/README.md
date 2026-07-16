# Offline Map Sample

- `tehran_sample_manifest.json` — package metadata
- `tehran_sample_graph.json` — road graph for A* offline routing
- `tehran_sample_pois.json` — local POI index for offline search

Tile caching at runtime uses `flutter_map_tile_caching` (download once, then offline).
Bundled graph/POI data work with zero network.
