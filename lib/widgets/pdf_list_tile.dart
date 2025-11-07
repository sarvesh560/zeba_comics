import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';

class PdfListTile extends StatelessWidget {
  final drive.File file;
  final VoidCallback onView;

  const PdfListTile({super.key, required this.file, required this.onView});

  String _formatBytes(int? bytes) {
    if (bytes == null) return "Unknown size";
    const suffixes = ["B", "KB", "MB", "GB"];
    double size = bytes.toDouble();
    int i = 0;
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Responsive sizes
    final cardMarginH = width * 0.03;
    final cardMarginV = height * 0.008;
    final contentPaddingH = width * 0.04;
    final contentPaddingV = height * 0.015;
    final iconSize = width * 0.07;
    final leadingBoxSize = width * 0.12;
    final textSize = width * 0.04;
    final spacing = height * 0.005;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: cardMarginH, vertical: cardMarginV),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: contentPaddingH, vertical: contentPaddingV),
        leading: Container(
          width: leadingBoxSize,
          height: leadingBoxSize,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.picture_as_pdf, color: Colors.red, size: iconSize),
        ),
        title: Text(
          file.name ?? "Untitled",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: textSize),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing),
            if (file.size != null)
              Text(
                _formatBytes(int.tryParse(file.size ?? '0')),
                style: TextStyle(fontSize: textSize * 0.85, color: Colors.grey[700]),
              ),
            if (file.modifiedTime != null)
              Text(
                _formatDate(file.modifiedTime.toString()),
                style: TextStyle(fontSize: textSize * 0.85, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.remove_red_eye, color: Colors.blue, size: iconSize),
          onPressed: onView,
        ),
      ),
    );
  }
}
