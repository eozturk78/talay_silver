import 'dart:ffi';

import 'package:talay_mobile/model/tags.dart';

class TagGroup {
  final String TagGroupId;
  final String TagGroupCode;
  final String TagGroupName;
  final List<Tag>? Tags;

  const TagGroup(
      {required this.TagGroupId,
      required this.TagGroupCode,
      required this.TagGroupName,
      this.Tags});

  factory TagGroup.fromJson(Map<String, dynamic> json) {
    return TagGroup(
        TagGroupId: json['TagGroupId'],
        TagGroupCode: json['TagGroupCode'],
        TagGroupName: json['TagGroupName'],
        Tags: json['Tags'] != null
            ? (json['Tags'] as List).map((e) => Tag.fromJson(e)).toList()
            : null);
  }
}
