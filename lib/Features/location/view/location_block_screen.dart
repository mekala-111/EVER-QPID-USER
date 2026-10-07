import 'package:everqpidapp/Features/location/view_model/location_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LocationBlockScreen extends StatefulWidget {
  const LocationBlockScreen({super.key});

  @override
  State<LocationBlockScreen> createState() => _LocationBlockScreenState();
}

class _LocationBlockScreenState extends State<LocationBlockScreen> {
  bool _isRequesting = false;

  Future<void> _onEnableLocationPressed() async {
    if (_isRequesting) return;

    setState(() => _isRequesting = true);

    try {
      if (kIsWeb) {
        // Browsers cannot open OS location settings; request via Geolocation API.
        final permission = await Geolocator.requestPermission();

        if (!mounted) return;

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location is blocked. Allow location for this site using the lock icon in the address bar, then tap Enable Location again.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        await context.read<LocationViewModel>().recheckLocation();
      } else {
        await Geolocator.openLocationSettings();
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),

              // Location icon illustration
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: PColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_outlined,
                  size: 60,
                  color: PColors.primaryColor,
                ),
              ),

              const SizedBox(height: 25),

              // Title
              Text(
                'Location Access Required',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  kIsWeb
                      ? 'Everqpid needs your location to help you find matches nearby. Allow location access in your browser to continue.'
                      : 'Everqpid needs your location to help you find matches nearby. Please enable location access to continue.',
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Features list
              _FeatureItem(
                icon: Icons.favorite,
                title: 'Find Local Matches',
                description: 'Discover people near you',
              ),

              const SizedBox(height: 10),

              _FeatureItem(
                icon: Icons.security,
                title: 'Privacy Protected',
                description: 'Your exact location is never shared',
              ),

              const SizedBox(height: 10),

              _FeatureItem(
                icon: Icons.explore,
                title: 'Better Connections',
                description: 'Meet people in your area',
              ),

              const Spacer(),

              // Enable Location Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _onEnableLocationPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRequesting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isRequesting ? 'Requesting…' : 'Enable Location',
                        style: getTextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info text
              Text(
                kIsWeb
                    ? 'Allow location when the browser prompts you'
                    : 'Tap to open location settings',
                style: getTextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Item Widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: PColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                  description,
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
