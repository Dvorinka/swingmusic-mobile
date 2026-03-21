class SearchSuggestion {
  final String id;
  final String title;
  final String? imageUrl;
  final String type; // 'track', 'album', 'artist', 'playlist'
  final dynamic data;

  SearchSuggestion({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.type,
    this.data,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['text'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      type: json['type'] ?? 'track',
      data: json['data'] ?? json,
    );
  }

  // Getter for backward compatibility
  String get text => title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchSuggestion &&
          other.runtimeType == SearchSuggestion &&
          other.id == id &&
          other.title == title &&
          other.type == type;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'type': type,
      'data': data,
    };
  }
}
