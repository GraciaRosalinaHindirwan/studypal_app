import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/components/header_sub.dart';
import 'package:studypal/components/search_bar.dart' as search;
import 'package:studypal/theme/app_colors.dart';

class PickLocationPage extends StatefulWidget {
  const PickLocationPage({super.key});

  @override
  State<PickLocationPage> createState() => _PickLocationPageState();
}

class _PickLocationPageState extends State<PickLocationPage> {
  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                      onChanged: (value) {
                        debugPrint('Search location: $value');
                      },
                      onFilterTap: () {
                        debugPrint('Filter location clicked');
                      },
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