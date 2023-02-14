class File {
  final String Id;
  final int FileType;
  String? OriginalName;
  final String FileName;
  File(
      {required this.Id,
      required this.FileType,
      this.OriginalName,
      required this.FileName});

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
        Id: json['Id'],
        FileType: json['FileType'],
        OriginalName: json['OrginalName'] ?? "",
        FileName: json['FileName']);
  }
}
