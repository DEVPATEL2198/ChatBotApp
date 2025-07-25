import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/message_controller.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'dart:ui';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController chatMessageController = Get.put(MessageController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    chatMessageController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
    messageController.addListener(() {
      setState(() {}); // Rebuild to update send button visibility
    });
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      backgroundColor: isUser ? Theme.of(context).colorScheme.primary : Colors.grey[300],
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? Colors.white : Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Chats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Obx(() => ListView(
                  children: chatMessageController.allSessions.keys.map((session) {
                    final isSelected = session == chatMessageController.currentSession.value;
                    return ListTile(
                      title: Text(session, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected,
                      onTap: () {
                        Navigator.of(context).pop();
                        chatMessageController.switchSession(session);
                        setState(() {});
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            tooltip: 'Rename',
                            onPressed: () async {
                              final newName = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  final TextEditingController renameController = TextEditingController(text: session);
                                  return AlertDialog(
                                    title: const Text('Rename Chat'),
                                    content: TextField(
                                      controller: renameController,
                                      decoration: const InputDecoration(hintText: 'Chat name'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(renameController.text.trim()),
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (newName != null && newName.isNotEmpty && newName != session) {
                                await chatMessageController.renameSession(session, newName);
                                setState(() {});
                              }
                            },
                          ),
                          if (chatMessageController.allSessions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              tooltip: 'Delete',
                              onPressed: () async {
                                await chatMessageController.deleteSession(session);
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('New Chat'),
                  onPressed: () async {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final TextEditingController newChatController = TextEditingController();
                        return AlertDialog(
                          title: const Text('New Chat'),
                          content: TextField(
                            controller: newChatController,
                            decoration: const InputDecoration(hintText: 'Chat name'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(newChatController.text.trim()),
                              child: const Text('Create'),
                            ),
                          ],
                        );
                      },
                    );
                    if (newName != null && newName.isNotEmpty) {
                      await chatMessageController.createSession(newName);
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Gradient AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.deepPurple, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      "TechiBot",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.deepPurple),
                      tooltip: "Set your name",
                      onPressed: () async {
                        final name = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final TextEditingController nameController = TextEditingController();
                            return AlertDialog(
                              title: const Text("Enter your name"),
                              content: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(hintText: "Your name"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(nameController.text.trim()),
                                  child: const Text("Save"),
                                ),
                              ],
                            );
                          },
                        );
                        if (name != null && name.isNotEmpty) {
                          await chatMessageController.rememberUserName(name);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: chatMessageController.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessageController.messages[index];
                      final isUser = message['isUser'];
                      final time = message['time'];
                      return Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser) ...[
                            _buildAvatar(false),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? (isDark ? Colors.deepPurple[400] : const Color(0xFF25D366))
                                    : (isDark ? Colors.grey[800] : Colors.white.withOpacity(0.7)),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'],
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: isUser ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isUser ? Colors.white70 : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 8),
                            _buildAvatar(true),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
              Obx(
                () => chatMessageController.isTyping.value
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                chatMessageController.responseText.value,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              style: const TextStyle(color: Colors.black),
                              onFieldSubmitted: (value) async {
                                if (value.trim().isNotEmpty && !isSending) {
                                  setState(() => isSending = true);
                                  await chatMessageController.sendMessage(value.trim());
                                  messageController.clear();
                                  setState(() => isSending = false);
                                }
                              },
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: messageController.text.isNotEmpty
                                ? IconButton(
                                    key: const ValueKey('send'),
                                    icon: const Icon(Icons.send_rounded, color: Color(0XFF25D366), size: 28),
                                    onPressed: isSending
                                        ? null
                                        : () async {
                                            setState(() => isSending = true);
                                            await chatMessageController.sendMessage(messageController.text.trim());
                                            messageController.clear();
                                            setState(() => isSending = false);
                                          },
                                  )
                                : IconButton(
                                    key: const ValueKey('emoji'),
                                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.deepPurple, size: 28),
                                    onPressed: () {},
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}