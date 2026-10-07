import 'dart:developer';

import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/messages/service/audio_recording_service.dart';
import 'package:everqpidapp/Features/messages/view/widgets/message_bubble_widget.dart';
import 'package:everqpidapp/Features/messages/view/widgets/otherprofile.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profileactions/view/profile_action_bottom_sheet.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Features/messages/view_model/chat_view_model.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String name;
  final String imageUrl;
  final bool isOnline;

  /// When true, renders inside a desktop split pane (no route pop / main-tab redirect).
  final bool embedded;
  final VoidCallback? onClose;

  /// Dark violet chrome for desktop embedded chat panel.
  final bool darkChrome;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
    this.embedded = false,
    this.onClose,
    this.darkChrome = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecordingService _audioService = AudioRecordingService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isTyping = false;
  bool _isRecordingAudio = false;
  bool _hasText = false;
  Duration _recordingDuration = Duration.zero;
  double _slideOffset = 0.0;

  // ✅ NEW: Track if user manually scrolled up
  final bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateHasText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ChatViewModel>();
      vm.initChat(
        receiverId: widget.receiverId,
        name: widget.name,
        imageUrl: widget.imageUrl,
        isOnline: widget.isOnline,
      );

      log('isOnline: ${widget.isOnline}');
    });
  }

  @override
  void dispose() {
    context.read<ChatViewModel>().onChatInvisible();
    _messageController.removeListener(_updateHasText);
    _messageController.dispose();
    _scrollController.dispose();
    _audioService.onDurationUpdate = null;
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _sendMessage(ChatViewModel vm) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    vm.sendTextMessage(text);
    _messageController.clear();
    vm.stopTyping();
  }

  Future<void> _startRecording() async {
    final success = await _audioService.startRecording();
    if (success) {
      setState(() {
        _isRecordingAudio = true;
        _recordingDuration = Duration.zero;
      });

      _audioService.onDurationUpdate = (duration) {
        if (mounted) {
          setState(() => _recordingDuration = duration);
        }
      };
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecordingAndSend(ChatViewModel vm) async {
    final audioBytes = await _audioService.stopRecording();

    setState(() {
      _isRecordingAudio = false;
      _recordingDuration = Duration.zero;
      _slideOffset = 0.0;
    });

    if (audioBytes != null) {
      await vm.uploadAndSendAudio(audioBytes);
    }
  }

  Future<void> _cancelRecording() async {
    await _audioService.cancelRecording();
    setState(() {
      _isRecordingAudio = false;
      _recordingDuration = Duration.zero;
      _slideOffset = 0.0;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _pickAndSendImage(ChatViewModel vm, ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Uploading image...'),
                ],
              ),
              duration: Duration(seconds: 30),
            ),
          );
        }

        await vm.uploadAndSendImage(await pickedFile.readAsBytes());

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image sent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;

    // ✅ Use addPostFrameCallback to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showImageSourceDialog(ChatViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: PColors.primaryColor),
                ),
                title: Text(
                  'Camera',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(vm, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: PColors.primaryColor),
                ),
                title: Text(
                  'Gallery',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndSendImage(vm, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, vm, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return WillPopScope(
          onWillPop: () async {
            if (widget.embedded) {
              widget.onClose?.call();
              return false;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              PPages.mainScreen,
              (route) => false,
              arguments: {'tabIndex': 3},
            );
            return false;
          },
          child: Scaffold(
            backgroundColor: widget.darkChrome
                ? Colors.transparent
                : const Color(0xFFF8F8F8),
            appBar: AppBar(
              backgroundColor: widget.darkChrome
                  ? const Color(0xFF0B0615).withValues(alpha: 0.85)
                  : Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(
                  widget.embedded ? Icons.close : Icons.arrow_back_ios,
                  color: widget.darkChrome ? Colors.white70 : Colors.black,
                ),
                onPressed: () {
                  if (widget.embedded) {
                    widget.onClose?.call();
                    return;
                  }
                  Navigator.pop(context);
                  MainScreenBridge.navigateToTab(3);
                },
              ),
              title: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Otherprofile(
                        profileId: widget.receiverId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.imageUrl.isNotEmpty
                          ? AppNetworkImage.provider(
                              widget.imageUrl,
                              memCacheWidth: 80,
                            )
                          : null,
                      child: widget.imageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: widget.darkChrome
                                  ? Colors.white54
                                  : null,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.darkChrome
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        Text(
                          vm.isReceiverOnline ? '● Online' : 'Offline',
                          style: getTextStyle(
                            fontSize: 12,
                            color: vm.isReceiverOnline
                                ? const Color(0xFF22C55E)
                                : (widget.darkChrome
                                    ? const Color(0xFF8E879E)
                                    : Colors.grey[500]),
                          ),
                        ),
                        if (vm.isTyping)
                          Text(
                            'Typing...',
                            style: getTextStyle(
                              fontSize: 11,
                              color: widget.darkChrome
                                  ? WelcomeTheme.violetLight
                                  : PColors.primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                if (widget.darkChrome)
                  IconButton(
                    tooltip: 'Profile',
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Otherprofile(
                            profileId: widget.receiverId,
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: widget.darkChrome ? Colors.white70 : Colors.black,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => ProfileActionsBottomSheet(
                        userId: widget.receiverId,
                        userName: widget.name,
                        onActionCompleted: () async {},
                      ),
                    );
                  },
                ),
              ],
            ),
            body: widget.embedded
                ? _buildChatBody(vm)
                : AppContentFrame(
                    maxWidth: ContentMaxWidth.chat,
                    child: _buildChatBody(vm),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildChatBody(ChatViewModel vm) {
    return Column(
      children: [
        Selector<ChatViewModel, (bool, String)>(
          selector: (_, chatVm) => (
            chatVm.isSubscriptionRestricted,
            chatVm.subscriptionErrorMessage,
          ),
          builder: (context, state, _) {
            if (!state.$1) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.orange[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.$2,
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showSubscriptionBottomSheet(
                        context: context,
                        title: 'Subscribe to Continue',
                        message: state.$2,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: PColors.primaryColor,
                    ),
                    child: Text(
                      'Subscribe',
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: PColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: Stack(
            children: [
              vm.isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : vm.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: getTextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start the conversation!',
                                style: getTextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          cacheExtent: 500,
                          itemCount: vm.messages.length,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: MessageBubble(
                                message: vm.messages[index],
                                dark: widget.darkChrome,
                              ),
                            );
                          },
                        ),
              if (_showScrollToBottomButton && vm.messages.isNotEmpty)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: _scrollToBottom,
                    backgroundColor: PColors.primaryColor,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _isRecordingAudio ? _buildRecordingUI(vm) : _buildInputUI(vm),
      ],
    );
  }

  Widget _buildInputUI(ChatViewModel vm) {
    final dark = widget.darkChrome;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0B0615) : Colors.white,
        border: dark
            ? Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
              )
            : null,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showImageSourceDialog(vm),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: dark ? WelcomeTheme.violetLight : PColors.primaryColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                  border: dark
                      ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                      : null,
                ),
                child: TextField(
                  controller: _messageController,
                  style: getTextStyle(
                    fontSize: 15,
                    color: dark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: dark ? 'Type a message...' : 'Your message',
                    hintStyle: getTextStyle(
                      fontSize: 15,
                      color: dark
                          ? const Color(0xFF7A728C)
                          : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    if (value.isNotEmpty && !_isTyping) {
                      _isTyping = true;
                      vm.startTyping();
                    } else if (value.isEmpty && _isTyping) {
                      _isTyping = false;
                      vm.stopTyping();
                    }
                  },
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(vm),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _hasText
                ? GestureDetector(
                    onTap: () => _sendMessage(vm),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            WelcomeTheme.violetSoft,
                            WelcomeTheme.violetDeep,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : GestureDetector(
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecordingAndSend(vm),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: dark
                            ? WelcomeTheme.violetSoft
                            : PColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingUI(ChatViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _slideOffset += details.delta.dx;
              if (_slideOffset < -100) {
                _cancelRecording();
              }
            });
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: _cancelRecording,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '< Slide to cancel',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _stopRecordingAndSend(vm),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
