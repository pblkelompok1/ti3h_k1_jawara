import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../themes/app_colors.dart';

class PdfViewer extends StatefulWidget {
  final String documentUrl;
  final String documentName;

  const PdfViewer({
    super.key,
    required this.documentUrl,
    required this.documentName,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        title: Text(
          widget.documentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.documentUrl,
            controller: _pdfViewerController,
            enableDoubleTapZooming: true,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
          ),
          // Page indicator
          if (_totalPages > 0)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
