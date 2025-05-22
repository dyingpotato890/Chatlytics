import 'package:chatlytics/models/data.dart';
import 'package:flutter/material.dart';

class FirstLastMessageWidget extends StatelessWidget {
  final Data messageData;

  const FirstLastMessageWidget({
    super.key,
    required this.messageData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First message
        const Text(
          "First Message",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF075E54), // WhatsApp dark green
          ),
        ),
        const SizedBox(height: 12),
        _buildMessageCard(
          messageData.firstMessage.sender,
          messageData.firstMessage.date,
          messageData.firstMessage.time,
          messageData.firstMessage.message,
        ),

        const SizedBox(height: 24),
        const Divider(color: Color.fromARGB(255, 180, 182, 182)),
        const SizedBox(height: 16),

        // Last message
        const Text(
          "Last Message",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF075E54), // WhatsApp dark green
          ),
        ),
        const SizedBox(height: 12),

        _buildMessageCard(
          messageData.lastMessage.sender,
          messageData.lastMessage.date,
          messageData.lastMessage.time,
          messageData.lastMessage.message,
        ),
      ],
    );
  }

  Widget _buildMessageCard(
    String sender,
    String date,
    String time,
    String message,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _getAvatarColor(sender),
                child: Text(
                  sender.isNotEmpty ? sender[0] : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2C34), // WhatsApp text color
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$date • $time",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667781), // WhatsApp secondary text
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2C34)),
            ),
          ),
        ],
      ),
    );
  }

  // Get a consistent color based on a username
  Color _getAvatarColor(String name) {
    final List<Color> colors = [
      const Color(0xFF25D366), // WhatsApp light green
      const Color(0xFF34B7F1), // WhatsApp blue
      const Color(0xFFFFA726), // Orange
      const Color(0xFFAB47BC), // Purple
    ];

    // Simple hash function to get consistent colors
    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
  }
}