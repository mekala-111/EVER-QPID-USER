import 'dart:convert';
import 'dart:developer';
import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageLocalStorage {
  static const String _keyPrefix = 'chat_history_';

  Future<void> saveChatHistory(
    String receiverId,
    List<ChatMessageModel> messages,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + receiverId;

      final jsonList = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(key, jsonString);
      log('💾 Saved ${messages.length} messages for $receiverId');
    } catch (e) {
      log('❌ Error saving chat history: $e');
    }
  }

  Future<List<ChatMessageModel>> loadChatHistory(String receiverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + receiverId;

      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        log('📭 No local chat history for $receiverId');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      final messages = jsonList
          .map(
              (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      log('📂 Loaded ${messages.length} messages for $receiverId');
      return messages;
    } catch (e) {
      log('❌ Error loading chat history: $e');
      return [];
    }
  }

  Future<void> clearChatHistory(String receiverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + receiverId;
      await prefs.remove(key);
      log('🗑️ Cleared chat history for $receiverId');
    } catch (e) {
      log('❌ Error clearing chat history: $e');
    }
  }

  Future<void> clearAllChatHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }

      log('🗑️ Cleared all chat histories');
    } catch (e) {
      log('❌ Error clearing all chat histories: $e');
    }
  }

  Future<void> appendMessage(
    String receiverId,
    ChatMessageModel message,
  ) async {
    try {
      final existingMessages = await loadChatHistory(receiverId);

      final isDuplicate = existingMessages.any((m) => m.id == message.id);
      if (isDuplicate) {
        log('⚠️ Message ${message.id} already exists, skipping');
        return;
      }

      existingMessages.add(message);
      await saveChatHistory(receiverId, existingMessages);
      log('➕ Appended message to local storage');
    } catch (e) {
      log('❌ Error appending message: $e');
    }
  }

  Future<void> markMessagesAsRead(String receiverId, String senderId) async {
    try {
      final messages = await loadChatHistory(receiverId);

      bool updated = false;
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].senderId == senderId && !messages[i].isRead) {
          messages[i] = messages[i].copyWith(isRead: true);
          updated = true;
        }
      }

      if (updated) {
        await saveChatHistory(receiverId, messages);
        log('✅ Marked messages as read in local storage');
      }
    } catch (e) {
      log('❌ Error marking messages as read: $e');
    }
  }

  // ✅ NEW: Mark messages as seen (purple tick)
  Future<void> markMessagesAsSeen(String receiverId, String senderId) async {
    try {
      final messages = await loadChatHistory(receiverId);

      bool updated = false;
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].senderId == senderId) {
          messages[i] = messages[i].copyWith(
            isRead: true,
            // isSeen: true,
          );
          updated = true;
        }
      }

      if (updated) {
        await saveChatHistory(receiverId, messages);
        log('👁️ Marked messages as SEEN in local storage');
      }
    } catch (e) {
      log('❌ Error marking messages as seen: $e');
    }
  }
}
