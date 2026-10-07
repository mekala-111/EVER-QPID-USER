import 'dart:developer';
import 'package:everqpidapp/Features/settings/model/contact_model.dart';
import 'package:everqpidapp/Features/settings/repository/contact_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsViewModel extends ChangeNotifier {
  final ContactsRepository _repository = ContactsRepository();

  bool _isLoading = false;
  bool _isFetching = false;
  String? _errorMessage;
  List<ContactItem> _contacts = [];
  List<String> _hiddenContactNumbers = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;
  List<ContactItem> get contacts => _contacts;
  List<String> get hiddenContactNumbers => _hiddenContactNumbers;

  int get hiddenCount => _hiddenContactNumbers.length;
  bool get hasContacts => _contacts.isNotEmpty;

  // Request contacts permission
  Future<bool> requestContactsPermission() async {
    if (kIsWeb) {
      _errorMessage = 'Contact sync is not available on web.';
      notifyListeners();
      return false;
    }
    try {
      log('🔐 Requesting contacts permission...');

      final status = await Permission.contacts.request();

      if (status.isGranted) {
        log('✅ Contacts permission granted');
        return true;
      } else if (status.isDenied) {
        log('❌ Contacts permission denied');
        _errorMessage = 'Contacts permission denied';
        notifyListeners();
        return false;
      } else if (status.isPermanentlyDenied) {
        log('⚠️ Contacts permission permanently denied');
        _errorMessage = 'Please enable contacts permission in settings';
        notifyListeners();
        return false;
      }

      return false;
    } catch (e) {
      log('❌ Permission request error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch device contacts
  Future<bool> fetchDeviceContacts() async {
    if (kIsWeb) {
      _isLoading = false;
      _errorMessage = 'Contact sync is not available on web.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📱 Fetching device contacts...');

      // Check permission first
      if (!await FlutterContacts.requestPermission()) {
        throw Exception('Contacts permission not granted');
      }

      // Fetch contacts with phone numbers only
      final deviceContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      log('📱 Found ${deviceContacts.length} contacts');

      // Extract phone numbers and filter out contacts without phone numbers
      final contactItems = <ContactItem>[];

      for (var contact in deviceContacts) {
        if (contact.phones.isNotEmpty) {
          for (var phone in contact.phones) {
            // Clean phone number (remove spaces, dashes, etc.)
            final cleanNumber = _cleanPhoneNumber(phone.number);

            if (cleanNumber.isNotEmpty) {
              contactItems.add(
                ContactItem(
                  phoneNumber: cleanNumber,
                  displayName: contact.displayName,
                  isHidden: _hiddenContactNumbers.contains(cleanNumber),
                ),
              );
            }
          }
        }
      }

      // Remove duplicates
      final uniqueContacts = <String, ContactItem>{};
      for (var contact in contactItems) {
        uniqueContacts[contact.phoneNumber] = contact;
      }

      _contacts = uniqueContacts.values.toList();

      log('✅ Processed ${_contacts.length} unique contacts');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      log('❌ Fetch contacts error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clean phone number - remove spaces, dashes, parentheses
  String _cleanPhoneNumber(String phone) {
    // Remove all non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If it starts with country code, keep it
    // Otherwise, just return the digits
    return cleaned;
  }

  // Import and hide contacts
  Future<bool> importContacts({
    required String loginUserId,
    required List<String> contactNumbers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📤 Importing ${contactNumbers.length} contacts to hide');

      final response = await _repository.importContacts(
        loginUserId: loginUserId,
        contacts: contactNumbers,
      );

      if (response.status && response.data != null) {
        _hiddenContactNumbers = response.data!.hiddenContacts;

        // Update contacts list to reflect hidden status
        _updateContactsHiddenStatus();

        log('✅ Contacts imported and hidden successfully');
        log('   Hidden count: ${_hiddenContactNumbers.length}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Import failed: ${response.message}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Import contacts error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get hidden contacts from server
  Future<bool> fetchHiddenContacts() async {
    _isFetching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📤 Fetching hidden contacts from server');

      final response = await _repository.getHiddenContacts();

      if (response.status && response.data != null) {
        _hiddenContactNumbers = response.data!.hiddenContacts;

        // Update contacts list to reflect hidden status
        _updateContactsHiddenStatus();

        log('✅ Hidden contacts fetched successfully');
        log('   Hidden count: ${_hiddenContactNumbers.length}');

        _isFetching = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Fetch failed: ${response.message}');
        _isFetching = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Fetch hidden contacts error: $e');
      _isFetching = false;
      notifyListeners();
      return false;
    }
  }

  // Remove contacts from hidden list
  Future<bool> removeHiddenContacts({
    required String loginUserId,
    required List<String> contactNumbers,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      log('📤 Removing ${contactNumbers.length} contacts from hidden');

      final response = await _repository.removeHiddenContacts(
        loginUserId: loginUserId,
        contacts: contactNumbers,
      );

      if (response.status && response.data != null) {
        _hiddenContactNumbers = response.data!.getHiddenContacts;

        // Update contacts list to reflect hidden status
        _updateContactsHiddenStatus();

        log('✅ Contacts removed from hidden successfully');
        log('   Remaining hidden count: ${_hiddenContactNumbers.length}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Remove failed: ${response.message}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Remove hidden contacts error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update contacts list to reflect hidden status
  void _updateContactsHiddenStatus() {
    _contacts = _contacts.map((contact) {
      return contact.copyWith(
        isHidden: _hiddenContactNumbers.contains(contact.phoneNumber),
      );
    }).toList();
  }

  // Get only hidden contacts
  List<ContactItem> getHiddenContacts() {
    return _contacts.where((contact) => contact.isHidden).toList();
  }

  // Get only visible contacts
  List<ContactItem> getVisibleContacts() {
    return _contacts.where((contact) => !contact.isHidden).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _contacts = [];
    _hiddenContactNumbers = [];
    _errorMessage = null;
    notifyListeners();
    log('🧹 Contacts data cleared');
  }
}
