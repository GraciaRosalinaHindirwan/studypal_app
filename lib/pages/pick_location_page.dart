import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/components/search_bar.dart' as search;
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/services/location_service.dart';
import 'package:studypal/models/location.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final TextEditingController searchController = TextEditingController();
  final LocationService locationService = LocationService();

  List<Location> locations = [];
  bool isLoading = false;
  String? errorMessage;

  Location? selectedLocation;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
                  // Map Placeholder
                  Positioned.fill(
                    child: Container(
                      color: AppColors.background,
                      child: const Center(
                        child: Text(
                          'Map will be displayed here',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
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
                              style: const TextStyle(color: Colors.red),
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
                                          setState(() {
                                            selectedLocation = location;
                                          });
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
                      onTap: () {
                        debugPrint('Location picked');
                      },
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