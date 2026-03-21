class TokenPair {
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;

  TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiry: DateTime.now().add(Duration(seconds: json['expires_in'] ?? 3600)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiry.difference(DateTime.now()).inSeconds,
    };
  }
}
