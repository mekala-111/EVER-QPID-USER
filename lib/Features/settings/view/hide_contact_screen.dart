import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/settings/view/desktop/desktop_hide_contacts_view.dart';
import 'package:everqpidapp/Features/settings/view/manage_hidden_contact_screen.dart';
import 'package:everqpidapp/Features/settings/view_model/contact_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HideContactsScreen extends StatefulWidget {
  const HideContactsScreen({super.key});

  @override
  State<HideContactsScreen> createState() => _HideContactsScreenState();
}

class _HideContactsScreenState extends State<HideContactsScreen> {
  @override
  void initState() {
    super.initState();
    // Defer: notifyListeners during Provider mount causes !_dirty assertion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchHiddenContacts();
    });
  }

  Future<void> _fetchHiddenContacts() async {
    if (!mounted) return;
    final viewModel = context.read<ContactsViewModel>();
    await viewModel.fetchHiddenContacts();
  }

  void _openManageHidden() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ContactsViewModel>(),
          child: const ManageHiddenContactsScreen(),
        ),
      ),
    ).then((_) {
      _fetchHiddenContacts();
    });
  }

  Future<void> _importContacts(BuildContext context) async {
    final viewModel = context.read<ContactsViewModel>();

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contact sync is not available on web. Use the mobile app.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final status = await Permission.contacts.request();

    if (status.isGranted) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await viewModel.fetchDeviceContacts();

      if (!mounted) return;
      Navigator.pop(context);

      if (success && viewModel.hasContacts) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectContactsScreen(),
          ),
        ).then((_) {
          _fetchHiddenContacts();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'No contacts found',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (status.isDenied) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts permission denied'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contacts Permission Required'),
          content: const Text(
            'Please enable contacts permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await openAppSettings();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditResponsive(
      mobile: (_) => _buildMobile(context),
      desktop: (_) => DesktopHideContactsView(
        onImportContacts: () => _importContacts(context),
        onManageHidden: _openManageHidden,
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Back',
          style: getTextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Selector<ContactsViewModel, int>(
            selector: (_, vm) => vm.hiddenCount,
            builder: (context, hiddenCount, child) {
              if (hiddenCount <= 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: _openManageHidden,
                child: Text(
                  'Manage ($hiddenCount)',
                  style: getTextStyle(
                    fontSize: 14,
                    color: PColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hide your profile from people you know, and date confidently.',
              style: getTextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'We understand that your dating journey is personal. With Everqpid\'s privacy settings, you can choose to hide your profile from contacts or people you may know — like friends, colleagues, or relatives. This feature gives you the space to explore serious connections confidently, without the pressure of familiar eyes. Your comfort comes first, and we\'re here to keep your experience discreet and secure.',
              style: getTextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<ContactsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isFetching) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (viewModel.hiddenCount > 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: PColors.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You have hidden ${viewModel.hiddenCount} contact${viewModel.hiddenCount > 1 ? 's' : ''}',
                            style: getTextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const Spacer(),
            Consumer<ContactsViewModel>(
              builder: (context, viewModel, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _importContacts(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColors.primaryColor,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Import contacts',
                            style: getTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Select Contacts Screen
class SelectContactsScreen extends StatefulWidget {
  const SelectContactsScreen({super.key});

  @override
  State<SelectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  final Set<String> _selectedContacts = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Contacts to Hide',
          style: getTextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final viewModel = context.read<ContactsViewModel>();
              setState(() {
                _selectAll = !_selectAll;
                if (_selectAll) {
                  _selectedContacts.addAll(
                    viewModel.contacts
                        .where((c) => !c.isHidden)
                        .map((c) => c.phoneNumber),
                  );
                } else {
                  _selectedContacts.clear();
                }
              });
            },
            child: Text(
              _selectAll ? 'Deselect All' : 'Select All',
              style: getTextStyle(
                fontSize: 14,
                color: PColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ContactsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final availableContacts = viewModel.getVisibleContacts();

          if (availableContacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All contacts are already hidden',
                    style: getTextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selected contacts won\'t see your profile',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contacts list
              Expanded(
                child: ListView.builder(
                  cacheExtent: 400,
                  itemCount: availableContacts.length,
                  itemBuilder: (context, index) {
                    final contact = availableContacts[index];
                    final isSelected =
                        _selectedContacts.contains(contact.phoneNumber);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedContacts.add(contact.phoneNumber);
                          } else {
                            _selectedContacts.remove(contact.phoneNumber);
                          }
                        });
                      },
                      title: Text(
                        contact.displayName ?? 'Unknown',
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        contact.phoneNumber,
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      activeColor: PColors.primaryColor,
                    );
                  },
                ),
              ),

              // Hide button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedContacts.isEmpty
                          ? null
                          : () => _hideSelectedContacts(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedContacts.isNotEmpty
                            ? PColors.primaryColor
                            : Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Hide ${_selectedContacts.length} Contact${_selectedContacts.length != 1 ? 's' : ''}',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedContacts.isNotEmpty
                              ? Colors.white
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _hideSelectedContacts(ContactsViewModel viewModel) async {
    final userId = LoggedInUser.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await viewModel.importContacts(
      loginUserId: userId,
      contactNumbers: _selectedContacts.toList(),
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedContacts.length} contact${_selectedContacts.length != 1 ? 's' : ''} hidden successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Failed to hide contacts',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
