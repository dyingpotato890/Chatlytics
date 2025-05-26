import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:chatlytics/models/data.dart';

class _UserMessageData {
  final String userName;
  final int messageCount;
  final double percentage;
  final Color avatarColor;
  final Color progressColor;
  final double progressWidth;

  const _UserMessageData({
    required this.userName,
    required this.messageCount,
    required this.percentage,
    required this.avatarColor,
    required this.progressColor,
    required this.progressWidth,
  });
}

class MessagesPerUserWidget extends StatefulWidget {
  final Data messageData;

  const MessagesPerUserWidget({super.key, required this.messageData});

  @override
  State<MessagesPerUserWidget> createState() => _MessagesPerUserWidgetState();
}

class _MessagesPerUserWidgetState extends State<MessagesPerUserWidget> {
  late final List<_UserMessageData> _userDataList;
  late final int _totalMessages;

  @override
  void initState() {
    super.initState();
    _precomputeUserData();
  }

  void _precomputeUserData() {
    final Map<String, int> messageData = widget.messageData.userMessagesCount;
    _totalMessages = widget.messageData.messageCount;

    // Pre-compute all user data with colors and percentages
    _userDataList = messageData.entries.map((entry) {
      final String userName = entry.key;
      final int userMessages = entry.value;
      final double percentage = _totalMessages > 0 
          ? (userMessages / _totalMessages) * 100 
          : 0.0;

      return _UserMessageData(
        userName: userName,
        messageCount: userMessages,
        percentage: percentage,
        avatarColor: ColorUtils.getAvatarColor(userName),
        progressColor: ColorUtils.getProgressColor(userName),
        progressWidth: percentage / 100 * 0.7,
      );
    }).toList();

    // Sort by message count (highest first)
    _userDataList.sort((a, b) => b.messageCount.compareTo(a.messageCount));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total messages summary
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Messages",
                      style: TextStyle(
                        fontSize: 14, 
                        color: ColorUtils.whatsappSecondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _totalMessages.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ColorUtils.whatsappDarkGreen,
                      ),
                    ),
                  ],
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: ColorUtils.whatsappLightGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.message_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

        // User message breakdown
        ..._userDataList.map((userData) => _buildUserMessageCard(userData)),
      ],
    );
  }

  Widget _buildUserMessageCard(_UserMessageData userData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    backgroundColor: userData.avatarColor,
                    child: Text(
                      userData.userName.isNotEmpty ? userData.userName[0] : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    userData.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorUtils.whatsappTextColor,
                    ),
                  ),
                ],
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappLightGreen.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    "${userData.percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(userData),
          const SizedBox(height: 6),
          Text(
            "${userData.messageCount} messages",
            style: const TextStyle(
              fontSize: 13,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(_UserMessageData userData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double progressWidth = constraints.maxWidth * userData.progressWidth;
        
        return Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: ColorUtils.whatsappDivider,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SizedBox(
                height: 10,
                width: double.infinity,
              ),
            ),
            Container(
              height: 10,
              width: progressWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    userData.progressColor,
                    userData.progressColor.withAlpha(179),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        );
      },
    );
  }
}