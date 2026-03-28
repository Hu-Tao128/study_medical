import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/backend_api.dart';
import '../../../core/network/backend_api_client.dart';
import '../data/chat_message_model.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _senderIdController;
  late final TextEditingController _messageController;

  List<ChatMessageModel> _messages = const <ChatMessageModel>[];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController();
    _senderIdController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _senderIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final roomId = _roomIdController.text.trim();
    if (roomId.isEmpty) {
      setState(() => _error = 'Ingresa roomId');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<BackendApi>();
      final history = await api.getChatHistory(roomId);
      if (!mounted) return;
      setState(() {
        _messages = history;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final roomId = _roomIdController.text.trim();
    final senderId = _senderIdController.text.trim();
    final text = _messageController.text.trim();
    if (roomId.isEmpty || senderId.isEmpty || text.isEmpty) {
      setState(() => _error = 'Completa roomId, senderId y mensaje');
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final api = context.read<BackendApi>();
      await api.sendChatMessage(
        roomId,
        ChatMessageRequest(senderId: senderId, text: text),
      );
      _messageController.clear();
      await _loadHistory();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups / Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'roomId',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _senderIdController,
              decoration: const InputDecoration(
                labelText: 'senderId',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Mensaje',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _loadHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Cargar historial'),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(message.text),
                          subtitle: Text(
                            '${message.senderId} · ${message.type}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
