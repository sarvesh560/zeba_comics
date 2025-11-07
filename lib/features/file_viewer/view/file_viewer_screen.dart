import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:pdfx/pdfx.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/app_values.dart';
import '../../../provider/theme_provider.dart';
import '../model/file_model.dart';
import '../view_model/file_viewer_model.dart';

class FileViewerScreen extends StatefulWidget {
  final FileModel fileModel;

  const FileViewerScreen({super.key, required this.fileModel});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _secureScreen();
  }

  Future<void> _secureScreen() async {
    await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Screenshots and screen recording are disabled for security.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black.withOpacity(0.85),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80.0, left: 16, right: 16),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final fabSize = width * 0.12;
    final fontSize = width * 0.04;
    final padding = width * 0.03;
    final btnHeight = height * 0.055;
    final btnWidth = width * 0.28;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.white : AppColors.black;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: ChangeNotifierProvider(
        create: (_) => FileViewerViewModel(widget.fileModel)..init(),
        builder: (context, _) {
          final vm = context.watch<FileViewerViewModel>();

          return Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildFileContent(vm, textColor)),
                  Positioned(
                    top: padding,
                    left: padding,
                    child: FloatingActionButton.small(
                      heroTag: 'back_btn',
                      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                      onPressed: () async {
                        if (await _onWillPop()) Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: textColor,
                        size: fabSize * 0.5,
                      ),
                    ),
                  ),
                  if (vm.fileModel.isPDF)
                    Positioned(
                      bottom: padding,
                      left: padding,
                      right: padding,
                      child: _buildPdfControls(
                        vm,
                        width,
                        height,
                        fontSize,
                        btnHeight,
                        btnWidth,
                        textColor,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileContent(FileViewerViewModel vm, Color textColor) {
    // Show loading spinner while initializing
    if (vm.pdfController == null && vm.webController == null && !vm.fileModel.isImage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.fileModel.isPDF) {
      if (vm.pdfController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Transform.scale(
        scale: vm.zoomScale,
        alignment: Alignment.topCenter,
        child: PdfViewPinch(
          controller: vm.pdfController!,
          onPageChanged: (page) => vm.updatePage(page),
        ),
      );
    } else if (vm.fileModel.isImage) {
      if (vm.fileModel.fileData == null) {
        return Center(
          child: Text("Image data not available", style: AppTextStyles.body(16, color: textColor)),
        );
      }
      return InteractiveViewer(
        maxScale: 4.0,
        minScale: 1.0,
        child: Image.memory(
          vm.fileModel.fileData!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (vm.webController != null) {
      return WebViewWidget(controller: vm.webController!);
    } else {
      return Center(
        child: Text("Cannot display file", style: AppTextStyles.body(16, color: textColor)),
      );
    }
  }

  Widget _buildPdfControls(
      FileViewerViewModel vm,
      double width,
      double height,
      double fontSize,
      double btnHeight,
      double btnWidth,
      Color textColor,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${vm.currentPage} / ${vm.totalPages}',
              style: AppTextStyles.body(fontSize, color: textColor),
            ),
            Expanded(
              child: Text(
                vm.fileModel.fileName,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(fontSize, color: textColor),
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: btnHeight,
              width: btnWidth,
              child: ElevatedButton.icon(
                onPressed: vm.zoomOut,
                icon: Icon(Icons.remove, size: fontSize * 0.8),
                label: Text('Zoom Out', style: AppTextStyles.body(fontSize * 0.8)),
              ),
            ),
            SizedBox(width: width * 0.03),
            SizedBox(
              height: btnHeight,
              width: btnWidth,
              child: ElevatedButton.icon(
                onPressed: vm.zoomIn,
                icon: Icon(Icons.add, size: fontSize * 0.8),
                label: Text('Zoom In', style: AppTextStyles.body(fontSize * 0.8)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
