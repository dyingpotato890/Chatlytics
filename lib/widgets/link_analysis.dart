import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class _PlatformData {
  final String platform;
  final int count;
  final double normalizedCount;

  const _PlatformData({
    required this.platform,
    required this.count,
    required this.normalizedCount,
  });
}

class _TopPlatformData {
  final String platform;
  final int count;
  final int rank;
  final Color color;
  final Color backgroundColor;

  const _TopPlatformData({
    required this.platform,
    required this.count,
    required this.rank,
    required this.color,
    required this.backgroundColor,
  });
}

class LinkAnalysisWidget extends StatefulWidget {
  final Data messageData;

  const LinkAnalysisWidget({
    super.key,
    required this.messageData,
  });

  @override
  State<LinkAnalysisWidget> createState() => _LinkAnalysisWidgetState();
}

class _LinkAnalysisWidgetState extends State<LinkAnalysisWidget> {
  late final List<_TopPlatformData> _topThreePlatforms;
  late final List<_PlatformData> _remainingPlatforms;
  late final int _totalLinks;
  late final bool _hasLinks;
  late final double _maxCount;

  // Pre-computed color constants
  static const List<Color> _platformColors = [
    Color(0xFF1877F2), // Blue (Facebook/LinkedIn)
    Color(0xFFE4405F), // Pink (Instagram)
    Color(0xFF1DA1F2), // Light Blue (Twitter)
  ];

  static const List<Color> _bgColors = [
    Color(0xFFE3F2FD), // Light blue
    Color(0xFFFCE4EC), // Light pink
    Color(0xFFE1F5FE), // Very light blue
  ];

  @override
  void initState() {
    super.initState();
    _precomputeLinkData();
  }

  void _precomputeLinkData() {
    final Map<String, int> linksByPlatform = widget.messageData.linksByPlatform;
    
    // Calculate total links from the map
    _totalLinks = linksByPlatform.values.fold(0, (sum, count) => sum + count);
    
    // Convert to sorted list
    final List<MapEntry<String, int>> sortedPlatforms = linksByPlatform.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _hasLinks = sortedPlatforms.isNotEmpty;
    
    if (!_hasLinks) {
      _topThreePlatforms = [];
      _remainingPlatforms = [];
      _maxCount = 0;
      return;
    }

    // Pre-compute top 3 platforms with colors
    final int topCount = min(3, sortedPlatforms.length);
    _topThreePlatforms = List.generate(topCount, (index) {
      final entry = sortedPlatforms[index];
      return _TopPlatformData(
        platform: entry.key,
        count: entry.value,
        rank: index,
        color: _platformColors[index],
        backgroundColor: _bgColors[index],
      );
    });

    // Pre-compute remaining platforms with normalized counts
    if (sortedPlatforms.length > 3) {
      _maxCount = sortedPlatforms[0].value.toDouble();
      
      _remainingPlatforms = sortedPlatforms
          .skip(3)
          .map((entry) => _PlatformData(
                platform: entry.key,
                count: entry.value,
                normalizedCount: entry.value / _maxCount,
              ))
          .toList();
    } else {
      _remainingPlatforms = [];
      _maxCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLinks) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Introduction section
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Link Analysis",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappLightGreen.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    "$_totalLinks Total",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ColorUtils.whatsappDarkGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 24),

        // Top 3 Platforms with special highlight
        if (_topThreePlatforms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: _topThreePlatforms
                  .map((platformData) => Expanded(child: _buildTopPlatformCard(platformData)))
                  .toList(),
            ),
          ),

        // Remaining platforms
        if (_remainingPlatforms.isNotEmpty) 
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRemainingPlatformsSection(),
          ),

        // User-wise link sharing
        _buildUserLinksSection(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            Icon(
              Icons.link_off_rounded,
              size: 48,
              color: ColorUtils.whatsappLightGreen,
            ),
            SizedBox(height: 12),
            Text(
              "No Links Shared",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "No external links detected in this chat",
              style: TextStyle(
                fontSize: 14,
                color: ColorUtils.whatsappSecondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingPlatformsSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Other Platforms",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: _remainingPlatforms
                  .map((platformData) => _buildPlatformProgressBar(platformData))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLinksSection() {
    final Map<String, int> userLinks = widget.messageData.linksSharedByUser;
    
    if (userLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort users by link count
    final sortedUsers = userLinks.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Find max for normalization
    final maxUserCount = sortedUsers.first.value.toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: ColorUtils.whatsappDarkGreen,
                ),
                SizedBox(width: 8),
                Text(
                  "Top Link Sharers",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.whatsappDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sortedUsers.take(5).map((entry) => _buildUserBar(
              entry.key,
              entry.value,
              entry.value / maxUserCount,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBar(String username, int count, double normalized) {
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
                    backgroundColor: ColorUtils.getAvatarColor(username),
                    child: Text(
                      username.isNotEmpty ? username[0] : "?",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    username,
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
                    count.toString(),
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
          Stack(
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
              FractionallySizedBox(
                widthFactor: normalized,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorUtils.whatsappLightGreen,
                        ColorUtils.whatsappLightGreen.withAlpha(179),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "$count links shared",
            style: const TextStyle(
              fontSize: 13,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformProgressBar(_PlatformData platformData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Row(
              children: [
                Icon(
                  _getPlatformIcon(platformData.platform),
                  size: 14,
                  color: ColorUtils.whatsappDarkGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    platformData.platform,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorUtils.whatsappDarkGreen,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: ColorUtils.whatsappDivider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(height: 14, width: double.infinity),
                ),
                FractionallySizedBox(
                  widthFactor: platformData.normalizedCount,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ColorUtils.whatsappLightGreen.withAlpha(179),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(height: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            platformData.count.toString(),
            style: const TextStyle(
              fontSize: 12,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlatformCard(_TopPlatformData platformData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: platformData.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: platformData.color.withAlpha(51),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: platformData.color.withAlpha(77)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Platform icon
              DecoratedBox(
                decoration: BoxDecoration(
                  color: platformData.color.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _getPlatformIcon(platformData.platform),
                    color: platformData.color,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Platform name
              Text(
                platformData.platform,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: platformData.color.withAlpha(204),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Count
              Text(
                platformData.count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen.withAlpha(230),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_outline;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'twitter/x':
      case 'twitter':
      case 'x':
        return Icons.alternate_email;
      case 'facebook':
        return Icons.facebook;
      case 'linkedin':
        return Icons.work_outline;
      case 'tiktok':
        return Icons.music_note_outlined;
      case 'reddit':
        return Icons.reddit;
      case 'whatsapp':
        return Icons.chat_bubble_outline;
      case 'telegram':
        return Icons.send_outlined;
      case 'spotify':
        return Icons.audiotrack_outlined;
      case 'github':
        return Icons.code;
      case 'medium':
        return Icons.article_outlined;
      case 'pinterest':
        return Icons.push_pin_outlined;
      case 'amazon':
      case 'flipkart':
        return Icons.shopping_cart_outlined;
      case 'google':
        return Icons.search;
      case 'netflix':
        return Icons.movie_outlined;
      case 'zoom':
      case 'meet':
        return Icons.videocam_outlined;
      default:
        return Icons.link;
    }
  }
}