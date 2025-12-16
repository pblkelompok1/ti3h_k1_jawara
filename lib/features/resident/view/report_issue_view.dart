import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../report/models/report_model.dart';
import '../../report/provider/report_provider.dart';
import '../../../core/services/report_service.dart';
import './report_create_tab.dart';
import './report_list_tab.dart';

class ReportIssueView extends ConsumerStatefulWidget {
  const ReportIssueView({super.key});

  @override
  ConsumerState<ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends ConsumerState<ReportIssueView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Lapor Masalah'),
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange(context),
          labelColor: AppColors.orange(context),
          unselectedLabelColor:
              isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: const [
            Tab(text: 'Buat Laporan'),
            Tab(text: 'Riwayat Laporan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ReportCreateTab(),
          ReportListTab(),
        ],
      ),
    );
  }
}
