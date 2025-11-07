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

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await _loadData();
  }

  void _openFile(BuildContext context, DriveFileModel file) {
    const apiKey = "AIzaSyCRwbXY06PD_hvLyWCLJp8D2DNdAkYV--w";
    final ext = file.name.split('.').last.toLowerCase();
    final fileId = file.id;

    final fileUrl =
        "https://www.googleapis.com/drive/v3/files/$fileId?alt=media&key=$apiKey";

    final directUrl = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']
        .contains(ext)
        ? fileUrl
        : "https://drive.google.com/uc?export=download&id=$fileId";

    final fileModel = FileModel(
      fileName: file.name,
      fileId: file.id,
      mimeType: file.mimeType,
      fileUrl: directUrl,
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
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final primaryColor =
    themeProvider.isDark ? AppColors.primaryDark : AppColors.primary;
    final secondaryColor =
    themeProvider.isDark ? AppColors.secondaryDark : AppColors.secondary;
    final bgColor = themeProvider.isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final cardColor =
    themeProvider.isDark ? AppColors.cardDark : AppColors.white;
    final textColor =
    themeProvider.isDark ? AppColors.white : AppColors.black;
    final searchBarColor =
    themeProvider.isDark ? AppColors.searchBarDark : AppColors.white;
    final hintColor =
    themeProvider.isDark ? AppColors.greyLight : AppColors.greyDark;
    final shimmerBase =
    themeProvider.isDark ? AppColors.shimmerBaseDark : AppColors.greyLight;
    final shimmerHighlight = themeProvider.isDark
        ? AppColors.shimmerHighlightDark
        : AppColors.white;

    final favVm = Provider.of<FavoritesViewModel>(context);
    List<DriveFileModel> allFiles = favVm.favorites;
    if (searchQuery.isNotEmpty) {
      allFiles = allFiles
          .where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Library",
          style: AppTextStyles.heading(screenWidth * 0.06, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(
                screenWidth, screenHeight, searchBarColor, hintColor, textColor),
            Expanded(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: _refreshData,
                child: isLoading
                    ? _buildShimmer(screenWidth, screenHeight, shimmerBase, shimmerHighlight)
                    : allFiles.isEmpty
                    ? Center(
                  child: Text(
                    "No Comics Found",
                    style: AppTextStyles.subHeading(
                      screenWidth * 0.045,
                      color: AppColors.greyDark,
                    ),
                  ),
                )
                    : Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: screenWidth * 0.02,
                      mainAxisSpacing: screenHeight * 0.02,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: allFiles.length,
                    itemBuilder: (context, index) => _buildCard(
                      allFiles[index],
                      cardColor,
                      textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth, double screenHeight, Color bgColor,
      Color hintColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppValues.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: AppTextStyles.body(screenWidth * 0.035, color: textColor),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search,
                color: hintColor, size: screenWidth * 0.06),
            hintText: "Search books...",
            hintStyle: AppTextStyles.body(screenWidth * 0.035, color: hintColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.015),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      DriveFileModel file,
      Color cardBackground,
      Color textColor,
      ) {
    return Consumer<FavoritesViewModel>(
      builder: (context, favVm, _) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                14,
                                color: textColor,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => favVm.toggleFavorite(file,context),
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isFav ? Colors.red : AppColors.greyDark,
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
      },
    );
  }

  Widget _buildShimmer(
      double screenWidth,
      double screenHeight,
      Color baseColor,
      Color highlightColor,
      ) {
    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.03),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: screenWidth * 0.02,
        mainAxisSpacing: screenHeight * 0.02,
        childAspectRatio: 0.65,
      ),
      itemCount: 9,
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
