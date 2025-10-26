import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ChatSupportPage extends StatefulWidget {
  @override
  _ChatSupportPageState createState() => _ChatSupportPageState();
}

class _ChatSupportPageState extends State<ChatSupportPage> {
  List<Map<String, dynamic>> chatSessions = [];
  bool _isLoading = true;
  String selectedSessionId = '';
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChatSessions() async {
    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('chat_sessions')
          .select('*')
          .order('last_message_at', ascending: false);

      setState(() {
        chatSessions = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading chat sessions: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMessages(String sessionId) async {
    // Cancel previous subscription
    _messagesSubscription?.cancel();

    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('chat_messages')
          .select('*')
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      setState(() {
        selectedSessionId = sessionId;
        messages = List<Map<String, dynamic>>.from(data);
      });

      // Set up real-time subscription for new messages
      _messagesSubscription = client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('session_id', sessionId)
          .listen((List<Map<String, dynamic>> data) {
            if (mounted) {
              setState(() {
                messages = data..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
              });
            }
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading messages: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || selectedSessionId.isEmpty) return;

    try {
      final client = Supabase.instance.client;
      final messageData = {
        'session_id': selectedSessionId,
        'sender_type': 'staff', // staff or customer
        'message': _messageController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('chat_messages').insert(messageData);

      // Update session's last message time
      await client
          .from('chat_sessions')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', selectedSessionId);

      _messageController.clear();
      _loadMessages(selectedSessionId);
      _loadChatSessions(); // Refresh session list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markSessionResolved(String sessionId) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('chat_sessions')
          .update({'status': 'resolved'})
          .eq('id', sessionId);

      _loadChatSessions();
      if (selectedSessionId == sessionId) {
        setState(() {
          selectedSessionId = '';
          messages = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating session: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Support'),
        backgroundColor: Color(0xFF1E90FF),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadChatSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Row(
        children: [
          // Chat Sessions List
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Text(
                    'Active Chats (${chatSessions.where((s) => s['status'] != 'resolved').length})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : chatSessions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No chat sessions yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: chatSessions.length,
                              itemBuilder: (context, index) {
                                final session = chatSessions[index];
                                final isSelected = selectedSessionId == session['id'];
                                final isResolved = session['status'] == 'resolved';

                                return Container(
                                  color: isSelected ? Color(0xFF1E90FF).withOpacity(0.1) : null,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isResolved ? Colors.green : Color(0xFF1E90FF),
                                      child: Icon(
                                        isResolved ? Icons.check : Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      session['customer_name'] ?? 'Unknown Customer',
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      session['last_message'] ?? 'No messages yet',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: isResolved
                                        ? Icon(Icons.check_circle, color: Colors.green, size: 16)
                                        : Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                    onTap: () => _loadMessages(session['id']),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // Chat Messages Area
          Expanded(
            child: selectedSessionId.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Select a chat session to view messages',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Chat Header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Color(0xFF1E90FF)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                chatSessions.firstWhere(
                                  (s) => s['id'] == selectedSessionId,
                                  orElse: () => {'customer_name': 'Unknown'},
                                )['customer_name'] ?? 'Unknown Customer',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _markSessionResolved(selectedSessionId),
                              child: Text('Mark Resolved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Messages List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isStaff = message['sender_type'] == 'staff';

                            return Align(
                              alignment: isStaff ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                decoration: BoxDecoration(
                                  color: isStaff ? Color(0xFF1E90FF) : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['message'] ?? '',
                                      style: TextStyle(
                                        color: isStaff ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatMessageTime(message['created_at']),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isStaff ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Message Input
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                maxLines: null,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            SizedBox(width: 8),
                            FloatingActionButton(
                              onPressed: _sendMessage,
                              mini: true,
                              backgroundColor: Color(0xFF1E90FF),
                              child: Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(String? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
