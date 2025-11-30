import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class FileInputWidget extends StatelessWidget {
  final File? file;
  final String hintText;
  final bool isDark;
  final VoidCallback onTap;

  const FileInputWidget({
    super.key,
    required this.file,
    required this.hintText,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.bgPrimaryInputBoxDark 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null
                ? AppColors.primaryLight
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: file != null
                    ? AppColors.primaryLight.withOpacity(0.1)
                    : (isDark 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                file != null ? Icons.check_circle : Icons.upload_file,
                color: file != null
                    ? AppColors.primaryLight
                    : (isDark 
                        ? AppColors.textSecondaryDark 
                        : Colors.grey.shade400),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file?.path != null ? file!.path.split('/').last : hintText,
                style: TextStyle(
                  color: file != null
                      ? (isDark 
                          ? AppColors.textPrimaryDark 
                          : AppColors.textPrimaryLight)
                      : (isDark 
                          ? AppColors.textSecondaryDark 
                          : Colors.grey.shade400),
                  fontSize: 14,
                  fontWeight: file != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark 
                  ? AppColors.textSecondaryDark 
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
