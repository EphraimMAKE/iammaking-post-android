import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  final Widget?  action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 40, color: kPrimary),
        ),
        const SizedBox(height: 20),
        Text(title,    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: kTextMuted), textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ]),
    ),
  );
}
