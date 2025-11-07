import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../view_model/category_view_model.dart';
import '../../../provider/theme_provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String searchQuery = "";

  final List<String> tabs = const [
    'Romance',
    'Horror',
    'Thriller',
    'Action & Adventures',
    'Humour',
  ];

  @override
  void initState() {
    super.initState();

    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // adjust for dark theme
    ));
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
    final vm = Provider.of<CategoryViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    final primaryColor =
    themeProvider.isDark ? AppColors.primaryDark : AppColors.primary;
    final secondaryColor =
    themeProvider.isDark ? AppColors.secondaryDark : AppColors.secondary;
    final textColor = themeProvider.isDark ? AppColors.white : AppColors.black;
    final cardBackground =
    themeProvider.isDark ? AppColors.cardDark : AppColors.white;
    final shimmerBase =
    themeProvider.isDark ? AppColors.shimmerBaseDark : AppColors.greyLight;
    final shimmerHighlight =
    themeProvider.isDark ? AppColors.shimmerHighlightDark : AppColors.white;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: themeProvider.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: Column(
          children: [
            _buildAppBar(screenWidth, screenHeight, primaryColor, secondaryColor, textColor),
            Expanded(
              child: TabBarView(
                children: tabs.map((tab) {
                  List<DriveFileModel> files = vm.tabFiles[tab] ?? [];
                  if (searchQuery.isNotEmpty) {
                    files = files
                        .where((f) =>
                        f.name.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (vm.isLoading) {
                    return _buildShimmerGrid(
                        screenWidth, screenHeight, shimmerBase, shimmerHighlight);
                  }

                  if (files.isEmpty) {
                    return Center(
                      child: Text(
                        "No Comics Found",
                        style: AppTextStyles.subHeading(screenWidth * 0.04,
                            color: textColor),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: screenWidth * 0.02,
                        mainAxisSpacing: screenHeight * 0.02,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: files.length,
                      itemBuilder: (_, index) =>
                          _buildCard(files[index], cardBackground, textColor),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(double screenWidth, double screenHeight, Color primaryColor,
      Color secondaryColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      // removed SafeArea to extend under notch
      child: Padding(
        padding: EdgeInsets.only(
            top: screenHeight * 0.04, // optional padding to avoid notch overlap
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenHeight * 0.01),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.07),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.greyDark, size: screenWidth * 0.06),
                  hintText: "Search books...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TabBar(
              isScrollable: true,
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white,
              labelStyle: AppTextStyles.subHeading(screenWidth * 0.035,
                  color: AppColors.white, weight: FontWeight.bold),
              tabs: tabs.map((tab) => Tab(text: tab.toUpperCase())).toList(),
            ),
          ],
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

  Widget _buildShimmerGrid(
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
        mainAxisSpacing: screenHeight * 0.02,
        crossAxisSpacing: screenWidth * 0.02,
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
