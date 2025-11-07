import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_drive_reader_app/features/home/view/see_all_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_values.dart';
import '../../file_viewer/model/file_model.dart';
import '../../file_viewer/view/file_viewer_screen.dart';
import '../../file_viewer/view_model/file_viewer_model.dart';
import '../../library/view_model/favourite_view_model.dart';
import '../model/drive_file_model.dart';
import '../view_model/drive_dashboard_viewmodel.dart';
import '../../../provider/theme_provider.dart';

class DriveDashboardScreen extends StatefulWidget {
  const DriveDashboardScreen({super.key});

  @override
  State<DriveDashboardScreen> createState() => _DriveDashboardScreenState();
}

class _DriveDashboardScreenState extends State<DriveDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _openFile(BuildContext context, DriveFileModel file) {
    const apiKey = "AIzaSyCRwbXY06PD_hvLyWCLJp8D2DNdAkYV--w";
    final ext = file.name.split('.').last.toLowerCase();
    final fileId = file.id;

    String directUrl;
    if (file.mimeType == 'application/pdf') {
      directUrl = "https://www.googleapis.com/drive/v3/files/$fileId?alt=media&key=$apiKey";
    } else if (file.mimeType.startsWith('image/')) {
      directUrl = "https://www.googleapis.com/drive/v3/files/$fileId?alt=media&key=$apiKey";
    } else if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
      directUrl = "https://www.googleapis.com/drive/v3/files/$fileId?alt=media&key=$apiKey";
    } else {
      directUrl = "https://drive.google.com/uc?export=download&id=$fileId";
    }

    final fileModel = FileModel(
      fileName: file.name,
      fileId: file.id,
      mimeType: file.mimeType,
      fileUrl: directUrl,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FileViewerViewModel(fileModel),
          child: FileViewerScreen(fileModel: fileModel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = themeProvider.isDark ? AppColors.primaryDark : AppColors.primary;
    final secondaryColor = themeProvider.isDark ? AppColors.secondaryDark : AppColors.secondary;
    final backgroundColor = themeProvider.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = themeProvider.isDark ? AppColors.white : AppColors.black;
    final cardBackground = themeProvider.isDark ? AppColors.cardDark : AppColors.white;
    final shimmerBase = themeProvider.isDark ? AppColors.shimmerBaseDark : AppColors.greyLight;
    final shimmerHighlight = themeProvider.isDark ? AppColors.shimmerHighlightDark : AppColors.white;

    return ChangeNotifierProvider(
      create: (_) => DriveDashboardViewModel()..fetchAll(),
      child: Consumer<DriveDashboardViewModel>(
        builder: (context, vm, _) {
          final filtered = _filterComics(vm);

          return Scaffold(
            backgroundColor: backgroundColor,
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
                "Zeba Books",
                style: AppTextStyles.heading(screenWidth * 0.06, color: AppColors.white),
              ),
              centerTitle: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppValues.radiusLarge),
                ),
              ),
              actions: [
                Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.045,
                  margin: EdgeInsets.only(
                    right: screenWidth * 0.03,
                    top: screenHeight * 0.01,
                    bottom: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(AppValues.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTextStyles.body(screenWidth * 0.035, color: textColor),
                    decoration: InputDecoration(
                      hintText: "Search books...",
                      hintStyle: AppTextStyles.body(screenWidth * 0.033, color: AppColors.greyDark),
                      prefixIcon: Icon(Icons.search, color: primaryColor, size: screenWidth * 0.05),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: screenWidth * 0.08,
                        minHeight: screenHeight * 0.04,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.005,
                        horizontal: screenWidth * 0.02,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () async => vm.fetchAll(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.04,
                      screenHeight * 0.025,
                      screenWidth * 0.04,
                      screenHeight * 0.15, // padding for FAB
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection("Top Updated", filtered["topUpdated"] ?? [], vm.isLoading,
                            screenWidth, screenHeight, cardBackground, textColor, shimmerBase, shimmerHighlight),
                        _buildSection("Bestsellers", filtered["bestseller"] ?? [], vm.isLoading,
                            screenWidth, screenHeight, cardBackground, textColor, shimmerBase, shimmerHighlight),
                        _buildSection("Trending Now", filtered["trending"] ?? [], vm.isLoading,
                            screenWidth, screenHeight, cardBackground, textColor, shimmerBase, shimmerHighlight),
                        _buildSection("New Arrivals", filtered["newComics"] ?? [], vm.isLoading,
                            screenWidth, screenHeight, cardBackground, textColor, shimmerBase, shimmerHighlight),
                        _buildSection("Top Horror", filtered["topHorror"] ?? [], vm.isLoading,
                            screenWidth, screenHeight, cardBackground, textColor, shimmerBase, shimmerHighlight),
                      ],
                    ),
                  ),
                ),

                // Floating Share Button
                Positioned(
                  bottom: screenHeight * 0.10,
                  right: screenWidth * 0.04,
                  child: FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: () {
                      Share.share(
                        "📚 Check out Zeba Books! Explore trending comics here: https://zebabooks.org",
                      );
                    },
                    child: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      String title,
      List<DriveFileModel> list,
      bool isLoading,
      double screenWidth,
      double screenHeight,
      Color cardBackground,
      Color textColor,
      Color shimmerBase,
      Color shimmerHighlight,
      ) {
    final cardSpacing = screenWidth * 0.03;
    final cardWidth = (screenWidth - cardSpacing * 2 - screenWidth * 0.06) / 3;
    final cardHeight = cardWidth / 0.65;

    Color badgeColor;
    Widget badgeWidget;
    switch (title) {
      case "Top Updated":
        badgeColor = Colors.orangeAccent;
        badgeWidget = Icon(Icons.update, size: screenWidth * 0.05, color: badgeColor);
        break;
      case "Bestsellers":
        badgeColor = Colors.redAccent;
        badgeWidget = Icon(Icons.star, size: screenWidth * 0.05, color: badgeColor);
        break;
      case "Trending Now":
        badgeColor = Colors.purpleAccent;
        badgeWidget = Icon(Icons.trending_up, size: screenWidth * 0.05, color: badgeColor);
        break;
      case "New Arrivals":
        badgeColor = Colors.greenAccent;
        badgeWidget = Icon(Icons.new_releases, size: screenWidth * 0.05, color: badgeColor);
        break;
      case "Top Horror":
        badgeColor = Colors.deepPurple;
        badgeWidget = Text("👻", style: TextStyle(fontSize: screenWidth * 0.05));
        break;
      default:
        badgeColor = Colors.grey;
        badgeWidget = SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: badgeWidget,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  title,
                  style: AppTextStyles.subHeading(
                    screenWidth * 0.045,
                    color: textColor,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (list.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeeAllBooksScreen(title: title, books: list),
                    ),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.035,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badgeColor.withOpacity(0.8), badgeColor],
                  ),
                  borderRadius: BorderRadius.circular(AppValues.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Text(
                  "Explore",
                  style: AppTextStyles.body(
                    screenWidth * 0.032,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.015),
        SizedBox(
          height: cardHeight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOut,
            child: isLoading
                ? _buildShimmerList(cardWidth, cardHeight, shimmerBase, shimmerHighlight)
                : list.isEmpty
                ? Center(child: Text("No books available", style: TextStyle(color: textColor)))
                : ListView.separated(
              key: ValueKey(title),
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, __) => SizedBox(width: cardSpacing),
              itemBuilder: (_, i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 40, end: 0),
                  duration: Duration(milliseconds: 400 + (i * 100)),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) => Opacity(
                    opacity: (1 - offset / 40).clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, offset),
                      child: child,
                    ),
                  ),
                  child: _buildCard(list[i], cardWidth, cardHeight, cardBackground, textColor),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      DriveFileModel file,
      double cardWidth,
      double cardHeight,
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

              await Share.shareXFiles(
                [XFile(filePath)],
                text: file.name,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to share thumbnail')),
              );
            }
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
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
                            onTap: () => favVm.toggleFavorite(file, context),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : AppColors.greyDark,
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

  Widget _buildShimmerList(
      double cardWidth,
      double cardHeight,
      Color baseColor,
      Color highlightColor,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) => Opacity(
        opacity: opacity,
        child: child,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: cardWidth * 0.08),
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1300),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(AppValues.radiusMedium),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, List<DriveFileModel>> _filterComics(DriveDashboardViewModel vm) {
    bool matches(DriveFileModel f) => f.name.toLowerCase().contains(_searchQuery);
    return {
      "topUpdated": vm.topUpdated?.where(matches).toList() ?? [],
      "bestseller": vm.bestseller?.where(matches).toList() ?? [],
      "trending": vm.trending?.where(matches).toList() ?? [],
      "newComics": vm.newComics?.where(matches).toList() ?? [],
      "topHorror": vm.topHorror?.where(matches).toList() ?? [],
    };
  }
}
