import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Features/messages/view/widgets/audio_player_widget.dart';
import 'package:everqpidapp/Features/messages/view/widgets/full_screen_image_viewer.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool dark;

  const MessageBubble({
    super.key,
    required this.message,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == ChatMessageModel.myUserId;

    if (message.type == ChatMessageType.text &&
        message.content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    if (message.type == ChatMessageType.audio &&
        message.mediaUrl.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    if (message.type == ChatMessageType.image &&
        message.mediaUrl.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final incomingText = dark ? Colors.white : Colors.black;

    Widget content;

    switch (message.type) {
      case ChatMessageType.text:
        content = Text(
          message.content,
          style: getTextStyle(
            fontSize: 15,
            color: isMe ? Colors.white : incomingText,
            height: 1.4,
          ),
        );
        break;

      case ChatMessageType.image:
        content = InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(
                  imageUrl: message.mediaUrl,
                  senderName: isMe ? 'You' : 'Sender',
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AppNetworkImage(
              url: message.mediaUrl,
              width: 200,
              height: 200,
              memCacheWidth: 400,
            ),
          ),
        );
        break;

      case ChatMessageType.audio:
        content = AudioPlayerWidget(
          audioUrl: message.mediaUrl,
          isSentByMe: isMe,
          darkIncoming: dark && !isMe,
        );
        break;
    }

    final bubbleDecoration = isMe
        ? BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      WelcomeTheme.violetSoft,
                      WelcomeTheme.violetDeep,
                      Color(0xFF5B21B6),
                    ],
                  )
                : null,
            color: dark ? null : PColors.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(4),
            ),
          )
        : BoxDecoration(
            color: dark ? const Color(0xFF1A1228) : const Color(0xFFF0F0F0),
            border: dark
                ? Border.all(
                    color: WelcomeTheme.violet.withValues(alpha: 0.22),
                  )
                : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * (dark ? 0.45 : 0.7),
              minWidth: message.type == ChatMessageType.audio ? 250 : 0,
            ),
            padding: message.type == ChatMessageType.text
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : message.type == ChatMessageType.audio
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    : const EdgeInsets.all(8),
            decoration: bubbleDecoration,
            child: content,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TimeOfDay.fromDateTime(
                  message.sentAt.toLocal(),
                ).format(context),
                style: getTextStyle(
                  fontSize: 12,
                  color: dark ? const Color(0xFF8E879E) : Colors.grey[500],
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color: message.isRead
                      ? (dark ? WelcomeTheme.violetLight : PColors.primaryColor)
                      : (dark ? const Color(0xFF8E879E) : Colors.grey[500]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
