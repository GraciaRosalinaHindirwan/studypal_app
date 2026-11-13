
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/components/search_bar.dart' as search;
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/services/location_service.dart';
import 'package:studypal/models/location.dart';

class PickLocationPage extends StatefulWidget {
  final Location? initialLocation;

  const PickLocationPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  // Controller dan service
  final TextEditingController searchController = TextEditingController();
  final LocationService locationService = LocationService();
  final MapController mapController = MapController();

  // Menentukan koordinat awal peta
  LatLng get initialPoint {
    if (widget.initialLocation != null) {
      return LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    }

    return LatLng(-7.7956, 110.3695);
  }

  // Menyimpan koordinat marker saat ini
  late LatLng selectedPoint = initialPoint;

  // Data hasil pencarian
  List<Location> locations = [];

  // Status pencarian
  bool isLoading = false;
  String? errorMessage;

  // Lokasi yang dipilih
  Location? selectedLocation;

  @override
  void initState() {
    super.initState();

    // Mempertahankan lokasi yang sebelumnya dipilih
    selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fungsi mencari lokasi
  Future<void> searchLocation() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        locations = [];
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      selectedLocation = null;
    });

    try {
      final result = await locationService.searchLocations(query);

      if (!mounted) return;

      setState(() {
        locations = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        locations = [];
        errorMessage = 'Gagal mencari lokasi. Silakan coba lagi.';
        isLoading = false;
      });

      debugPrint('Error pencarian lokasi: $e');
    }
  }

  // Fungsi memilih hasil pencarian
  void selectLocation(Location location) {
    final point = LatLng(
      location.latitude,
      location.longitude,
    );

    // Memindahkan peta ke lokasi yang dipilih
    mapController.move(point, 17);

    setState(() {
      selectedLocation = location;
      selectedPoint = point;
      locations = [];
    });

    FocusScope.of(context).unfocus();
  }

  // Fungsi konfirmasi lokasi
  void confirmLocation() {
    final location = selectedLocation ??
        Location(
          name: 'Lokasi pilihan di peta',
          address:
              'Latitude: ${selectedPoint.latitude}, '
              'Longitude: ${selectedPoint.longitude}',
          latitude: selectedPoint.latitude,
          longitude: selectedPoint.longitude,
        );

    // Mengirim lokasi kembali ke AddTaskPage
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            HeaderSub(
              onBack: () => Navigator.pop(context),
            ),

            // Map Area
            Expanded(
              child: Stack(
                children: [
                  // OpenStreetMap
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: initialPoint,
                        initialZoom: widget.initialLocation != null ? 17 : 15,

                        onMapReady: () {
                          debugPrint('Map sudah siap');
                        },

                        onPositionChanged: (camera, hasGesture) {
                          if (hasGesture) {
                            setState(() {
                              selectedPoint = camera.center;
                              selectedLocation = null;
                            });

                            debugPrint(
                              'Latitude: ${selectedPoint.latitude}, '
                              'Longitude: ${selectedPoint.longitude}',
                            );
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'studypal',
                          errorTileCallback: (tile, error, stackTrace) {
                            debugPrint('Gagal memuat tile: $error');
                          },
                        ),

                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Marker tetap di tengah peta
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -24),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Search Bar
                  Positioned(
                    top: 28,
                    left: 24,
                    right: 24,
                    child: search.SearchBar(
                      controller: searchController,
                      height: 48,
                      buttonSize: 48,
                      onChanged: (value) {},
                      onSearchTap: searchLocation,
                    ),
                  ),

                  // Search Results
                  Positioned(
                    top: 88,
                    left: 24,
                    right: 24,
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : errorMessage != null
                            ? Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            : locations.isEmpty
                                ? const SizedBox.shrink()
                                : Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 250,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: locations.length,
                                      itemBuilder: (context, index) {
                                        final location = locations[index];

                                        return ListTile(
                                          title: Text(location.name),
                                          subtitle: Text(
                                            location.address,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () {
                                            selectLocation(location);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                  ),

                  // Pick Location Button
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: AppButton(
                      label: 'Picked This Location',
                      onTap: confirmLocation,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
