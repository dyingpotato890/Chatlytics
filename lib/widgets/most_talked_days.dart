import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class _DayData {
  final String key;
  final String displayName;
  final int messages;

  const _DayData({
    required this.key,
    required this.displayName,
    required this.messages,
  });
}

class MostTalkedDaysWidget extends StatefulWidget {
  final Data messageData;

  const MostTalkedDaysWidget({super.key, required this.messageData});

  @override
  State<MostTalkedDaysWidget> createState() => _MostTalkedDaysWidgetState();
}

class _MostTalkedDaysWidgetState extends State<MostTalkedDaysWidget> {
  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 
    'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  late List<_DayData> _sortedDays;
  late String _mostActiveDay;

  @override
  void initState() {
    super.initState();
    _precomputeData();
  }

  void _precomputeData() {
    final Map<String, int> daysData = Map.from(widget.messageData.mostTalkedDays);
    
    // Pre-compute all day data with display names
    _sortedDays = daysData.entries
        .map((entry) => _DayData(
              key: entry.key,
              displayName: _getDayName(entry.key),
              messages: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.messages.compareTo(a.messages));

    // Pre-compute most active day
    _mostActiveDay = _sortedDays.isNotEmpty 
        ? _sortedDays.first.displayName 
        : "";
  }

  String _getDayName(String dayNumber) {
    try {
      int index = int.parse(dayNumber) - 1;
      if (index >= 0 && index < _dayNames.length) {
        return _dayNames[index];
      }
    } catch (e) {
      // In case the day number is not in expected format
    }
    return dayNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Days summary header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Most Active Days",
                    style: TextStyle(
                      fontSize: 14, 
                      color: ColorUtils.whatsappSecondaryText
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mostActiveDay,
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
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: ColorUtils.whatsappDivider, height: 20),
        const SizedBox(height: 10),

        // Pre-built days breakdown
        ..._sortedDays.take(7).map((dayData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 10, right: 10),
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
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: ColorUtils.whatsappSecondaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dayData.displayName,
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
                      "${dayData.messages}",
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