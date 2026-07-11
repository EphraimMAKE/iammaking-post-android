import 'package:flutter/material.dart';

class PlatformMeta {
  final Color  color;
  final String label;
  final String abbr;
  final int    charLimit;

  const PlatformMeta({
    required this.color,
    required this.label,
    required this.abbr,
    required this.charLimit,
  });
}

const _meta = <String, PlatformMeta>{
  'facebook':   PlatformMeta(color: Color(0xFF1877F2), label: 'Facebook',   abbr: 'F',  charLimit: 63206),
  'instagram':  PlatformMeta(color: Color(0xFFE1306C), label: 'Instagram',  abbr: 'IG', charLimit: 2200),
  'x':          PlatformMeta(color: Color(0xFF000000), label: 'X',          abbr: 'X',  charLimit: 280),
  'twitter':    PlatformMeta(color: Color(0xFF1DA1F2), label: 'Twitter',    abbr: 'X',  charLimit: 280),
  'tiktok':     PlatformMeta(color: Color(0xFF010101), label: 'TikTok',     abbr: 'TT', charLimit: 2200),
  'linkedin':   PlatformMeta(color: Color(0xFF0077B5), label: 'LinkedIn',   abbr: 'in', charLimit: 3000),
  'youtube':    PlatformMeta(color: Color(0xFFFF0000), label: 'YouTube',    abbr: 'YT', charLimit: 5000),
  'pinterest':  PlatformMeta(color: Color(0xFFE60023), label: 'Pinterest',  abbr: 'P',  charLimit: 500),
  'threads':    PlatformMeta(color: Color(0xFF101010), label: 'Threads',    abbr: 'Th', charLimit: 500),
  'snapchat':   PlatformMeta(color: Color(0xFFFFCC00), label: 'Snapchat',   abbr: 'Sc', charLimit: 250),
  'bluesky':    PlatformMeta(color: Color(0xFF0085FF), label: 'Bluesky',    abbr: 'Bs', charLimit: 300),
  'mastodon':   PlatformMeta(color: Color(0xFF6364FF), label: 'Mastodon',   abbr: 'M',  charLimit: 500),
  'reddit':     PlatformMeta(color: Color(0xFFFF4500), label: 'Reddit',     abbr: 'R',  charLimit: 40000),
  'telegram':   PlatformMeta(color: Color(0xFF2CA5E0), label: 'Telegram',   abbr: 'Tg', charLimit: 4096),
};

const _fallback = PlatformMeta(
  color: Color(0xFF6C63FF),
  label: 'Social',
  abbr: '?',
  charLimit: 2200,
);

PlatformMeta platformMeta(String key) => _meta[key.toLowerCase()] ?? _fallback;
