import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_profile_view.dart';
import 'package:everqpidapp/Features/profile/view/mobile/mobile_profile_view.dart';
import 'package:everqpidapp/Features/profile/view/tablet/tablet_profile_view.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Settings/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Profile entry — mobile keeps existing UI; tablet/desktop use web layouts.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetProfileViewModel>().fetchProfile();
      LoggedInUser.id != null
          ? LoggedInUser.id!
          : context.read<GetProfileViewModel>().profile?.id ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _mobile,
      tablet: _tablet,
      desktop: _desktop,
    );
  }

  static Widget _mobile(BuildContext context) => const MobileProfileView();
  static Widget _tablet(BuildContext context) => const TabletProfileView();
  static Widget _desktop(BuildContext context) => const DesktopProfileView();
}
