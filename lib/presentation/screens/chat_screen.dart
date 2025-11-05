import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/projects_provider.dart';
import '../../business_logic/providers/messages_provider.dart';
import '../widgets/message_bubble.dart';
import 'knowledge_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    
    if (projectsProvider.currentProject != null) {
      await messagesProvider.loadMessages(projectsProvider.currentProject!.id);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);

    final content = _messageController.text.trim();
    _messageController.clear();

    await messagesProvider.sendMessage(
      projectsProvider.currentProject!.id,
      content,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProjectsProvider>(
          builder: (context, projectsProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(projectsProvider.currentProject?.name ?? 'Chat'),
                const Text(
                  'Manus AI Assistant',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Knowledge Base',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KnowledgeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<MessagesProvider>(
              builder: (context, messagesProvider, child) {
                if (messagesProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messagesProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation with Manus',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messagesProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = messagesProvider.messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<MessagesProvider>(
                  builder: (context, messagesProvider, child) {
                    return FloatingActionButton(
                      onPressed: messagesProvider.isLoading ? null : _sendMessage,
                      mini: true,
                      child: messagesProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
