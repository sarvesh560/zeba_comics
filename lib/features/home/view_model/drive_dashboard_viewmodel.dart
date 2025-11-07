import 'package:flutter/material.dart';
import '../../../services/drive_service.dart';
import '../../../utils/home_page_folder_ids.dart';
import '../model/drive_file_model.dart';

class DriveDashboardViewModel extends ChangeNotifier {
  final DriveService _service = DriveService();

  // Sections
  List<DriveFileModel> carouselImages = [];
  List<DriveFileModel> topUpdated = [];
  List<DriveFileModel> trending = [];
  List<DriveFileModel> bestseller = [];
  List<DriveFileModel> newComics = [];
  List<DriveFileModel> topHorror = [];

  bool isLoading = true;

  Future<void> fetchAll() async {
    isLoading = true;
    notifyListeners();

    try {
      carouselImages = await _service.fetchFilesFromFolder(DriveFolders.carouselImages);
      topUpdated = await _service.fetchDocsWithThumbnails(
          DriveFolders.topUpdatedDocs, DriveFolders.topUpdatedImages);
      trending = await _service.fetchDocsWithThumbnails(
          DriveFolders.trendingDocs, DriveFolders.trendingImages);
      bestseller = await _service.fetchDocsWithThumbnails(
          DriveFolders.bestsellerDocs, DriveFolders.bestsellerImages);
      newComics = await _service.fetchDocsWithThumbnails(
          DriveFolders.newComicsDocs, DriveFolders.newComicsImages);
      topHorror = await _service.fetchDocsWithThumbnails(
          DriveFolders.topHorrorDocs, DriveFolders.topHorrorImages);
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
