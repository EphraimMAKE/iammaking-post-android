class Post {
  final int id;
  final String caption;
  final String status; // draft | scheduled | published | failed
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final List<Map<String, dynamic>> accounts;
  final List<Map<String, dynamic>> medias;

  const Post({
    required this.id,
    required this.caption,
    required this.status,
    this.scheduledAt,
    required this.createdAt,
    required this.accounts,
    required this.medias,
  });

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id:          j['id'] as int,
    caption:     j['caption'] as String? ?? '',
    status:      j['status'] as String? ?? 'draft',
    scheduledAt: j['scheduled_at'] != null ? DateTime.tryParse(j['scheduled_at']) : null,
    createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
    accounts:    (j['accounts'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
    medias:      (j['medias']   as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
  );
}
