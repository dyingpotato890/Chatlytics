import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/pages/home_page.dart';
import 'package:chatlytics/widgets/ai_summary.dart';
import 'package:chatlytics/widgets/chats_per_week.dart';
import 'package:chatlytics/widgets/chats_per_year.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:chatlytics/widgets/emoji_analysis.dart';
import 'package:chatlytics/widgets/first_last_message.dart';
import 'package:chatlytics/widgets/link_analysis.dart';
import 'package:chatlytics/widgets/conversation_starter.dart';
import 'package:chatlytics/widgets/message_breakdown.dart';
import 'package:chatlytics/widgets/response_time.dart';
import 'package:chatlytics/widgets/messages_per_user.dart';
import 'package:chatlytics/widgets/most_talked_days.dart';
import 'package:chatlytics/widgets/most_talked_hours.dart';
import 'package:chatlytics/widgets/chats_per_months.dart';
import 'package:chatlytics/widgets/overview.dart';
import 'package:chatlytics/widgets/panel.dart';
import 'package:chatlytics/widgets/streak.dart';
import 'package:chatlytics/widgets/top_cuss_words.dart';
import 'package:chatlytics/widgets/top_words.dart';
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  final Data messageData;

  const AnalysisPage({super.key, required this.messageData});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late final List<_Section> _sections;
  final Set<String> _collapsed = {};

  @override
  void initState() {
    super.initState();

    _sections = [
      _Section(
        title: 'PEOPLE & BEHAVIOUR',
        panels: [
          _PanelItem(
            title: 'Messages per User',
            icon: Icons.people_alt_rounded,
            builder: () => MessagesPerUserWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Response Time',
            icon: Icons.timer_outlined,
            builder: () => ResponseTimeWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Conversation Starters',
            icon: Icons.wb_sunny_rounded,
            builder: () => ConversationStarterWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Deleted Messages',
            icon: Icons.delete_outline_rounded,
            builder: () => MessageBreakdownWidget(messageData: widget.messageData),
          ),
        ],
      ),

      _Section(
        title: 'CONTENT',
        panels: [
          _PanelItem(
            title: 'Top 100 Words',
            icon: Icons.text_fields_rounded,
            builder: () => TopWordsWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Top Cuss Words',
            icon: Icons.warning_rounded,
            builder: () => TopCussWordsWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Emoji Analysis',
            icon: Icons.emoji_emotions_rounded,
            builder: () => EmojiAnalysisWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Link Analysis',
            icon: Icons.link_rounded,
            builder: () => LinkAnalysisWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'AI Daily Analysis',
            icon: Icons.psychology_rounded,
            builder: () => AIDailyAnalysisWidget(messageData: widget.messageData),
          ),
        ],
      ),

      _Section(
        title: 'ACTIVITY',
        panels: [
          _PanelItem(
            title: 'First & Last Messages',
            icon: Icons.chat_bubble_outline_rounded,
            builder: () => FirstLastMessageWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Hourly Activity',
            icon: Icons.schedule_rounded,
            builder: () => MostTalkedHoursWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Most Active Days',
            icon: Icons.calendar_today_rounded,
            builder: () => MostTalkedDaysWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Weekly Analysis',
            icon: Icons.date_range_rounded,
            builder: () => ChatByWeekWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Monthly Activity',
            icon: Icons.date_range_rounded,
            builder: () => ChatByMonthWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Yearly Activity',
            icon: Icons.date_range_rounded,
            builder: () => ChatByYearWidget(messageData: widget.messageData),
          ),
          _PanelItem(
            title: 'Chat Streaks',
            icon: Icons.star_rounded,
            builder: () => DayStreakWidget(messageData: widget.messageData),
          ),
        ],
      ),
    ];
  }

  List<dynamic> _flatItems() {
    final result = <dynamic>[];
    for (final section in _sections) {
      result.add(section);
      if (!_collapsed.contains(section.title)) {
        result.addAll(section.panels);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final items = _flatItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Analysis',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      backgroundColor: ColorUtils.whatsappDivider,

      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: items.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "${widget.messageData.firstMessage.date} - ${widget.messageData.lastMessage.date}",
                  style: const TextStyle(
                    color: Color(0xFF667781),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            if (index == 1) {
              return OverviewWidget(messageData: widget.messageData);
            }

            final item = items[index - 2];

            if (item is _Section) {
              return _buildSectionHeader(item);
            }

            final panel = item as _PanelItem;
            return PanelWidget(
              title: panel.title,
              color: ColorUtils.whatsappLightBackground,
              icon: panel.icon,
              content: panel.builder(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(_Section section) {
    final isCollapsed = _collapsed.contains(section.title);

    return GestureDetector(
      onTap: () => setState(() {
        if (isCollapsed) {
          _collapsed.remove(section.title);
        } else {
          _collapsed.add(section.title);
        }
      }),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
        child: Row(
          children: [
            Text(
              section.title,
              style: const TextStyle(
                color: Color(0xFF075E54),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Icon(
              isCollapsed ? Icons.expand_more_rounded : Icons.expand_less_rounded,
              color: const Color(0xFF075E54),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section {
  final String title;
  final List<_PanelItem> panels;

  const _Section({required this.title, required this.panels});
}

class _PanelItem {
  final String title;
  final IconData icon;
  final Widget Function() builder;

  const _PanelItem({required this.title, required this.icon, required this.builder});
}
