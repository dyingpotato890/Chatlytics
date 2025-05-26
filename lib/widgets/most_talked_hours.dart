import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class _HourData {
  final String key;
  final String displayName;
  final int messages;
  final int hour24;
  final IconData icon;
  final String timePeriod;

  const _HourData({
    required this.key,
    required this.displayName,
    required this.messages,
    required this.hour24,
    required this.icon,
    required this.timePeriod,
  });
}

class MostTalkedHoursWidget extends StatefulWidget {
  final Data messageData;

  const MostTalkedHoursWidget({super.key, required this.messageData});

  @override
  State<MostTalkedHoursWidget> createState() => _MostTalkedHoursWidgetState();
}

class _MostTalkedHoursWidgetState extends State<MostTalkedHoursWidget> {
  late List<_HourData> _sortedHours;
  late Map<int, int> _normalizedHourData;
  late String _mostActiveTimePeriod;
  late int _maxMessages;

  @override
  void initState() {
    super.initState();
    _precomputeData();
  }

  void _precomputeData() {
    final Map<String, int> hoursData = Map.from(widget.messageData.mostTalkedHours);
    
    // Pre-compute normalized hour data
    _normalizedHourData = {};
    for (var entry in hoursData.entries) {
      int hour24 = _parseHour(entry.key);
      _normalizedHourData[hour24] = (_normalizedHourData[hour24] ?? 0) + entry.value;
    }

    // Pre-compute max messages for intensity calculations
    _maxMessages = _normalizedHourData.values.isEmpty 
        ? 1 
        : _normalizedHourData.values.reduce((a, b) => a > b ? a : b);

    // Pre-compute sorted hours with all data
    _sortedHours = hoursData.entries
        .map((entry) {
          final hour24 = _parseHour(entry.key);
          return _HourData(
            key: entry.key,
            displayName: _formatHourDisplay(entry.key),
            messages: entry.value,
            hour24: hour24,
            icon: _getTimeIcon(hour24),
            timePeriod: _getTimePeriod(hour24),
          );
        })
        .toList()
      ..sort((a, b) => b.messages.compareTo(a.messages));

    // Pre-compute most active time period
    _mostActiveTimePeriod = _sortedHours.isNotEmpty 
        ? _sortedHours.first.timePeriod
        : "Unknown";
  }

  int _parseHour(String hourKey) {
    try {
      if (hourKey.contains(' ')) {
        List<String> parts = hourKey.split(' ');
        int hour = int.parse(parts[0]);
        String period = parts[1].toUpperCase();
        
        if (period == 'AM') {
          return hour == 12 ? 0 : hour;
        } else {
          return hour == 12 ? 12 : hour + 12;
        }
      }
      return int.parse(hourKey);
    } catch (e) {
      return 0;
    }
  }

  String _formatHourDisplay(String hourKey) {
    try {
      if (hourKey.contains(' ')) {
        return hourKey;
      }
      
      int hour = int.parse(hourKey);
      if (hour == 0) return "12 AM";
      if (hour == 12) return "12 PM";
      return hour > 12 ? "${hour - 12} PM" : "$hour AM";
    } catch (e) {
      return hourKey;
    }
  }

  String _getTimePeriod(int hour) {
    if (hour >= 0 && hour < 4) return "Midnight";
    if (hour >= 4 && hour < 7) return "Early Morning";
    if (hour >= 7 && hour < 12) return "Morning";
    if (hour >= 12 && hour < 17) return "Afternoon";
    if (hour >= 17 && hour < 20) return "Evening";
    if (hour >= 20 && hour < 24) return "Night";
    return "Unknown";
  }

  IconData _getTimeIcon(int hour) {
    if (hour >= 0 && hour < 4) return Icons.nightlight_round;
    if (hour >= 4 && hour < 7) return Icons.bedtime_rounded;
    if (hour >= 7 && hour < 12) return Icons.wb_sunny_rounded;
    if (hour >= 12 && hour < 17) return Icons.wb_cloudy_rounded;
    if (hour >= 17 && hour < 20) return Icons.wb_twilight_rounded;
    if (hour >= 20 && hour < 24) return Icons.nights_stay_rounded;
    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hours summary header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Most Active Hours",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.whatsappSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mostActiveTimePeriod,
                    style: const TextStyle(
                      fontSize: 24,
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
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 32),

        // Hourly Activity Grid
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hourly Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final int hourMessages = _normalizedHourData[index] ?? 0;
                  final double intensity = hourMessages > 0 ? hourMessages / _maxMessages : 0;

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: ColorUtils.whatsappLightGreen.withAlpha(
                        (25 + (intensity * 200)).round(),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ColorUtils.whatsappDivider,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatHourDisplay(index.toString()),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: intensity > 0.5
                                  ? Colors.white
                                  : ColorUtils.whatsappTextColor,
                            ),
                          ),
                          if (hourMessages > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              hourMessages.toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: intensity > 0.5
                                    ? Colors.white
                                    : ColorUtils.whatsappSecondaryText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Top Active Hours
        const Text(
          "Top Active Hours",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorUtils.whatsappDarkGreen,
          ),
        ),
        const SizedBox(height: 12),

        // Pre-built list of top 5 hours
        ..._sortedHours.take(5).map((hourData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 5, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColorUtils.whatsappLightGreen.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          hourData.icon,
                          size: 18,
                          color: ColorUtils.whatsappSecondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      hourData.displayName,
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
                      "${hourData.messages}",
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
          );
        }),
      ],
    );
  }
}