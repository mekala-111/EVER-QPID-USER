// features/clan/view/clan_screen.dart

import 'package:everqpidapp/Features/clan2.0/view/desktop/desktop_clan_view.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/clan_view_model.dart';

class ClanScreen extends StatefulWidget {
  final String userId;

  const ClanScreen({super.key, required this.userId});

  @override
  State<ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends State<ClanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ClanViewModel>();
      if (!viewModel.purposeSelected) {
        viewModel.clearSelectedClanSilent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Desktop/tablet: premium coming-soon inside MainScreen sidebar shell.
    // Mobile: keep the existing centered illustration.
    if (!context.isMobile) {
      return const DesktopClanView();
    }

    return Center(
      child: Image.asset(Images.clanSoon),
    );
  }
}
