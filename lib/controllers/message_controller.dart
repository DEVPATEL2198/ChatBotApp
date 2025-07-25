import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Added for jsonDecode and jsonEncode

import '../services/api_service.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isTyping = false.obs;
  String? userName;

  // Multi-session support
  var allSessions = <String, List<Map<String, dynamic>>>{}.obs;
  var currentSession = "Default".obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _loadSessions();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
  }

  Future<void> rememberUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    userName = name;
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsData = prefs.getString('allSessions');
    if (sessionsData != null) {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(jsonDecode(sessionsData));
      allSessions.value = decoded.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v)));
      if (allSessions.containsKey(currentSession.value)) {
        messages.value = List<Map<String, dynamic>>.from(allSessions[currentSession.value]!);
      } else if (allSessions.isNotEmpty) {
        currentSession.value = allSessions.keys.first;
        messages.value = List<Map<String, dynamic>>.from(allSessions[currentSession.value]!);
      }
    } else {
      allSessions.value = {"Default": []};
      currentSession.value = "Default";
      messages.value = [];
      await _saveSessions();
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('allSessions', jsonEncode(allSessions));
  }

  void switchSession(String sessionName) {
    if (allSessions.containsKey(sessionName)) {
      currentSession.value = sessionName;
      messages.value = List<Map<String, dynamic>>.from(allSessions[sessionName]!);
    }
  }

  Future<void> createSession(String sessionName) async {
    if (!allSessions.containsKey(sessionName)) {
      allSessions[sessionName] = [];
      await _saveSessions();
      switchSession(sessionName);
    }
  }

  Future<void> deleteSession(String sessionName) async {
    if (allSessions.length > 1 && allSessions.containsKey(sessionName)) {
      allSessions.remove(sessionName);
      await _saveSessions();
      // Switch to another session
      final nextSession = allSessions.keys.first;
      switchSession(nextSession);
    }
  }

  Future<void> renameSession(String oldName, String newName) async {
    if (allSessions.containsKey(oldName) && !allSessions.containsKey(newName)) {
      allSessions[newName] = allSessions.remove(oldName)!;
      if (currentSession.value == oldName) {
        currentSession.value = newName;
      }
      await _saveSessions();
    }
  }

  @override
  void onClose() {
    allSessions[currentSession.value] = List<Map<String, dynamic>>.from(messages);
    _saveSessions();
    super.onClose();
  }

  Future<void> sendMessage(String message) async {
    messages.add(
      {
        'text': message,
        'isUser': true,
        'time': DateFormat('hh:mm a').format(DateTime.now())
      },
    );
    allSessions[currentSession.value] = List<Map<String, dynamic>>.from(messages);
    await _saveSessions();

    responseText.value = "Thinking..";
    isTyping.value = true;
    update();

    // Build conversation context with userName if available
    List<Map<String, dynamic>> contextMessages = List.from(messages);
    if (userName != null && userName!.isNotEmpty) {
      contextMessages.insert(0, {
        'text': 'My name is $userName.',
        'isUser': true,
        'time': ''
      });
    }

    String reply = await GoogleApiService.getApiResponse(contextMessages);

    responseText.value = reply;

    messages.add(
      {
        'text': reply,
        'isUser': false,
        'time': DateFormat('hh:mm a').format(DateTime.now())
      },
    );
    allSessions[currentSession.value] = List<Map<String, dynamic>>.from(messages);
    await _saveSessions();

    isTyping.value = false;
    update();
  }
}