import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Features/messages/view_model/chat_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class Otherprofile extends StatefulWidget {
  final String profileId;
  const Otherprofile({super.key, required this.profileId});

  @override
  State<Otherprofile> createState() => _OtherprofileState();
}

class _OtherprofileState extends State<Otherprofile> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChatViewModel>().fetchReceiverProfile();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, vm, _) {
          final p = vm.receiverProfile;

          if (_isLoading || p == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────────────── PROFILE IMAGE ─────────────────
                Stack(
                  children: [
                    Container(
                      height: size.height * 0.55,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        image: DecorationImage(
                          image: p.profileImageUrl.isNotEmpty
                              ? AppNetworkImage.provider(
                                  p.profileImageUrl,
                                  memCacheWidth: 800,
                                )
                              : const AssetImage(
                                  'assets/images/profile_placeholder.png',
                                ) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: size.height * 0.55,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 30,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${p.fullName}, ${p.age}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (p.isVerified)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.education.isNotEmpty ? p.education : '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ───────────────── INTERESTS ─────────────────
                if (p.interests.isNotEmpty)
                  _section(
                    title: 'We can talk about',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: p.interests.map(_chip).toList(),
                    ),
                  ),

                // ───────────────── LANGUAGES ─────────────────
                if (p.otherLanguages.isNotEmpty)
                  _section(
                    title: 'Languages',
                    child: Wrap(
                      spacing: 10,
                      children: p.otherLanguages.map(_chip).toList(),
                    ),
                  ),

                // ───────────────── ABOUT ─────────────────
                _section(
                  title: 'This is Me',
                  child: p.aboutMe.isNotEmpty
                      ? Text(
                          p.aboutMe,
                          style: const TextStyle(fontSize: 14),
                        )
                      : _noData('This user hasn’t added a bio yet'),
                ),

                // ───────────────── BASICS ─────────────────
                _buildBasicsSection(p),

                // ───────────────── PROFESSION ─────────────────
                if (p.currentProfession.isNotEmpty || p.companyName.isNotEmpty)
                  _section(
                    title: 'Profession',
                    child: Wrap(
                      spacing: 10,
                      children: [
                        if (p.currentProfession.isNotEmpty)
                          _chip(p.currentProfession),
                        if (p.companyName.isNotEmpty) _chip(p.companyName),
                      ],
                    ),
                  ),

                // ───────────────── EDUCATION ─────────────────
                if (p.education.isNotEmpty || p.graduationYear > 0)
                  _section(
                    title: 'Education',
                    child: Wrap(
                      spacing: 10,
                      children: [
                        if (p.education.isNotEmpty) _chip(p.education),
                        if (p.graduationYear > 0)
                          _chip(p.graduationYear.toString()),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────── HELPERS ─────────────────

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _noData(String message) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildBasicsSection(dynamic p) {
    final basics = <String>[
      p.relationshipStatus,
      p.height > 0 ? '${p.height} cm' : '',
      p.religion,
      p.locationString,
      p.smokingHabit,
      p.alcoholConsumption,
    ].where((e) => e.isNotEmpty).toList();

    if (basics.isEmpty) return const SizedBox.shrink();

    return _section(
      title: 'Basics',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: basics.map(_chip).toList(),
      ),
    );
  }
}
