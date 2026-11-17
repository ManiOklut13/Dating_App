// ─────────────────────────────────────────────────────────────────────────────
// Meetup Spot Card (Offline-only)
// Uses flutter_map + OpenStreetMap tiles (URL configurable)
// Nominatim place search with debounce
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan_date_model.dart';
import '../providers/plan_date_providers.dart';
import '../repository/plan_date_repository.dart';
import '../plan_date_theme.dart';

class MeetupSpotCard extends ConsumerStatefulWidget {
  final DateSpot? spot;
  final ValueChanged<DateSpot> onSpotSelected;
  final VoidCallback onClearSpot;

  const MeetupSpotCard({
    super.key,
    required this.spot,
    required this.onSpotSelected,
    required this.onClearSpot,
  });

  @override
  ConsumerState<MeetupSpotCard> createState() => _MeetupSpotCardState();
}

class _MeetupSpotCardState extends ConsumerState<MeetupSpotCard> {
  final TextEditingController _searchCtrl = TextEditingController();
  final MapController _mapCtrl = MapController();

  // Default to Mumbai city centre
  static const LatLng _defaultCenter = LatLng(19.076, 72.877);

  // Suggested spot chips
  static const _suggestions = ['Café', 'Park', 'Restaurant', 'Museum', 'Cinema'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _recenter() {
    // In production: use geolocator to get real position.
    // Here we animate to default center as placeholder.
    _mapCtrl.move(_defaultCenter, 14);
  }

  Future<void> _openDirections(DateSpot spot) async {
    final uri = Uri.parse(
      'https://maps.google.com/?q=${spot.lat},${spot.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(placeSearchProvider);
    final spot = widget.spot;
    final center = spot != null
        ? LatLng(spot.lat, spot.lng)
        : _defaultCenter;

    return Container(
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Meetup Spot', style: PDTextStyles.sectionTitle),
          ),
          const SizedBox(height: 12),

          // ── Search field ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _searchField(),
          ),
          const SizedBox(height: 8),

          // ── Search results ────────────────────────────────────────────────
          searchState.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LinearProgressIndicator(color: PDColors.textAccent),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('Search failed', style: PDTextStyles.muted.copyWith(color: PDColors.textAccent)),
            ),
            data: (results) {
              if (results.isEmpty) return const SizedBox.shrink();
              return Column(
                children: results.map((r) => _resultTile(r)).toList(),
              );
            },
          ),

          // ── Map ───────────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(0),
              bottom: Radius.circular(PDRadius.card),
            ),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: PlanDateConfig.osmTileUrl,
                        userAgentPackageName: 'app.younme.mobile',
                        // Attribution is shown separately below
                      ),
                      MarkerLayer(
                        markers: [
                          // My pin
                          _buildMarker(_defaultCenter, PDColors.pinMe, Icons.person),
                          // Partner pin (slightly offset)
                          _buildMarker(
                            LatLng(_defaultCenter.latitude + 0.002, _defaultCenter.longitude + 0.002),
                            PDColors.pinPartner,
                            Icons.favorite,
                          ),
                          // Selected spot pin
                          if (spot != null)
                            _buildMarker(
                              LatLng(spot.lat, spot.lng),
                              PDColors.pinSpot,
                              Icons.place,
                            ),
                        ],
                      ),
                      // Dashed lines (PolylineLayer)
                      if (spot != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [_defaultCenter, LatLng(spot.lat, spot.lng)],
                              color: PDColors.pinMe.withValues(alpha: 0.6),
                              strokeWidth: 2.0,
                              pattern: StrokePattern.dotted(spacingFactor: 2),
                            ),
                            Polyline(
                              points: [
                                LatLng(_defaultCenter.latitude + 0.002, _defaultCenter.longitude + 0.002),
                                LatLng(spot.lat, spot.lng),
                              ],
                              color: PDColors.pinPartner.withValues(alpha: 0.6),
                              strokeWidth: 2.0,
                              pattern: StrokePattern.dotted(spacingFactor: 2),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Recenter button
                  Positioned(
                    bottom: 36,
                    right: 12,
                    child: Semantics(
                      label: 'Re-centre map on my location',
                      button: true,
                      child: InkWell(
                        onTap: _recenter,
                        child: Container(
                          width: kMinTouchTarget,
                          height: kMinTouchTarget,
                          decoration: BoxDecoration(
                            color: PDColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: PDColors.cardBorder),
                            boxShadow: PDShadows.cardShadow,
                          ),
                          child: const Icon(Icons.my_location,
                              color: PDColors.textViolet, size: 20),
                        ),
                      ),
                    ),
                  ),
                  // OSM Attribution
                  const Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Selected spot info card ───────────────────────────────────────
          if (spot != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _selectedSpotInfo(spot),
            ),
          ],

          // ── Suggested chips ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested', style: PDTextStyles.muted),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _suggestions.map((s) {
                    return Semantics(
                      label: 'Search for $s',
                      button: true,
                      child: ActionChip(
                        label: Text(s),
                        onPressed: () {
                          _searchCtrl.text = s;
                          ref.read(placeSearchProvider.notifier).search(s);
                        },
                        backgroundColor: PDColors.inputFill,
                        side: const BorderSide(color: PDColors.cardBorder),
                        labelStyle: PDTextStyles.muted,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: kMinTouchTarget,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: PDColors.inputFill,
        borderRadius: BorderRadius.circular(PDRadius.input),
        border: Border.all(color: PDColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: PDColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: PDTextStyles.body,
              onChanged: (q) =>
                  ref.read(placeSearchProvider.notifier).search(q),
              decoration: const InputDecoration(
                hintText: 'Search for a place...',
                hintStyle: TextStyle(color: PDColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(DateSpot spot) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.place, color: PDColors.pinSpot, size: 20),
      title: Text(spot.name, style: PDTextStyles.body.copyWith(fontSize: 13)),
      subtitle: Text(spot.address, style: PDTextStyles.muted.copyWith(fontSize: 11)),
      tileColor: PDColors.inputFill,
      onTap: () {
        widget.onSpotSelected(spot);
        _searchCtrl.clear();
        ref.read(placeSearchProvider.notifier).search('');
        _mapCtrl.move(LatLng(spot.lat, spot.lng), 15);
      },
    );
  }

  Widget _selectedSpotInfo(DateSpot spot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PDColors.inputFill,
        borderRadius: BorderRadius.circular(PDRadius.control),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.place, color: PDColors.pinSpot, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spot.name, style: PDTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${spot.kind ?? ''} · ${spot.distanceKm?.toStringAsFixed(1) ?? '?'} km',
                  style: PDTextStyles.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Open directions for ${spot.name}',
            button: true,
            child: InkWell(
              onTap: () => _openDirections(spot),
              borderRadius: BorderRadius.circular(PDRadius.chip),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: PDGradients.primary,
                  borderRadius: BorderRadius.circular(PDRadius.chip),
                ),
                child: const Text(
                  'Directions',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(LatLng point, Color color, IconData icon) {
    return Marker(
      point: point,
      width: 36,
      height: 36,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

