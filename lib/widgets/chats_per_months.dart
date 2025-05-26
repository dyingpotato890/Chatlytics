import 'package:flutter/material.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/models/data.dart';

class ChatByMonthWidget extends StatefulWidget {
  final Data messageData;

  const ChatByMonthWidget({super.key, required this.messageData});

  @override
  State<ChatByMonthWidget> createState() => _ChatByMonthWidgetState();
}

class _ChatByMonthWidgetState extends State<ChatByMonthWidget> {
  late final List<MapEntry<String, int>> monthEntries;
  late final int totalMonthMessages;
  late final MapEntry<String, int> mostActiveMonth;
  late final List<_MonthData> activeMonthDataList;

  // Constants
  static const Map<String, String> _monthNames = {
    "01": "January", "02": "February", "03": "March", "04": "April",
    "05": "May", "06": "June", "07": "July", "08": "August",
    "09": "September", "10": "October", "11": "November", "12": "December",
  };

  static const Map<String, String> _shortMonthNames = {
    "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr",
    "05": "May", "06": "Jun", "07": "Jul", "08": "Aug",
    "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dec",
  };

  @override
  void initState() {
    super.initState();
    _computeMonthData();
  }

  void _computeMonthData() {
    // Get all 12 months data
    final Map<String, int> allMonthsData = _getAllMonthsData();
    monthEntries = allMonthsData.entries.toList();
    monthEntries.sort((a, b) => a.key.compareTo(b.key)); // Chronological order

    // Calculate totals
    totalMonthMessages = allMonthsData.values.fold(0, (sum, count) => sum + count);

    // Find most active month
    mostActiveMonth = monthEntries
        .where((entry) => entry.value > 0)
        .fold(const MapEntry("01", 0), (a, b) => a.value > b.value ? a : b);

    // Pre-compute active month data with percentages
    activeMonthDataList = monthEntries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final double percentage = totalMonthMessages > 0 
              ? (entry.value / totalMonthMessages) * 100 
              : 0;
          return _MonthData(
            key: entry.key,
            name: _monthNames[entry.key] ?? "Unknown",
            messages: entry.value,
            percentage: percentage,
          );
        }).toList();
  }

  Map<String, int> _getAllMonthsData() {
    final Map<String, int> allMonths = {
      "01": 0, "02": 0, "03": 0, "04": 0, "05": 0, "06": 0,
      "07": 0, "08": 0, "09": 0, "10": 0, "11": 0, "12": 0,
    };

    // Merge with actual data
    final originalData = widget.messageData.monthCount;
    for (String month in originalData.keys) {
      String monthKey = month.trim();
      if (monthKey.length == 1) {
        monthKey = "0$monthKey";
      }
      if (allMonths.containsKey(monthKey)) {
        allMonths[monthKey] = originalData[month]!;
      }
    }

    return allMonths;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const Divider(color: ColorUtils.whatsappDivider, height: 32),
        _buildChart(),
        const SizedBox(height: 20),
        ..._buildMonthItems(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Activity by Month",
                style: TextStyle(
                  fontSize: 14,
                  color: ColorUtils.whatsappSecondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _monthNames[mostActiveMonth.key] ?? "Unknown",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              Text(
                mostActiveMonth.value > 0 ? "Most active month" : "No activity recorded",
                style: TextStyle(
                  fontSize: 12,
                  color: ColorUtils.whatsappSecondaryText.withAlpha(204),
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
              Icons.date_range_rounded,
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
      height: 180,
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: monthEntries.map((entry) => _buildChartBar(entry)).toList(),
        ),
      ),
    );
  }

  Widget _buildChartBar(MapEntry<String, int> entry) {
    final double percentage = mostActiveMonth.value > 0 ? entry.value / mostActiveMonth.value : 0;
    final String shortMonthName = _shortMonthNames[entry.key] ?? "???";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 28,
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
            height: (120 * percentage).clamp(entry.value == 0 ? 2 : 8, 120),
            width: 28,
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
              shortMonthName,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: ColorUtils.whatsappTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMonthItems() {
    return activeMonthDataList.map((monthData) => _buildMonthItem(monthData)).toList();
  }

  Widget _buildMonthItem(_MonthData monthData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorUtils.whatsappLightGreen.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: ColorUtils.whatsappSecondaryText,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthData.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorUtils.whatsappTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${monthData.messages} messages",
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
              "${monthData.percentage.toStringAsFixed(1)}%",
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
}

class _MonthData {
  final String key;
  final String name;
  final int messages;
  final double percentage;

  _MonthData({
    required this.key,
    required this.name,
    required this.messages,
    required this.percentage,
  });
}