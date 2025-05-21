import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:chatlytics/models/data.dart';

class OverviewWidget extends StatelessWidget {
  final Data messageData;

  const OverviewWidget({super.key, required this.messageData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured metric - Total Messages
          _buildFeaturedMetricCard(),
          const SizedBox(height: 16),
          // Secondary metrics in a row
          _buildSecondaryMetricsRow(),
        ],
      ),
    );
  }

  Widget _buildFeaturedMetricCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorUtils.whatsappLightGreen,
            ColorUtils.whatsappDarkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF128C7E).withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {}, // Add functionality when card is tapped
          splashColor: Colors.white.withAlpha(26),
          highlightColor: Colors.white.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Messages",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      messageData.messageCount.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "messages",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Over ${messageData.activeDays} days",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryMetricCard(
            'Active Days',
            messageData.activeDays.toString(),
            Icons.calendar_today_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecondaryMetricCard(
            'Media Shared',
            messageData.mediaShared.toString(),
            Icons.photo_library_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecondaryMetricCard(
            'Participants',
            messageData.participants.toString(),
            Icons.people_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtils.whatsappLightBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorUtils.whatsappLightGreen.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: ColorUtils.whatsappDarkGreen),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ColorUtils.whatsappDarkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}