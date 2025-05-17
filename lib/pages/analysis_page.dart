import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final List<bool> _expanded = [true, false, false];

  void _togglePanel(int index) {
    setState(() {
      _expanded[index] = !_expanded[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp Chat Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(
        0xFF121B22,
      ), // Dark background similar to WhatsApp dark theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAnimatedPanel(
                  0,
                  "MESSAGES PER USER",
                  const Color(0xFF056162), // WhatsApp darker green
                  Icons.message,
                ),
                _buildAnimatedPanel(
                  1,
                  "TOP 5 MOST USED WORDS",
                  const Color(0xFF056162),
                  Icons.text_fields,
                ),
                _buildAnimatedPanel(
                  2,
                  "TOP 5 EMOJIS",
                  const Color(0xFF056162),
                  Icons.emoji_emotions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPanel(
    int index,
    String title,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _togglePanel(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded[index]
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  _expanded[index]
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              firstChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _getPanelContent(index),
              ),
              secondChild: const SizedBox(height: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPanelContent(int index) {
    switch (index) {
      case 0:
        return _buildMessagesPerUserContent();
      case 1:
        return _buildTopWordsContent();
      case 2:
        return _buildTopEmojisContent();
      default:
        return const Text(
          "Unknown Panel",
          style: TextStyle(color: Colors.white),
        );
    }
  }

  Widget _buildMessagesPerUserContent() {
    // Sample data for demonstration
    final Map<String, int> messageData = {
      "John": 342,
      "Alice": 289,
      "Bob": 178,
      "Emma": 156,
    };

    // Calculate total messages
    final int totalMessages = messageData.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section with total messages
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          width: double.infinity,
          child: Column(
            children: [
              Text(
                "$totalMessages",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Total Messages",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                "Jan 1, 2023 - Apr 30, 2023",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white24),
        const SizedBox(height: 16),

        // Heading for percentage section
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 16),
          child: Text(
            "Messages Per User",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Messages per user with percentage bars
        ...messageData.entries.map((entry) {
          final String userName = entry.key;
          final int userMessages = entry.value;
          final double percentage = (userMessages / totalMessages) * 100;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "$userMessages messages",
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopWordsContent() {
    // Sample data for demonstration
    final List<Map<String, dynamic>> topWords = [
      {"word": "haha", "count": 245},
      {"word": "ok", "count": 189},
      {"word": "cool", "count": 156},
      {"word": "yes", "count": 134},
      {"word": "thanks", "count": 98},
    ];

    return Column(
      children: [
        ...topWords.map(
          (wordData) => _buildWordItem(
            wordData["word"],
            wordData["count"],
            (wordData["count"] / topWords.first["count"]) * 0.8 + 0.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Based on 965 messages analyzed",
          style: TextStyle(fontSize: 14, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWordItem(String word, int count, double ratio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                word,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white24,
              color: Colors.teal.shade300,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopEmojisContent() {
    // Sample data for demonstration
    final List<Map<String, dynamic>> topEmojis = [
      {"emoji": "😂", "count": 176},
      {"emoji": "👍", "count": 145},
      {"emoji": "❤️", "count": 89},
      {"emoji": "😊", "count": 67},
      {"emoji": "🎉", "count": 43},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                topEmojis
                    .map(
                      (emojiData) => _buildEmojiItem(
                        emojiData["emoji"],
                        emojiData["count"],
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Total Emojis Used: 520",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "That's about 0.54 emojis per message!",
          style: TextStyle(fontSize: 14, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmojiItem(String emoji, int count) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
