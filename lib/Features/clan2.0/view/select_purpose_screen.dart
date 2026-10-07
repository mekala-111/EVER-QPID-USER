// features/clan/view/select_purpose_screen.dart

import 'dart:developer';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import '../view_model/clan_view_model.dart';
import '../service/location_name_service.dart';

class SelectPurposeScreen extends StatefulWidget {
  final String userId;

  const SelectPurposeScreen({super.key, required this.userId});

  @override
  State<SelectPurposeScreen> createState() => _SelectPurposeScreenState();
}

class _SelectPurposeScreenState extends State<SelectPurposeScreen> {
  String? _selectedPurpose;
  bool _isLoading = false;
  String? _locationName;

  final List<Map<String, String>> _purposes = [
    {
      'id': 'home',
      'title': 'Exploring',
      'subtitle': 'Considering moving or settling here.',
    },
    {
      'id': 'work',
      'title': 'For Work',
      'subtitle': 'Living here for jobs or professional work.',
    },
    {
      'id': 'study',
      'title': 'For Study',
      'subtitle': 'Studying at a college or institute in this area.',
    },
    {
      'id': 'quest',
      'title': 'Trip or Vacation',
      'subtitle': 'Currently visiting for tourism purposes.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Do NOT request permission here — mobile Chrome auto-denies prompts
    // that are not tied to a user tap. Only reuse an already-granted fix.
    _tryReuseGrantedLocation();
  }

  Future<void> _tryReuseGrantedLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
      await _applyPosition(await Geolocator.getCurrentPosition());
    } catch (e) {
      log('❌ Location reuse error: $e');
    }
  }

  /// Call from a button so mobile browsers keep user activation.
  Future<void> _fetchLocationFromTap() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          _showError('Location permission is required');
          return;
        }
      } else if (permission == LocationPermission.deniedForever) {
        _showError('Location permission is required');
        return;
      }

      await _applyPosition(await Geolocator.getCurrentPosition());
    } catch (e) {
      log('❌ Location error: $e');
      _showError('Failed to get location');
    }
  }

  Future<void> _applyPosition(Position position) async {
    final locationService = LocationNameService();
    final name = await locationService.getLocationName(
      lat: position.latitude,
      lng: position.longitude,
    );

    if (!mounted) return;

    final placemarks = await locationService.getPlacemarkDetails(
      lat: position.latitude,
      lng: position.longitude,
    );

    context.read<ClanViewModel>().setLocation(
          position.latitude,
          position.longitude,
          locationName: name,
          city: placemarks['city'],
          state: placemarks['state'],
        );

    setState(() {
      _locationName = name;
    });

    log('📍 Location fetched: $name');
  }

  Future<void> _handleSubmit() async {
    if (_selectedPurpose == null) {
      _showError('Please select a purpose');
      return;
    }

    final viewModel = context.read<ClanViewModel>();
    if (viewModel.currentLat == null || viewModel.currentLng == null) {
      await _fetchLocationFromTap();
      if (viewModel.currentLat == null || viewModel.currentLng == null) {
        _showError('Location not available — tap Use my location');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await viewModel.updateClanLocation(widget.userId, _selectedPurpose!);
      if (!mounted) return;

      // Fetch initial data for home screen
      await Future.wait([
        viewModel.fetchAllClanPhotos(widget.userId),
        viewModel.fetchMostActiveProfiles(),
      ]);

      log('✅ Purpose submitted successfully');
    } catch (e) {
      log('❌ Submit error: $e');
      if (mounted) {
        _showError('Failed to update location');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_locationName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      TextButton.icon(
                        onPressed: _fetchLocationFromTap,
                        icon: const Icon(Icons.my_location, size: 18),
                        label: const Text('Use my location'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Select your purpose?',
                      style: getTextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your reason for visiting this place to help us connect you with the right clan members.',
                      style: getTextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._purposes.map(
                      (purpose) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PurposeCard(
                          title: purpose['title']!,
                          subtitle: purpose['subtitle']!,
                          isSelected: _selectedPurpose == purpose['id'],
                          onTap: () => setState(() {
                            _selectedPurpose = purpose['id'];
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurposeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PurposeCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? PColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? PColors.primaryColor : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? PColors.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
