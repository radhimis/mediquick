import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class CustomerChatPage extends StatefulWidget {
  @override
  _CustomerChatPageState createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  String? sessionId;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _sessionStarted = false;
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    // In a real app, you'd check for existing session based on user authentication
    // For demo purposes, we'll create a new session each time
    setState(() {
      _sessionStarted = false;
    });
  }

  Future<void> _startChatSession() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      final sessionData = {
        'customer_name': _nameController.text.trim(),
        'status': 'active',
        'last_message_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final result = await client
          .from('chat_sessions')
          .insert(sessionData)
          .select()
          .single();

      setState(() {
        sessionId = result['id'];
        _sessionStarted = true;
        _isLoading = false;
      });

      // Send initial greeting message
      await _sendInitialMessage();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting chat: ${e.toString() ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendInitialMessage() async {
    if (sessionId == null) return;

    try {
      final client = Supabase.instance.client;
      final messageData = {
        'session_id': sessionId,
        'sender_type': 'customer',
        'message': 'Hello! I need help with my order.',
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('chat_messages').insert(messageData);
      _loadMessages();
    } catch (e) {
      print('Error sending initial message: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (sessionId == null) return;

    // Cancel previous subscription
    _messagesSubscription?.cancel();

    try {
      final client = Supabase.instance.client;
      final data = await client
          .from('chat_messages')
          .select('*')
          .eq('session_id', sessionId!)
          .order('created_at', ascending: true);

      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
      });

      // Set up real-time subscription for new messages
      _messagesSubscription = client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('session_id', sessionId!)
          .listen((List<Map<String, dynamic>> data) {
            if (mounted) {
              setState(() {
                messages = data..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
              });
            }
          });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || sessionId == null) return;

    try {
      final client = Supabase.instance.client;
      final messageData = <String, Object>{
        'session_id': sessionId!,
        'sender_type': 'customer',
        'message': _messageController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await client.from('chat_messages').insert(messageData);

      // Update session's last message time
      await client
          .from('chat_sessions')
          .update(<String, Object>{'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId!);

      _messageController.clear();
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: ' + (e.toString() ?? 'Unknown error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Pharmacy'),
        backgroundColor: Color(0xFF1E90FF),
        actions: [
          if (_sessionStarted)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadMessages,
              tooltip: 'Refresh Messages',
            ),
        ],
      ),
      body: !_sessionStarted
          ? _buildStartChatScreen()
          : _buildChatScreen(),
    );
  }

  Widget _buildStartChatScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Color(0xFF1E90FF),
          ),
          SizedBox(height: 24),
          Text(
            'Welcome to MediQuick Chat Support',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E90FF),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Get instant help with your orders, prescriptions, and any pharmacy-related questions.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startChatSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E90FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Start Chat',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen() {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1E90FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.local_pharmacy, color: Color(0xFF1E90FF)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MediQuick Pharmacy Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Typically replies instantly',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Starting conversation...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCustomer = message['sender_type'] == 'customer';

                    return Align(
                      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isCustomer ? Color(0xFF1E90FF) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'] ?? '',
                              style: TextStyle(
                                color: isCustomer ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatMessageTime(message['created_at']),
                              style: TextStyle(
                                fontSize: 10,
                                color: isCustomer ? Colors.white.withOpacity(0.7) : Colors.grey[600],
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
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
