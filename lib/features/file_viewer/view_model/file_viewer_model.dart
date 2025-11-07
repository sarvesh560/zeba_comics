import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../model/file_model.dart';

class FileViewerViewModel extends ChangeNotifier {
  final FileModel fileModel;

  FileViewerViewModel(this.fileModel);

  PdfControllerPinch? pdfController;
  WebViewController? webController;

  int currentPage = 1;
  int totalPages = 0;
  bool isBookmarked = false;
  int bookmarkedPage = 1;
  double zoomScale = 1.0;

  Future<void> init({bool initialBookmarked = false}) async {
    isBookmarked = initialBookmarked;

    if (fileModel.isPDF && fileModel.fileData != null) {
      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(fileModel.fileData!),
      );
      await _loadPDFMeta();
    } else if (fileModel.isDoc && fileModel.fileUrl != null) {
      webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(
          'https://docs.google.com/gview?url=${Uri.encodeComponent(fileModel.fileUrl!)}&embedded=true',
        ));
    }

    notifyListeners();
  }

  Future<void> _loadPDFMeta() async {
    final doc = await PdfDocument.openData(fileModel.fileData!);
    totalPages = doc.pagesCount;

    final prefs = await SharedPreferences.getInstance();
    final key = 'bookmark_${fileModel.fileId}';

    if (prefs.containsKey(key)) {
      final savedPage = prefs.getInt(key) ?? 1;
      isBookmarked = true;
      bookmarkedPage = savedPage;
      currentPage = savedPage;

      Future.delayed(const Duration(milliseconds: 100), () {
        pdfController?.jumpToPage(savedPage);
      });
    } else {
      totalPages = doc.pagesCount;
    }
  }

  Future<void> toggleBookmark(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'bookmark_${fileModel.fileId}';
    final allBookmarksKey = 'bookmarks';
    List<String> allBookmarks = prefs.getStringList(allBookmarksKey) ?? [];

    Map<String, dynamic> currentFileData = {
      'id': fileModel.fileId,
      'name': fileModel.fileName,
      'mimeType': fileModel.mimeType,
      'page': fileModel.isPDF ? currentPage : 1,
    };

    if (isBookmarked) {
      await prefs.remove(key);
      allBookmarks.removeWhere(
              (e) => (jsonDecode(e)['id'] ?? '') == fileModel.fileId);
      isBookmarked = false;
      _showSnack(context, 'Bookmark removed');
    } else {
      if (fileModel.isPDF) await prefs.setInt(key, currentPage);
      allBookmarks.add(jsonEncode(currentFileData));
      isBookmarked = true;
      _showSnack(context,
          fileModel.isPDF ? 'Bookmarked page $currentPage' : 'Bookmarked file');
    }

    await prefs.setStringList(allBookmarksKey, allBookmarks);
    notifyListeners();
  }

  void goToBookmark() {
    if (!isBookmarked || !fileModel.isPDF) return;
    pdfController?.jumpToPage(bookmarkedPage);
  }

  void zoomIn() {
    zoomScale = (zoomScale + 0.25).clamp(1.0, 4.0);
    notifyListeners();
  }

  void zoomOut() {
    zoomScale = (zoomScale - 0.25).clamp(1.0, 4.0);
    notifyListeners();
  }

  void updatePage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }
}
