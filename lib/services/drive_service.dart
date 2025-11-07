import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/home/model/drive_file_model.dart';

class DriveService {
  final String apiKey = "AIzaSyCRwbXY06PD_hvLyWCLJp8D2DNdAkYV--w";

  Future<List<DriveFileModel>> fetchFilesFromFolder(String folderId) async {
    try {
      final query = "'$folderId' in parents";
      final url =
          "https://www.googleapis.com/drive/v3/files?q=${Uri.encodeComponent(query)}"
          "&key=$apiKey"
          "&fields=files(id,name,mimeType,thumbnailLink,webViewLink)"
          "&supportsAllDrives=true&includeItemsFromAllDrives=true";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('Failed to fetch files: ${response.statusCode}');
        print('Body: ${response.body}');
        return [];
      }

      final files = (json.decode(response.body)['files'] as List)
          .cast<Map<String, dynamic>>();

      return files
          .map((file) => DriveFileModel.fromMap({
        'id': file['id'] ?? '',
        'name': file['name'] ?? 'Unknown',
        'mimeType': file['mimeType'] ?? '',
        'thumbnail': file['thumbnailLink'] ?? '',
        'webViewLink': file['webViewLink'] ?? '',
      }))
          .toList();
    } catch (e) {
      print('Exception fetching files: $e');
      return [];
    }
  }

  Future<List<DriveFileModel>> fetchDocsWithThumbnails(
      String docsFolderId, String imagesFolderId) async {
    final docs = await fetchFilesFromFolder(docsFolderId);
    final images = await fetchFilesFromFolder(imagesFolderId);

    return docs.map((doc) {
      final baseName = doc.name.split('.').first.toLowerCase();
      final match = images.firstWhere(
            (img) => img.name.split('.').first.toLowerCase() == baseName,
        orElse: () => DriveFileModel(
          id: '',
          name: '',
          mimeType: '',
          webViewLink: '',
          thumbnail: '',
        ),
      );

      return DriveFileModel(
        id: doc.id,
        name: doc.name,
        mimeType: doc.mimeType,
        webViewLink: doc.webViewLink,
        thumbnail: match.id.isNotEmpty
            ? "https://drive.google.com/uc?export=view&id=${match.id}"
            : (doc.thumbnail.isNotEmpty ? doc.thumbnail : ''),
        hasCustomThumbnail: match.id.isNotEmpty,
      );
    }).toList();
  }
}
