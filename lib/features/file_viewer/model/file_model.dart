import 'dart:typed_data';

class FileModel {
  final Uint8List? fileData;
  final String fileName;
  final String fileId;
  final String mimeType;
  final String? fileUrl;

  FileModel({
    this.fileData,
    required this.fileName,
    required this.fileId,
    required this.mimeType,
    this.fileUrl,
  });

  bool get isPDF => mimeType == 'application/pdf';
  bool get isImage => mimeType.startsWith('image/');
  bool get isDoc => !isPDF && !isImage;
}
