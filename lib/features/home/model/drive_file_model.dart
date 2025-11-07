class DriveFileModel {
  final String id;
  final String name;
  final String thumbnail;
  final String mimeType;
  final String webViewLink;
  final bool hasCustomThumbnail;

  DriveFileModel({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.mimeType,
    required this.webViewLink,
    this.hasCustomThumbnail = false,
  });

  factory DriveFileModel.fromMap(Map<String, dynamic> map) {
    return DriveFileModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      thumbnail: map['thumbnail'] ?? '',
      mimeType: map['mimeType'] ?? '',
      webViewLink: map['webViewLink'] ?? '',
      hasCustomThumbnail: map['hasCustomThumbnail'] ?? false,
    );
  }

  /// ✅ Needed for SharedPreferences persistence
  factory DriveFileModel.fromJson(Map<String, dynamic> json) {
    return DriveFileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      mimeType: json['mimeType'] ?? '',
      webViewLink: json['webViewLink'] ?? '',
      hasCustomThumbnail: json['hasCustomThumbnail'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'mimeType': mimeType,
      'webViewLink': webViewLink,
      'hasCustomThumbnail': hasCustomThumbnail,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DriveFileModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
