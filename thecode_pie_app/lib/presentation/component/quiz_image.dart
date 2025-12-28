import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';

/// 퀴즈 이미지 컴포넌트 (정사각형)
class QuizImage extends StatelessWidget {
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const QuizImage({
    super.key,
    required this.imageUrl,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder 대신 AspectRatio를 사용하여 1:1 비율 강제
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1.0, // 가로:세로 = 1:1 (정사각형)
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl == null
                ? const SizedBox.shrink()
                : Image.network(imageUrl!),
          ),
        ),
      ),
    );
  }
}
