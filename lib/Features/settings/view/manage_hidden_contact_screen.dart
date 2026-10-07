import 'package:everqpidapp/Features/settings/model/contact_model.dart';
import 'package:everqpidapp/Features/settings/view_model/contact_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';

class ManageHiddenContactsScreen extends StatefulWidget {
  const ManageHiddenContactsScreen({super.key});

  @override
  State<ManageHiddenContactsScreen> createState() =>
      _ManageHiddenContactsScreenState();
}

class _ManageHiddenContactsScreenState
    extends State<ManageHiddenContactsScreen> {
  final Set<String> _selectedToUnhide = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Defer: showDialog / notifyListeners during mount causes !_dirty assertion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadHiddenContacts();
    });
  }

  Future<void> _loadHiddenContacts() async {
    if (!mounted) return;
    final viewModel = context.read<ContactsViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await viewModel.fetchHiddenContacts();

    if (!mounted) return;
    Navigator.pop(context); // Close loading
  }

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
          'Hidden Contacts',
          style: getTextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<ContactsViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.hiddenContactNumbers.isEmpty) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () {
                  setState(() {
                    _selectAll = !_selectAll;
                    if (_selectAll) {
                      _selectedToUnhide.addAll(viewModel.hiddenContactNumbers);
                    } else {
                      _selectedToUnhide.clear();
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
              );
            },
          ),
        ],
      ),
      body: Consumer<ContactsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isFetching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hiddenContactNumbers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hidden contacts',
                    style: getTextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacts you hide will appear here',
                    style: getTextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
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
                        'These contacts cannot see your profile. Select contacts to unhide them.',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hidden contacts list
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.hiddenContactNumbers.length,
                  itemBuilder: (context, index) {
                    final phoneNumber = viewModel.hiddenContactNumbers[index];
                    final isSelected = _selectedToUnhide.contains(phoneNumber);

                    // Try to find contact with this number
                    final contact = viewModel.contacts.firstWhere(
                      (c) => c.phoneNumber == phoneNumber,
                      orElse: () => ContactItem(
                        phoneNumber: phoneNumber,
                        displayName: null,
                      ),
                    );

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedToUnhide.add(phoneNumber);
                          } else {
                            _selectedToUnhide.remove(phoneNumber);
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
                        phoneNumber,
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.visibility_off,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                      activeColor: PColors.primaryColor,
                    );
                  },
                ),
              ),

              // Unhide button
              if (_selectedToUnhide.isNotEmpty)
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
                        onPressed: viewModel.isLoading
                            ? null
                            : () => _unhideSelectedContacts(viewModel),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Unhide ${_selectedToUnhide.length} Contact${_selectedToUnhide.length != 1 ? 's' : ''}',
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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

  Future<void> _unhideSelectedContacts(ContactsViewModel viewModel) async {
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

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unhide Contacts?'),
        content: Text(
          'Are you sure you want to unhide ${_selectedToUnhide.length} contact${_selectedToUnhide.length != 1 ? 's' : ''}? They will be able to see your profile again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unhide',
              style: TextStyle(color: PColors.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await viewModel.removeHiddenContacts(
      loginUserId: userId,
      contactNumbers: _selectedToUnhide.toList(),
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (success) {
      setState(() {
        _selectedToUnhide.clear();
        _selectAll = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts unhidden successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // If no more hidden contacts, go back
      if (viewModel.hiddenContactNumbers.isEmpty) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Failed to unhide contacts',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
