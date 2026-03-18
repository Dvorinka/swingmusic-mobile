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
}
