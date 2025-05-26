import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:chatlytics/models/data.dart';

class _MetricData {
  final String title;
  final String value;
  final IconData icon;

  const _MetricData({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _FeaturedMetricData {
  final String messageCountText;
  final String activeDaysText;

  const _FeaturedMetricData({
    required this.messageCountText,
    required this.activeDaysText,
  });
}

class OverviewWidget extends StatefulWidget {
  final Data messageData;

  const OverviewWidget({super.key, required this.messageData});

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  late final _FeaturedMetricData _featuredData;
  late final List<_MetricData> _secondaryMetrics;

  // Pre-computed decoration constants
  static final BoxDecoration _featuredCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorUtils.whatsappLightGreen, ColorUtils.whatsappDarkGreen],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF128C7E).withAlpha(50),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final BoxDecoration _iconContainerDecoration = BoxDecoration(
    color: Colors.white.withAlpha(51),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(20),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final BoxDecoration _activeDaysDecoration = BoxDecoration(
    color: Colors.white.withAlpha(38),
    borderRadius: BorderRadius.circular(12),
  );

  static final BoxDecoration _secondaryCardDecoration = BoxDecoration(
    color: ColorUtils.whatsappLightBackground,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(50),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration _secondaryIconDecoration = BoxDecoration(
    color: ColorUtils.whatsappLightGreen.withAlpha(50),
    borderRadius: BorderRadius.circular(12),
  );

  @override
  void initState() {
    super.initState();
    _precomputeData();
  }

  void _precomputeData() {
    // Pre-compute featured metric data
    _featuredData = _FeaturedMetricData(
      messageCountText: widget.messageData.messageCount.toString(),
      activeDaysText: "Over ${widget.messageData.activeDays} days",
    );

    // Pre-compute secondary metrics data
    _secondaryMetrics = [
      _MetricData(
        title: 'Active Days',
        value: widget.messageData.activeDays.toString(),
        icon: Icons.calendar_today_rounded,
      ),
      _MetricData(
        title: 'Media Shared',
        value: widget.messageData.mediaShared.toString(),
        icon: Icons.photo_library_rounded,
      ),
      _MetricData(
        title: 'Participants',
        value: widget.messageData.participants.toString(),
        icon: Icons.people_alt_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: _featuredCardDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {},
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
                      DecoratedBox(
                        decoration: _iconContainerDecoration,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _featuredData.messageCountText,
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

                  DecoratedBox(
                    decoration: _activeDaysDecoration,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                            _featuredData.activeDaysText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryMetricsRow() {
    return Row(
      children: [
        Expanded(child: _buildSecondaryMetricCard(_secondaryMetrics[0])),
        const SizedBox(width: 12),
        Expanded(child: _buildSecondaryMetricCard(_secondaryMetrics[1])),
        const SizedBox(width: 12),
        Expanded(child: _buildSecondaryMetricCard(_secondaryMetrics[2])),
      ],
    );
  }

  Widget _buildSecondaryMetricCard(_MetricData metricData) {
    return DecoratedBox(
      decoration: _secondaryCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: _secondaryIconDecoration,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  metricData.icon,
                  size: 18,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              metricData.value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metricData.title,
              style: const TextStyle(
                fontSize: 13,
                color: ColorUtils.whatsappSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}