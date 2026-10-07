import 'dart:developer';
import 'dart:typed_data';

import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/mainscreen/view/widgets/desktop_sidebar.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_profile_view.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/edit_about_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_bio_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_interests_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_relationship_goals_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_work_and_education_screen.dart';
import 'package:everqpidapp/Features/profile/view/widgets/image_slot.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final List<ImageSlot> _imageSlots = List.generate(4, (_) => ImageSlot());

  final ImagePicker _picker = ImagePicker();
  bool _hasChanges = false;
  bool _tabletSidebarCollapsed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeImageSlots();
    });
  }

  void _initializeImageSlots() {
    final getProfileVM = Provider.of<GetProfileViewModel>(
      context,
      listen: false,
    );
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    if (getProfileVM.profile != null) {
      profileVM.loadFromProfile(getProfileVM.profile!);

      final existingPhotos = profileVM.profilePhotos;
      setState(() {
        for (int i = 0; i < 4; i++) {
          _imageSlots[i] = ImageSlot(
            networkUrl: i < existingPhotos.length ? existingPhotos[i] : null,
            isModified: false,
          );
        }
        _hasChanges = false;
      });
      log('📸 Loaded ${existingPhotos.length} existing photos into slots');
    }
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageSlots[index] = ImageSlot(
            localBytes: bytes,
            networkUrl: null,
            isModified: true,
          );
          _hasChanges = true;
        });
        log('📸 Image picked for slot $index (replaced existing)');
      }
    } catch (e) {
      log('❌ Error picking image: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pick image',
        backgroundColor: Colors.red,
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageSlots[index] = ImageSlot(isModified: true);
      _hasChanges = true;
    });
    log('🗑️ Image removed from slot $index');
  }

  /// Reorder only — first slot becomes profileImageUrl on save (existing API).
  void _setAsPrimary(int index) {
    if (index <= 0 || !_imageSlots[index].hasImage) return;
    setState(() {
      final moved = _imageSlots.removeAt(index);
      _imageSlots.insert(0, moved);
      while (_imageSlots.length < 4) {
        _imageSlots.add(ImageSlot());
      }
      _hasChanges = true;
    });
  }

  void _goBackToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      PPages.mainScreen,
      (route) => false,
      arguments: {'tabIndex': 4},
    );
  }

  void _leaveToTab(int index) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      PPages.mainScreen,
      (route) => false,
      arguments: {'tabIndex': index},
    );
    MainScreenBridge.navigateToTab(index);
  }

  Future<void> _saveProfile() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final getProfileVM = Provider.of<GetProfileViewModel>(
      context,
      listen: false,
    );

    final hasAtLeastOneImage = _imageSlots.any((slot) => slot.hasImage);
    if (!hasAtLeastOneImage) {
      Fluttertoast.showToast(
        msg: 'Please add at least one photo',
        backgroundColor: Colors.red,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SaveProfileDialog(viewModel: profileVM),
    );

    try {
      final List<String> finalPhotoUrls = await _buildFinalPhotoList(profileVM);

      if (finalPhotoUrls.isEmpty) {
        if (!mounted) return;
        Navigator.pop(context);

        Fluttertoast.showToast(
          msg: 'Failed to process photos. Please try again.',
          backgroundColor: Colors.red,
        );
        return;
      }

      profileVM.setProfilePhotos(finalPhotoUrls);
      log('📋 Final photo list: ${finalPhotoUrls.length} photos');

      log('🚀 Calling updateProfile...');
      final success = await profileVM.updateProfile();

      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        log('✅ Profile updated successfully');

        Fluttertoast.showToast(
          msg: 'Profile updated successfully! ✅',
          backgroundColor: Colors.green,
        );

        setState(() {
          _hasChanges = false;
          for (int i = 0; i < 4; i++) {
            _imageSlots[i] = ImageSlot(
              networkUrl: i < finalPhotoUrls.length ? finalPhotoUrls[i] : null,
              isModified: false,
            );
          }
        });

        await getProfileVM.fetchProfile();

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        log('❌ Profile update failed: ${profileVM.errorMessage}');

        Fluttertoast.showToast(
          msg: profileVM.errorMessage ?? 'Failed to update profile',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      log('❌ Save profile error: $e');

      if (mounted) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'An error occurred: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<List<String>> _buildFinalPhotoList(ProfileViewModel profileVM) async {
    final List<String> finalUrls = [];

    for (int i = 0; i < 4; i++) {
      final slot = _imageSlots[i];

      if (slot.localBytes != null) {
        log('📤 Uploading new image at slot $i...');

        final url = await profileVM.uploadSinglePhoto(slot.localBytes!);

        if (url == null || url.isEmpty) {
          log('❌ Failed to upload image at slot $i');
          return [];
        }

        finalUrls.add(url);
        log('✅ Uploaded slot $i: $url');
      } else if (slot.networkUrl != null) {
        finalUrls.add(slot.networkUrl!);
        log('✓ Preserved slot $i: ${slot.networkUrl}');
      } else {
        log('○ Slot $i is empty');
      }
    }

    return finalUrls;
  }

  Future<void> _openSection(Widget screen) async {
    final result = await Navigator.push(
      context,
      profileSectionRoute(screen),
    );
    if (result != null && mounted) {
      setState(() => _hasChanges = true);
    }
  }

  void _showPreview() {
    final vm = context.read<ProfileViewModel>();
    final getVm = context.read<GetProfileViewModel>();
    ImageSlot? first;
    for (final s in _imageSlots) {
      if (s.hasImage) {
        first = s;
        break;
      }
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF15082D),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'How others see you',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: first?.localBytes != null
                        ? Image.memory(first!.localBytes!, fit: BoxFit.cover)
                        : AppNetworkImage(
                            url: first?.networkUrl ??
                                AppConfig.placeholderImageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  (vm.fullName ?? '').isEmpty ? 'You' : vm.fullName!,
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if ((vm.aboutMe ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    vm.aboutMe!,
                    style: getTextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
                if (getVm.profile?.isVerified == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Verified profile',
                    style: getTextStyle(
                      fontSize: 12,
                      color: PColors.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopForm() {
    final isVerified =
        context.read<GetProfileViewModel>().profile?.isVerified ?? false;

    return DesktopEditProfileView(
      imageSlots: _imageSlots,
      hasChanges: _hasChanges,
      isVerified: isVerified,
      onPickImage: _pickImage,
      onRemoveImage: _removeImage,
      onSetPrimary: _setAsPrimary,
      onSave: _saveProfile,
      onReset: _initializeImageSlots,
      onCancel: _goBackToProfile,
      onBack: _goBackToProfile,
      onEditBio: () {
        final bio = context.read<ProfileViewModel>().aboutMe;
        _openSection(EditBioScreen(initialBio: bio));
      },
      onEditAbout: () => _openSection(const EditAboutScreen()),
      onEditWork: () => _openSection(const EditWorkEducationScreen()),
      onEditGoals: () => _openSection(const EditRelationshipGoalsScreen()),
      onEditInterests: () => _openSection(const EditInterestsScreen()),
      onPreview: _showPreview,
    );
  }

  Widget _shell({required bool collapsed, VoidCallback? onToggleCollapse}) {
    return Scaffold(
      backgroundColor: const Color(0xFF090416),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            Images.bg,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            cacheWidth: 1600,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF090416)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesktopSidebar(
                selectedIndex: 4,
                onSelect: _leaveToTab,
                collapsed: collapsed,
                onToggleCollapse: onToggleCollapse,
              ),
              Expanded(
                child: Column(
                  children: [
                    const DesktopContentTopBar(),
                    Expanded(child: _desktopForm()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Do you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (shouldPop != true) return false;
    }

    _goBackToProfile();
    return false;
  }

  Widget _buildMobile() {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: _goBackToProfile,
          ),
          title: Text(
            'Back',
            style: getTextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveProfile,
                child: Text(
                  'Save',
                  style: getTextStyle(
                    fontSize: 16,
                    color: PColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: AppContentFrame(
          maxWidth: ContentMaxWidth.form,
          child: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromARGB(255, 111, 108, 108),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete profile, get matched better',
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: photoSlotColumns(context),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final slot = _imageSlots[index];

                          return _PhotoBox(
                            localBytes: slot.localBytes,
                            networkImage: slot.networkUrl,
                            onTap: () => _pickImage(index),
                            onRemove: () => _removeImage(index),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _EditSection(
                        title: 'This is Me',
                        content: viewModel.aboutMe?.isNotEmpty == true
                            ? viewModel.aboutMe!
                            : 'Add your bio',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditBioScreen(initialBio: viewModel.aboutMe),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _EditSection(
                        title: 'About',
                        content: _getAboutSummary(viewModel),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditAboutScreen(),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _EditSection(
                        title: 'Work & Education',
                        content: _getWorkEducationSummary(viewModel),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EditWorkEducationScreen(),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _EditSection(
                        title: 'Relationship Goals',
                        content: viewModel.relationshipGoals.isNotEmpty
                            ? viewModel.relationshipGoals.join(', ')
                            : 'Not specified',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EditRelationshipGoalsScreen(),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _EditSection(
                        title: 'Hobbies & Interests',
                        content: viewModel.interests.isNotEmpty
                            ? viewModel.interests.join(', ')
                            : 'Add your interests',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditInterestsScreen(),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = breakpointOf(constraints.maxWidth);
        if (bp == AppBreakpoint.mobile) return _buildMobile();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _onWillPop();
          },
          child: bp == AppBreakpoint.desktop
              ? _shell(collapsed: false)
              : _shell(
                  collapsed: _tabletSidebarCollapsed,
                  onToggleCollapse: () {
                    setState(
                      () =>
                          _tabletSidebarCollapsed = !_tabletSidebarCollapsed,
                    );
                  },
                ),
        );
      },
    );
  }

  String _getAboutSummary(ProfileViewModel viewModel) {
    final parts = <String>[];

    if (viewModel.relationshipStatus != null &&
        viewModel.relationshipStatus!.isNotEmpty) {
      parts.add(viewModel.relationshipStatus!);
    }

    if (viewModel.height != null) {
      parts.add('${viewModel.height} cm');
    }

    if (viewModel.religion != null && viewModel.religion!.isNotEmpty) {
      parts.add(viewModel.religion!);
    }

    if (viewModel.otherLanguages.isNotEmpty) {
      parts.addAll(viewModel.otherLanguages.take(2));
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Complete your info';
  }

  String _getWorkEducationSummary(ProfileViewModel viewModel) {
    final parts = <String>[];

    if (viewModel.currentProfession != null &&
        viewModel.currentProfession!.isNotEmpty) {
      parts.add(viewModel.currentProfession!);
    }
    if (viewModel.companyName != null && viewModel.companyName!.isNotEmpty) {
      parts.add(viewModel.companyName!);
    }
    if (viewModel.education != null && viewModel.education!.isNotEmpty) {
      parts.add(viewModel.education!);
    }
    if (viewModel.collegeName != null && viewModel.collegeName!.isNotEmpty) {
      parts.add(viewModel.collegeName!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Add work & education';
  }
}

class _SaveProfileDialog extends StatelessWidget {
  final ProfileViewModel viewModel;

  const _SaveProfileDialog({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Updating Profile',
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.isUploadingPhotos)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          value: viewModel.uploadProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Uploading photos ${(viewModel.uploadProgress * 100).toInt()}%',
                          style: getTextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else if (viewModel.isLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Saving changes...',
                          style: getTextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final Uint8List? localBytes;
  final String? networkImage;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PhotoBox({
    required this.localBytes,
    required this.networkImage,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = localBytes != null || networkImage != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          image: hasImage
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: localBytes != null
                      ? MemoryImage(localBytes!)
                      : AppNetworkImage.provider(
                          networkImage!,
                          memCacheWidth: 400,
                        ),
                )
              : null,
        ),
        child: !hasImage
            ? const Center(child: Icon(Icons.add, size: 40, color: Colors.grey))
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
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

class _EditSection extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;

  const _EditSection({
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
