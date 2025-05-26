import 'package:flutter/material.dart';
import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';

class ChatByWeekWidget extends StatefulWidget {
  final Data messageData;

  const ChatByWeekWidget({super.key, required this.messageData});

  @override
  State<ChatByWeekWidget> createState() => _ChatByWeekWidgetState();
}

class _ChatByWeekWidgetState extends State<ChatByWeekWidget> {
  late final List<MapEntry<String, int>> weekEntries;
  late final int totalWeekMessages;
  late final MapEntry<String, int> mostActiveDay;
  late final List<_DayData> dayDataList;

  static const List<String> dayOrder = [
    "Monday", "Tuesday", "Wednesday", "Thursday", 
    "Friday", "Saturday", "Sunday",
  ];

  @override
  void initState() {
    super.initState();
    _computeWeekData();
  }

  void _computeWeekData() {
    final Map<String, int> weekData = widget.messageData.weekCount;
    
    // Compute once, reuse everywhere
    weekEntries = dayOrder.map((day) => MapEntry(day, weekData[day] ?? 0)).toList();
    
    totalWeekMessages = weekData.values.fold(0, (sum, count) => sum + count);
    
    mostActiveDay = weekEntries.fold(
      weekEntries.first,
      (a, b) => a.value > b.value ? a : b,
    );

    // Pre-compute all day data with percentages
    dayDataList = weekEntries.map((entry) {
      final double percentage = totalWeekMessages > 0 
          ? (entry.value / totalWeekMessages) * 100 
          : 0;
      return _DayData(
        name: entry.key,
        messages: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const Divider(color: ColorUtils.whatsappDivider, height: 32),
        _buildChart(),
        const SizedBox(height: 16),
        ..._buildDayItems(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
      decoration: BoxDecoration(
        color: ColorUtils.whatsappLightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Activity by Day of Week",
                style: TextStyle(
                  fontSize: 14,
                  color: ColorUtils.whatsappSecondaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mostActiveDay.key,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              Text(
                mostActiveDay.value > 0 ? "Most active day" : "No activity recorded",
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorUtils.whatsappSecondaryText,
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
              Icons.view_week_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtils.whatsappLightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekEntries.map((entry) => _buildChartBar(entry)).toList(),
        ),
      ),
    );
  }

  Widget _buildChartBar(MapEntry<String, int> entry) {
    final double percentage = mostActiveDay.value > 0 ? entry.value / mostActiveDay.value : 0;
    final String shortDayName = _getShortDayName(entry.key);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 16,
              child: entry.value > 0
                  ? Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: ColorUtils.whatsappSecondaryText,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Container(
              height: (80 * percentage).clamp(entry.value == 0 ? 2 : 8, 80),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: entry.value > 0
                      ? [
                          ColorUtils.whatsappLightGreen,
                          ColorUtils.whatsappLightGreen.withAlpha(179),
                        ]
                      : [
                          Colors.grey.withAlpha(100),
                          Colors.grey.withAlpha(50),
                        ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                shortDayName,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: ColorUtils.whatsappTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDayItems() {
    return dayDataList.map((dayData) => _buildDayItem(dayData)).toList();
  }

  Widget _buildDayItem(_DayData dayData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtils.whatsappLightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorUtils.whatsappLightGreen.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getDayIcon(dayData.name),
              size: 20,
              color: ColorUtils.whatsappDarkGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayData.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorUtils.whatsappTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${dayData.messages} messages",
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorUtils.whatsappSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ColorUtils.whatsappLightGreen.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "${dayData.percentage.toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorUtils.whatsappDarkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortDayName(String dayName) {
    const Map<String, String> shortDays = {
      "Monday": "Mon", "Tuesday": "Tue", "Wednesday": "Wed", "Thursday": "Thu",
      "Friday": "Fri", "Saturday": "Sat", "Sunday": "Sun",
    };
    return shortDays[dayName] ?? "???";
  }

  IconData _getDayIcon(String dayName) {
    const Map<String, IconData> dayIcons = {
      "Monday": Icons.work_rounded, "Tuesday": Icons.work_rounded,
      "Wednesday": Icons.work_rounded, "Thursday": Icons.work_rounded,
      "Friday": Icons.work_rounded, "Saturday": Icons.weekend_rounded,
      "Sunday": Icons.weekend_rounded,
    };
    return dayIcons[dayName] ?? Icons.calendar_today_rounded;
  }
}

class _DayData {
  final String name;
  final int messages;
  final double percentage;

  _DayData({required this.name, required this.messages, required this.percentage});
}