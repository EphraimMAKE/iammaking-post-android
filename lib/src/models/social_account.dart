class SocialAccount {
  final int    id;
  final String displayName;
  final String username;
  final String providerKey;
  final String? avatarUrl;
  final bool   isActive;

  const SocialAccount({
    required this.id,
    required this.displayName,
    required this.username,
    required this.providerKey,
    this.avatarUrl,
    required this.isActive,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> j) => SocialAccount(
    id:          j['id'] as int,
    displayName: j['display_name'] as String? ?? '',
    username:    j['username']     as String? ?? '',
    providerKey: j['provider_key'] as String? ?? '',
    avatarUrl:   j['avatar_url']   as String?,
    isActive:    j['is_active']    as bool? ?? true,
  );
}
