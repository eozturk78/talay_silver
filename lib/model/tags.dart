class Tag {
  final String TagId;
  final String TagCode;
  final String TagName;

  Tag({
    required this.TagId,
    required this.TagCode,
    required this.TagName,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      TagId: json['TagId'],
      TagCode: json['TagCode'],
      TagName: json['TagName'],
    );
  }

  late bool _selectedTag = false;
  set selectedTag(bool value) {
    _selectedTag = value;
  }

  bool get selectedTag => _selectedTag;
}
