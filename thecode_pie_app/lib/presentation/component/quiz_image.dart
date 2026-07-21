import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/services/sound_effects_service.dart';

class QuizImage extends StatelessWidget {
  const QuizImage({
    super.key,
    required this.imageUrl,
    this.isLoading = false,
    this.onRefresh,
    this.showShadow = true,
    this.showBorder = true,
    this.borderWidth = 1,
    this.borderColor,
    this.borderRadius = 8,
  });

  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final bool showShadow;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final frameColor = borderColor ?? AppColors.crust.withValues(alpha: 0.4);

    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: showBorder ? EdgeInsets.all(borderWidth) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: showBorder
                ? frameColor
                : AppColors.surface.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: showShadow
                ? const [
                    BoxShadow(
                      color: Color(0x55210F20),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              showBorder
                  ? (borderRadius - 3).clamp(0, borderRadius)
                  : borderRadius,
            ),
            child: ColoredBox(
              color: AppColors.surface.withValues(alpha: 0.12),
              child: imageUrl == null
                  ? const SizedBox.shrink()
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.pumpkin,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: IconButton(
                            onPressed: SoundEffectsService().withSelect(
                              onRefresh,
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.crust,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
