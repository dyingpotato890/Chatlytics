import 'package:chatlytics/models/data.dart';
import 'package:chatlytics/widgets/colors.dart';
import 'package:flutter/material.dart';

class _UserStat {
  final String name;
  final int totalCount;
  final int? avgSeconds;
  const _UserStat({required this.name, required this.totalCount, this.avgSeconds});
}

class ResponseTimeWidget extends StatefulWidget {
  final Data messageData;

  const ResponseTimeWidget({super.key, required this.messageData});

  @override
  State<ResponseTimeWidget> createState() => _ResponseTimeWidgetState();
}

class _ResponseTimeWidgetState extends State<ResponseTimeWidget> {
  late final List<_UserStat> _sorted;
  late final bool _hasData;
  late final _UserStat? _fastest;

  @override
  void initState() {
    super.initState();
    final stats = widget.messageData.responseCount.entries.map((e) {
      return _UserStat(
        name: e.key,
        totalCount: e.value,
        avgSeconds: widget.messageData.avgResponseTime[e.key],
      );
    }).toList();

    stats.sort((a, b) {
      if (a.avgSeconds != null && b.avgSeconds != null) {
        return a.avgSeconds!.compareTo(b.avgSeconds!);
      }
      if (a.avgSeconds != null) return -1;
      if (b.avgSeconds != null) return 1;
      return b.totalCount.compareTo(a.totalCount);
    });

    _sorted = stats;
    _hasData = _sorted.isNotEmpty;
    _fastest = _hasData ? _sorted.firstWhere((s) => s.avgSeconds != null, orElse: () => _sorted.first) : null;
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return s == 0 ? '${m}m' : '${m}m ${s}s';
    }
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.timer_off_outlined, size: 48, color: ColorUtils.whatsappLightGreen),
              SizedBox(height: 12),
              Text(
                'No Response Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.whatsappDarkGreen,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Not enough back-and-forth messages to calculate response times',
                style: TextStyle(fontSize: 14, color: ColorUtils.whatsappSecondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Response Time',
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
                    'avg per reply',
                    style: const TextStyle(
                      fontSize: 13,
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

        if (_fastest?.avgSeconds != null) _buildFastestCard(),

        if (_fastest?.avgSeconds != null) const SizedBox(height: 16),

        _buildRankingList(),
      ],
    );
  }

  Widget _buildFastestCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF075E54), Color(0xFF128C7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF075E54).withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fastest Responder',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fastest!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(_fastest.avgSeconds!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList() {
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
          children: List.generate(_sorted.length, (index) {
            final stat = _sorted[index];
            final isFastest = stat.avgSeconds != null && stat == _fastest;
            final fastestAvg = _fastest?.avgSeconds ?? 1;
            final barFactor = stat.avgSeconds != null
                ? (fastestAvg / stat.avgSeconds!).clamp(0.1, 1.0)
                : 0.1;

            return _buildUserRow(
              stat.name,
              stat.avgSeconds,
              isFastest,
              barFactor,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildUserRow(
    String name,
    int? avgSeconds,
    bool isFastest,
    double barFactor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ColorUtils.getAvatarColor(name),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ColorUtils.whatsappTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isFastest)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFFFC107)),
                ),
              Text(
                avgSeconds != null ? _formatTime(avgSeconds) : '—',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isFastest ? ColorUtils.whatsappDarkGreen : ColorUtils.whatsappTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: ColorUtils.whatsappDivider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(height: 8, width: double.infinity),
              ),
              FractionallySizedBox(
                widthFactor: barFactor,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFastest
                          ? [const Color(0xFF25D366), const Color(0xFF128C7E)]
                          : [ColorUtils.whatsappLightGreen.withAlpha(150), ColorUtils.whatsappLightGreen.withAlpha(80)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
