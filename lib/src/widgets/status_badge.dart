import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'published' => ('Publié',   kSuccess,   Icons.check_circle_outline_rounded),
      'scheduled' => ('Planifié', kWarning,   Icons.schedule_rounded),
      'failed'    => ('Échoué',   kDanger,    Icons.error_outline_rounded),
      'pending'   => ('En cours', kPrimary,   Icons.hourglass_top_rounded),
      _           => ('Brouillon',kTextMuted, Icons.edit_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ),
      ]),
    );
  }
}
