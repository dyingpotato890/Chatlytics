import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:chatlytics/models/data.dart';

class MessagesPerUserWidget extends StatelessWidget {
  final Data messageData;

  const MessagesPerUserWidget({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    // Get user message data
    final Map<String, int> messageData = this.messageData.userMessagesCount;
    int totalMessages = this.messageData.messageCount;

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
                    style: TextStyle(fontSize: 14, color: ColorUtils.whatsappSecondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    this.messageData.messageCount.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappLightGreen,
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

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

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
                          backgroundColor: ColorUtils.getAvatarColor(userName),
                          child: Text(
                            userName.isNotEmpty ? userName[0] : "?",
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
                            color: ColorUtils.whatsappTextColor,
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
                        color: ColorUtils.whatsappLightGreen.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.whatsappDarkGreen,
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
                        color: ColorUtils.whatsappDivider,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuart,
                      height: 10,
                      width: MediaQuery.of(context).size.width *
                          (percentage / 100) *
                          0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorUtils.getProgressColor(userName),
                            ColorUtils.getProgressColor(userName).withAlpha(179),
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorUtils.whatsappSecondaryText,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}