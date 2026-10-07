import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';

class OfflineCitySelectorBottomSheet extends StatefulWidget {
  final String? currentCity;
  final String? currentCountry;
  final String? currentState;
  final Function(SelectedLocation) onLocationSelected;

  const OfflineCitySelectorBottomSheet({
    super.key,
    this.currentCity,
    this.currentCountry,
    this.currentState,
    required this.onLocationSelected,
  });

  @override
  State<OfflineCitySelectorBottomSheet> createState() =>
      _OfflineCitySelectorBottomSheetState();
}

class _OfflineCitySelectorBottomSheetState
    extends State<OfflineCitySelectorBottomSheet> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  bool get _canSubmit =>
      _selectedCountry != null &&
      _selectedState != null &&
      _selectedCity != null;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.currentCountry;
    _selectedState = widget.currentState;
    _selectedCity = widget.currentCity;
  }

  void _handleSubmit() {
    if (_canSubmit) {
      widget.onLocationSelected(
        SelectedLocation(
          country: _selectedCountry!,
          state: _selectedState!,
          city: _selectedCity!,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Location',
                  style: getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select your country, state, and city',
              style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(height: 24),

          // CSC Picker
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country Selector
                  _buildSectionLabel('Country'),
                  const SizedBox(height: 8),
                  CSCPickerPlus(
                    layout: Layout.vertical,
                    flagState: CountryFlag.DISABLE,

                    // Country
                    defaultCountry: _selectedCountry != null
                        ? CscCountry.India // Set based on your default
                        : null,
                    onCountryChanged: (country) {
                      setState(() {
                        _selectedCountry = country;
                        _selectedState = null;
                        _selectedCity = null;
                      });
                    },

                    // State
                    onStateChanged: (state) {
                      setState(() {
                        _selectedState = state;
                        _selectedCity = null;
                      });
                    },

                    // City
                    onCityChanged: (city) {
                      setState(() {
                        _selectedCity = city;
                      });
                    },

                    // Styling
                    countryDropdownLabel: 'Select Country',
                    stateDropdownLabel: 'Select State',
                    cityDropdownLabel: 'Select City',

                    selectedItemStyle: getTextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),

                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),

                    disabledDropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),

                    dropdownHeadingStyle: getTextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),

                    dropdownItemStyle: getTextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selected location preview
                  if (_selectedCity != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PColors.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: PColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Location',
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: PColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.location_city,
                            'City',
                            _selectedCity!,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.map,
                            'State',
                            _selectedState ?? '',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.public,
                            'Country',
                            _selectedCountry ?? '',
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Submit button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PColors.primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _canSubmit ? 2 : 0,
                ),
                child: Text(
                  'Confirm Location',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _canSubmit ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: getTextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// Model for selected location
class SelectedLocation {
  final String country;
  final String state;
  final String city;

  SelectedLocation({
    required this.country,
    required this.state,
    required this.city,
  });

  String get displayName => '$city, $state, $country';
  String get shortName => city;
  String get fullName => '$city, $state';
}

// Helper function to show the bottom sheet
void showOfflineCitySelector({
  required BuildContext context,
  String? currentCity,
  String? currentCountry,
  String? currentState,
  required Function(SelectedLocation) onLocationSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => OfflineCitySelectorBottomSheet(
      currentCity: currentCity,
      currentCountry: currentCountry,
      currentState: currentState,
      onLocationSelected: onLocationSelected,
    ),
  );
}
