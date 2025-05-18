import 'package:chatlytics/models/data.dart';
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  final Data messageData;

  const AnalysisPage({super.key, required this.messageData});

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
          'Chat Analysis',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF128C7E), // Modern WhatsApp green
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {}, // Add functionality as needed
          ),
        ],
      ),
      backgroundColor: const Color(0xFF121B22), // Dark theme background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header with date range
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Jan 1, 2023 - Apr 30, 2023",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              _buildOverviewTab(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: const [
                    Text(
                      "DETAILED INSIGHTS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              _buildAnimatedPanel(
                0,
                "Messages per User",
                const Color(0xFF075E54), // WhatsApp dark green
                Icons.people_alt_rounded,
              ),
              _buildAnimatedPanel(
                1,
                "Top Words",
                const Color(0xFF075E54),
                Icons.text_fields_rounded,
              ),
              _buildAnimatedPanel(
                2,
                "Emoji Analysis",
                const Color(0xFF075E54),
                Icons.emoji_emotions_rounded,
              ),
            ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _togglePanel(index),
          splashColor: Colors.white.withAlpha(26),
          highlightColor: Colors.white.withAlpha(13),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(39),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded[index] ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
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
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: _getPanelContent(index),
                ),
                secondChild: const SizedBox(height: 0),
              ),
            ],
          ),
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

  Widget _buildOverviewTab() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSummaryCards()],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard('Total Messages', widget.messageData.messageCount.toString(), Icons.chat_bubble_rounded),
        _buildSummaryCard('Active Days', widget.messageData.activeDays.toString(), Icons.calendar_today_rounded),
        _buildSummaryCard('Media Shared', widget.messageData.mediaShared.toString(), Icons.photo_library_rounded),
        _buildSummaryCard('Participants', widget.messageData.participants.toString(), Icons.people_alt_rounded),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF128C7E), // WhatsApp green
            const Color(0xFF075E54), // WhatsApp dark green
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF128C7E).withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {}, // Add specific functionality when cards are tapped
          splashColor: Colors.white.withAlpha(26),
          highlightColor: Colors.white.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        // Total messages summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Messages",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$totalMessages",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(39),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.message_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white24, height: 32),

        // User message breakdown
        ...messageData.entries.map((entry) {
          final String userName = entry.key;
          final int userMessages = entry.value;
          final double percentage = (userMessages / totalMessages) * 100;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: _getAvatarColor(userName),
                          child: Text(
                            userName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(39),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuart,
                      height: 10,
                      width:
                          MediaQuery.of(context).size.width *
                          (percentage / 100) *
                          0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getProgressColor(userName),
                            _getProgressColor(userName).withAlpha(179),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "$userMessages messages",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
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

  // Get progress bar color based on username
  Color _getProgressColor(String name) {
    final List<Color> colors = [
      const Color(0xFF25D366), // WhatsApp light green
      const Color(0xFF34B7F1), // WhatsApp blue
      const Color(0xFFFFA726), // Orange
      const Color(0xFFAB47BC), // Purple
    ];

    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
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
        // Introduction section
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Most Used Words",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "Total Words: 9,873",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white24, height: 24),

        ...topWords.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> wordData = entry.value;
          return _buildWordItem(
            wordData["word"],
            wordData["count"],
            (wordData["count"] / topWords.first["count"]) * 0.85 + 0.15,
            index: index,
          );
        }),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                "Based on 965 messages analyzed",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordItem(
    String word,
    int count,
    double ratio, {
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 26,
            alignment: Alignment.center,
            child: Text(
              "${index + 1}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getMedalColor(index),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuart,
                      height: 8,
                      width: MediaQuery.of(context).size.width * ratio * 0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getMedalColor(index),
                            _getMedalColor(index).withAlpha(179),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF25D366); // WhatsApp green
    }
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Emoji Usage",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(39),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "520 Total",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Emoji grid with modern look
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
          ),
          itemCount: topEmojis.length,
          itemBuilder: (context, index) {
            return _buildEmojiItem(
              topEmojis[index]["emoji"],
              topEmojis[index]["count"],
              index,
            );
          },
        ),

        const SizedBox(height: 16),

        // Emoji statistics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_emotions_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Emoji Stats",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEmojiStat("0.54", "Per Message"),
                  Container(height: 24, width: 1, color: Colors.white24),
                  _buildEmojiStat("42%", "Of Messages"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEmojiItem(String emoji, int count, int index) {
    Color borderColor = Colors.transparent;

    // Add special color for top 3
    if (index < 3) {
      borderColor = _getMedalColor(index);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
