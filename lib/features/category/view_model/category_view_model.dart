import 'package:flutter/material.dart';
import '../../../services/drive_service.dart';
import '../../../utils/category_page_folder.dart';
import '../../home/model/drive_file_model.dart';

class CategoryViewModel extends ChangeNotifier {
  final DriveService _service = DriveService();

  bool isLoading = true;
  String _searchQuery = "";

  // All fetched data
  final Map<String, List<DriveFileModel>> _allTabFiles = {
    'Romance': [],
    'Horror': [],
    'Thriller': [],
    'Action & Adventures': [],
    'Humour': [],
  };

  // Filtered data for UI
  final Map<String, List<DriveFileModel>> tabFiles = {
    'Romance': [],
    'Horror': [],
    'Thriller': [],
    'Action & Adventures': [],
    'Humour': [],
  };

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();

    try {
      _allTabFiles['Romance'] = await _service.fetchDocsWithThumbnails(
        CategoryFolders.romanceDocs,
        CategoryFolders.romanceImages,
      );
      _allTabFiles['Horror'] = await _service.fetchDocsWithThumbnails(
        CategoryFolders.horrorDocs,
        CategoryFolders.horrorImages,
      );
      _allTabFiles['Thriller'] = await _service.fetchDocsWithThumbnails(
        CategoryFolders.thrillerDocs,
        CategoryFolders.thrillerImages,
      );
      _allTabFiles['Action & Adventures'] = await _service.fetchDocsWithThumbnails(
        CategoryFolders.actionDocs,
        CategoryFolders.actionImages,
      );
      _allTabFiles['Humour'] = await _service.fetchDocsWithThumbnails(
        CategoryFolders.humourDocs,
        CategoryFolders.humourImages,
      );

      // Initialize tabFiles
      tabFiles.forEach((key, _) => tabFiles[key] = List.from(_allTabFiles[key]!));
    } catch (e) {
      debugPrint("Error fetching category files: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // --- SEARCH FUNCTIONALITY ---
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();

    tabFiles.forEach((category, files) {
      final allFiles = _allTabFiles[category] ?? [];
      if (_searchQuery.isEmpty) {
        tabFiles[category] = List.from(allFiles);
      } else {
        tabFiles[category] = allFiles
            .where((file) => file.name.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });

    notifyListeners();
  }
}
