import 'package:flutter/material.dart';
import 'package:studypal/components/app_button.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:studypal/services/location_service.dart';

class TaskDetailDialog extends StatefulWidget {
  final String title;
  final String description;
  final String dueDate;
  final String reminder;
  final String location;
  final double? locationLatitude;
  final double? locationLongitude;
  final bool isCompleted;

  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const TaskDetailDialog({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.reminder,
    required this.location,
    this.locationLatitude,
    this.locationLongitude,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
    required this.isCompleted,
    required this.onToggleStatus,
  });

 

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LatLng? _userPosition;
  String _distanceText = 'Memuat jarak...';
  

  bool _isMapReady = false;

  List<LatLng> _routePoints = [];

  Widget _buildDistanceMapSection(LatLng target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 175,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: target,
              initialZoom: 15,
              onMapReady: () {
                setState(() {
                  _isMapReady = true;
                });
                _fitCameraIfPossible();
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'studypal',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 3.5,
                      color: AppColors.primary,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  if (_userPosition != null)
                    Marker(
                      point: _userPosition!,
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  Marker(
                    point: target,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoItem(
          icon: Icons.near_me_outlined,
          label: 'Distance',
          value: _distanceText,
        ),
      ],
    );
  }

   void _fitCameraIfPossible() {
    final target = _targetPosition;
    final userPos = _userPosition;
    if (!_isMapReady || target == null || userPos == null || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMapReady || !mounted) return;
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [userPos, target],
          padding: const EdgeInsets.all(28),
        ),
      );
    });
  }

  //getter buat ubah latitude sama longitude jadi latLng 
  LatLng? get _targetPosition {
    if (widget.locationLatitude == null || widget.locationLongitude == null) {
      return null;
    }
    return LatLng(widget.locationLatitude!, widget.locationLongitude!);
  }

  @override
  void initState() {
    super.initState();
    _loadLocationAndDistance();
  }

  Future<void> _loadLocationAndDistance() async {
    final target = _targetPosition;
    if (target == null) {
      if (!mounted) return;
      setState(() {
        _distanceText = 'Lokasi belum diatur';
      });
      return;
    }

    final userPos = await _locationService.getCurrentUserPosition();


    if (!mounted) return;

    if (userPos == null) {
      
      setState(() {
        _distanceText = 'Jarak tidak tersedia (cek GPS/izin lokasi)';
      });
      return;
    }

    final routeResult = await _locationService.getDrivingRoute(
      start: userPos,
      end: target,
    );

    final points = (routeResult != null && routeResult.points.isNotEmpty)
    ? routeResult.points
    : [userPos, target];

    final meters = routeResult?.distanceMeters ??
        _locationService.calculateDistanceMeters(
          startLat: userPos.latitude,
          startLng: userPos.longitude,
          endLat: target.latitude,
          endLng: target.longitude,
        );

    setState(() {
      _userPosition = userPos;
      _routePoints = points;
      _distanceText = '${_locationService.formatDistance(meters)} dari lokasimu';
    });

    //supaya 2 titik keliat jelas 
    _fitCameraIfPossible();
  }

  DateTime? _parseDueDate(String raw) {
    // Mendukung format 'dd/MM/yyyy HH:mm' yang dipakai di TaskPage.formatTaskDate
    final parts = raw.trim().split(' ');
    if (parts.length != 2) return null;

    final dateParts = parts[0].split('/');
    final timeParts = parts[1].split(':');
    if (dateParts.length != 3 || timeParts.length != 2) return null;

    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = int.tryParse(dateParts[2]);
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null) {
      return null;
    }

    return DateTime(year, month, day, hour, minute);
  }

  Duration? _parseReminderDuration(String raw) {
    final cleaned = raw.replaceAll('[', '').replaceAll(']', '').trim().toLowerCase();
    if (cleaned.isEmpty || cleaned == 'no reminder') return null;

    // Jika hanya angka (misalnya "15" dari reminderMinutes), anggap sebagai menit
    final onlyNumber = int.tryParse(cleaned);
    if (onlyNumber != null && onlyNumber >= 0) {
      return Duration(minutes: onlyNumber);
    }

    final words = cleaned.split(' ');
    if (words.isEmpty) return null;

    final value = int.tryParse(words[0]);
    if (value == null || value < 0) return null;
    if (value == 0) return Duration.zero;
    if (words.length < 2) return null;

    final unit = words[1];
    if (unit.startsWith('menit') || unit.startsWith('minute')) {
      return Duration(minutes: value);
    }
    if (unit.startsWith('jam') || unit.startsWith('hour')) {
      return Duration(hours: value);
    }
    if (unit.startsWith('hari') || unit.startsWith('day')) {
      return Duration(days: value);
    }

    return null;
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  //helper
  String _formatReminderLabel(String raw, Duration duration) {
    final cleaned = raw.replaceAll('[', '').replaceAll(']', '').trim();
    if (int.tryParse(cleaned) != null) {
      final totalMinutes = duration.inMinutes;
      if (totalMinutes == 0) return 'Saat Acara Dimulai';
      if (totalMinutes % (60 * 24) == 0) {
        final days = totalMinutes ~/ (60 * 24);
        return '$days Hari sebelum';
      }
      if (totalMinutes % 60 == 0) {
        final hours = totalMinutes ~/ 60;
        return '$hours Jam sebelum';
      }
      return '$totalMinutes menit sebelum';
    }
    return cleaned;
  }

  String _buildReminderDisplay() {
    final duration = _parseReminderDuration(widget.reminder);
    if (duration == null) {
      return widget.reminder;
    }

    return _formatReminderLabel(widget.reminder, duration);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: _buildCircleButton(
                  icon: Icons.close,
                  onTap: widget.onClose,
                ),
              ),

              const SizedBox(height: 20),

              // Main Detail Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: AppColors.secondary,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.background,
                                ),
                              ),
                    
                              const SizedBox(height: 8),
                    
                              Text(
                                widget.description,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                    
                        // Task Information
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoItem(
                                icon: Icons.edit_calendar,
                                label: 'Due Date',
                                value: widget.dueDate,
                              ),
                    
                              const SizedBox(height: 14),
                    
                              _buildInfoItem(
                                icon: Icons.alarm,
                                label: 'Reminder',
                                value: _buildReminderDisplay(),
                              ),
                    
                              const SizedBox(height: 14),
                    
                              _buildInfoItem(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: widget.location,
                              ),

                              if (_targetPosition != null) ...[
                                const SizedBox(height: 14),
                                _buildDistanceMapSection(_targetPosition!),
                              ],
                    
                              const SizedBox(height: 16),
                    
                              // Mark as Done
                              AppButton(
                                label: widget.isCompleted ? 'Undo Completed' : 'Mark as Done',
                                onTap: widget.onToggleStatus,
                              ), 
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Edit and Delete Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleButton(
                    icon: Icons.edit_outlined,
                    onTap: widget.onEdit,
                  ),

                  const SizedBox(width: 32),

                  _buildCircleButton(
                    icon: Icons.delete_outline,
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 25,
        ),
      ),
    );
  }
}
