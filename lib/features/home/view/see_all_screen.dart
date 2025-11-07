import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_values.dart';
import '../../file_viewer/model/file_model.dart';
import '../../file_viewer/view/file_viewer_screen.dart';
import '../../library/view_model/favourite_view_model.dart';
import '../../home/model/drive_file_model.dart';
import '../../../provider/theme_provider.dart';

class SeeAllBooksScreen extends StatefulWidget {
  final String title;
  final List<DriveFileModel> books;
  final bool isLoading;

  const SeeAllBooksScreen({
    super.key,
    required this.title,
    required this.books,
    this.isLoading = false,
  });

  @override
  State<SeeAllBooksScreen> createState() => _SeeAllBooksScreenState();
}

class _SeeAllBooksScreenState extends State<SeeAllBooksScreen> {
  String searchQuery = "";

  Future<void> _refresh() async {
    setState(() {});
  }

  void _openFile(BuildContext context, DriveFileModel file) {
    final fileModel = FileModel(
      fileName: file.name,
      fileId: file.id,
      mimeType: file.mimeType,
      fileUrl: "https://drive.google.com/uc?export=download&id=${file.id}",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FileViewerScreen(fileModel: fileModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor =
    themeProvider.isDark ? AppColors.primaryDark : AppColors.primary;
    final secondaryColor =
    themeProvider.isDark ? AppColors.secondaryDark : AppColors.secondary;
    final bgColor =
    themeProvider.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = themeProvider.isDark ? AppColors.cardDark : AppColors.white;
    final textColor = themeProvider.isDark ? AppColors.white : AppColors.black;
    final shimmerBase =
    themeProvider.isDark ? AppColors.shimmerBaseDark : AppColors.greyLight;
    final shimmerHighlight =
    themeProvider.isDark ? AppColors.shimmerHighlightDark : AppColors.white;

    final favVm = Provider.of<FavoritesViewModel>(context);
    List<DriveFileModel> displayedBooks = widget.books;
    if (searchQuery.isNotEmpty) {
      displayedBooks = displayedBooks
          .where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.heading(screenWidth * 0.06, color: AppColors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            children: [
              const SizedBox(height: 10),
              widget.isLoading
                  ? _buildShimmerGrid(screenWidth, screenHeight, shimmerBase, shimmerHighlight)
                  : displayedBooks.isEmpty
                  ? SizedBox(
                height: screenHeight * 0.7,
                child: Center(
                  child: Text(
                    "No Books Found",
                    style: AppTextStyles.subHeading(16, color: textColor),
                  ),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedBooks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final file = displayedBooks[index];
                  return _buildCard(file, cardColor, textColor, favVm, screenWidth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      DriveFileModel file,
      Color cardBackground,
      Color textColor,
      FavoritesViewModel favVm,
      double screenWidth) {
    final isFav = favVm.isFavorite(file);
    final thumbnail = file.thumbnail.isNotEmpty
        ? file.thumbnail
        : 'https://via.placeholder.com/140x180?text=No+Image';

    return GestureDetector(
      onTap: () => _openFile(context, file),
      onLongPress: () async {
        try {
          final response = await http.get(Uri.parse(thumbnail));
          final bytes = response.bodyBytes;
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/${file.name}.png';
          final imageFile = File(filePath);
          await imageFile.writeAsBytes(bytes);
          await Share.shareXFiles([XFile(filePath)]);
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to share thumbnail')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(AppValues.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppValues.radiusMedium),
          child: Column(
            children: [
              Expanded(
                flex: 85,
                child: Image.network(
                  thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.greyLight,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 15,
                child: Container(
                  color: cardBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(
                            13,
                            color: textColor,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => favVm.toggleFavorite(file, context),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(
      double screenWidth, double screenHeight, Color baseColor, Color highlightColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(AppValues.radiusMedium),
          ),
        ),
      ),
    );
  }
}
