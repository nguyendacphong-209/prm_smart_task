import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final String type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color background;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'high':
        background = colorScheme.error.withValues(alpha: 0.18);
        icon = Icons.priority_high_rounded;
        break;
      case 'medium':
        background = colorScheme.primary.withValues(alpha: 0.18);
        icon = Icons.drag_handle_rounded;
        break;
      case 'low':
        background = colorScheme.tertiary.withValues(alpha: 0.18);
        icon = Icons.south_rounded;
        break;
      default:
        background = colorScheme.surface.withValues(alpha: 0.30);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
