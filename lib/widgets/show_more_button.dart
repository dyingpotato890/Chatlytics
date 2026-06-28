import 'package:flutter/material.dart';

class ShowMoreButton extends StatelessWidget {
  final bool showAll;
  final int total;
  final int initialCount;
  final VoidCallback onTap;

  const ShowMoreButton({
    super.key,
    required this.showAll,
    required this.total,
    required this.initialCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              showAll ? 'Show less' : 'Show ${total - initialCount} more',
              style: const TextStyle(
                color: Color(0xFF075E54),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              showAll ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: const Color(0xFF075E54),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
