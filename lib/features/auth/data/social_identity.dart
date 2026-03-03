class SocialIdentity {
  const SocialIdentity({
    required this.provider,
    required this.idToken,
    this.email,
    this.fullName,
  });

  final String provider;
  final String idToken;
  final String? email;
  final String? fullName;
}
