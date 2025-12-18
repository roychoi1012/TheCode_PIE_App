import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thecode_pie_app/constants/app_colors.dart';
import 'package:thecode_pie_app/quiz/data/data_source/progress_storage.dart';

import '../../component/retro_background.dart';
import '../../component/retro_glass_card.dart';
import 'quiz_view_model.dart';
import 'quiz_screen_root.dart';
import '../../../providers/app_providers.dart';

class QuizScreen extends StatefulWidget {
  final int episodeId;
  final int stageNo;

  const QuizScreen({super.key, required this.episodeId, required this.stageNo});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  int _lastClearedStageNo = 0;
  bool _hasLoadedStage = false;

  Future<void> _goToStage({required int stageNo}) async {
    await ProgressStorage.saveLastProgress(
      episodeId: widget.episodeId,
      stageNo: stageNo,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<QuizViewModel>(
          create: (_) => DependencyInjection.createQuizViewModel(),
          child: QuizScreenRoot(episodeId: widget.episodeId, stageNo: stageNo),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 시점도 "마지막으로 푼 곳"으로 간주하여 저장
    ProgressStorage.saveLastProgress(
      episodeId: widget.episodeId,
      stageNo: widget.stageNo,
    );

    ProgressStorage.getLastClearedStageNo(episodeId: widget.episodeId).then((
      value,
    ) {
      if (!mounted) return;
      setState(() => _lastClearedStageNo = value);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _showHintDialog(String hint) async {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(
          'HINT',
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: AppColors.accentOrange,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          hint,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: AppColors.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResultSnackBar(
    String message, {
    required bool success,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.accentOrange : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RetroBackground(),
          SafeArea(
            child: Consumer<QuizViewModel>(
              builder: (context, vm, _) {
                // Consumer 내부에서 한 번만 loadStage 호출
                if (!_hasLoadedStage &&
                    vm.stage == null &&
                    !vm.isLoadingStage) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_hasLoadedStage) {
                      vm.loadStage(
                        episodeId: widget.episodeId,
                        stageNo: widget.stageNo,
                      );
                      _hasLoadedStage = true;
                    }
                  });
                }

                final stage = vm.stage;
                final canGoPrev = widget.stageNo > 1;
                final canGoNext =
                    stage?.nextStageNo != null &&
                    _lastClearedStageNo >= widget.stageNo;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 상단 헤더
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accentOrange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: AppColors.accentOrange,
                                size: 24,
                              ),
                              tooltip: '뒤로',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stage != null
                                        ? 'STAGE ${stage.stageNo}'
                                        : 'STAGE ${widget.stageNo}',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 14,
                                      color: AppColors.accentOrange,
                                      letterSpacing: 2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'EPISODE ${widget.episodeId}',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 8,
                                      color: AppColors.textTertiary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: RetroGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (vm.isLoadingStage) ...[
                                const SizedBox(height: 12),
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ] else if (stage == null) ...[
                                Text(
                                  '스테이지 정보를 불러오지 못했습니다.',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (vm.errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    vm.errorMessage!,
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 8,
                                      color: Colors.red.shade300,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    vm.loadStage(
                                      episodeId: widget.episodeId,
                                      stageNo: widget.stageNo,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    foregroundColor: AppColors.textPrimary,
                                  ),
                                  child: Text(
                                    'RETRY',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 12,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                // 스테이지 타이틀
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.accentOrange.withOpacity(0.2),
                                        AppColors.accentOrange.withOpacity(
                                          0.05,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.accentOrange.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    stage.title,
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 16,
                                      color: AppColors.accentOrange,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.accentOrange
                                              .withOpacity(0.5),
                                          blurRadius: 8,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // 이미지 컨테이너 (그림자 효과 추가)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentOrange
                                            .withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: stage.imageUrl == null
                                          ? Container(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                '이미지가 없습니다.',
                                                style: GoogleFonts.pressStart2p(
                                                  fontSize: 8,
                                                  color:
                                                      AppColors.textSecondary,
                                                  height: 1.6,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
                                                  stage.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        }
                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                color: AppColors
                                                                    .accentOrange,
                                                              ),
                                                        );
                                                      },
                                                  errorBuilder: (context, error, stack) {
                                                    return Container(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            '이미지를 불러올 수 없습니다.\n(만료되었을 수 있어요)',
                                                            style: GoogleFonts.pressStart2p(
                                                              fontSize: 8,
                                                              color: AppColors
                                                                  .textSecondary,
                                                              height: 1.6,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          ElevatedButton(
                                                            onPressed:
                                                                vm.isLoadingStage
                                                                ? null
                                                                : () {
                                                                    vm.loadStage(
                                                                      episodeId:
                                                                          widget
                                                                              .episodeId,
                                                                      stageNo:
                                                                          widget
                                                                              .stageNo,
                                                                    );
                                                                  },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .accentOrange,
                                                              foregroundColor:
                                                                  AppColors
                                                                      .textPrimary,
                                                            ),
                                                            child: Text(
                                                              'REFRESH',
                                                              style:
                                                                  GoogleFonts.pressStart2p(
                                                                    fontSize:
                                                                        10,
                                                                    letterSpacing:
                                                                        1,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // 답변 입력 필드
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentOrange
                                            .withOpacity(0.2),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _answerController,
                                    enabled: !vm.isSubmitting,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 2,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'ENTER ANSWER',
                                      hintStyle: GoogleFonts.pressStart2p(
                                        fontSize: 10,
                                        color: AppColors.textTertiary,
                                        letterSpacing: 1,
                                      ),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.4),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: AppColors.accentOrange
                                              .withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: AppColors.accentOrange
                                              .withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: AppColors.accentOrange,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // 네비게이션 및 제출 버튼
                                Row(
                                  children: [
                                    // 왼쪽: 이전 문제 (있을 때만)
                                    if (canGoPrev)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.accentOrange
                                                .withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: vm.isSubmitting
                                              ? null
                                              : () => _goToStage(
                                                  stageNo: widget.stageNo - 1,
                                                ),
                                          icon: const Icon(
                                            Icons.chevron_left,
                                            color: AppColors.accentOrange,
                                            size: 32,
                                          ),
                                          tooltip: '이전 문제',
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 48),

                                    // 중앙: 정답 제출
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accentOrange
                                                  .withOpacity(0.4),
                                              blurRadius: 16,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: vm.isSubmitting
                                              ? null
                                              : () async {
                                                  final answer =
                                                      _answerController.text;
                                                  final result = await vm
                                                      .submitAnswer(
                                                        episodeId:
                                                            widget.episodeId,
                                                        stageNo: widget.stageNo,
                                                        answer: answer,
                                                      );
                                                  if (!context.mounted) return;

                                                  if (result == null) {
                                                    await _showResultSnackBar(
                                                      vm.errorMessage ??
                                                          '정답 제출에 실패했습니다.',
                                                      success: false,
                                                    );
                                                    return;
                                                  }

                                                  await _showResultSnackBar(
                                                    result.message,
                                                    success: result.isCorrect,
                                                  );

                                                  if (result.isCorrect) {
                                                    await ProgressStorage.markStageCleared(
                                                      episodeId:
                                                          widget.episodeId,
                                                      stageNo: widget.stageNo,
                                                    );
                                                    if (!context.mounted)
                                                      return;
                                                    setState(
                                                      () => _lastClearedStageNo =
                                                          _lastClearedStageNo <
                                                              widget.stageNo
                                                          ? widget.stageNo
                                                          : _lastClearedStageNo,
                                                    );

                                                    final next =
                                                        vm.stage?.nextStageNo;
                                                    if (next != null) {
                                                      _answerController.clear();
                                                      await _goToStage(
                                                        stageNo: next,
                                                      );
                                                    } else {
                                                      // 마지막 스테이지: 화면 유지
                                                      await _showResultSnackBar(
                                                        '마지막 스테이지입니다.',
                                                        success: true,
                                                      );
                                                    }
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.accentOrange,
                                            foregroundColor:
                                                AppColors.textPrimary,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: vm.isSubmitting
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : Text(
                                                  'SUBMIT',
                                                  style:
                                                      GoogleFonts.pressStart2p(
                                                        fontSize: 12,
                                                        letterSpacing: 2,
                                                      ),
                                                ),
                                        ),
                                      ),
                                    ),

                                    // 오른쪽: 다음 문제 (있을 때만)
                                    if (canGoNext)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.accentOrange
                                                .withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: vm.isSubmitting
                                              ? null
                                              : () => _goToStage(
                                                  stageNo:
                                                      stage.nextStageNo ??
                                                      widget.stageNo,
                                                ),
                                          icon: const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.accentOrange,
                                            size: 32,
                                          ),
                                          tooltip: '다음 문제',
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 48),
                                  ],
                                ),
                                // 힌트 버튼
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.accentOrange.withOpacity(
                                        0.5,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: vm.isLoadingHint
                                        ? null
                                        : () async {
                                            final hint = await vm.loadHint(
                                              episodeId: widget.episodeId,
                                              stageNo: widget.stageNo,
                                            );
                                            if (!context.mounted) return;
                                            if (hint != null) {
                                              await _showHintDialog(
                                                hint.content,
                                              );
                                            } else if (vm.errorMessage !=
                                                null) {
                                              await _showResultSnackBar(
                                                vm.errorMessage!,
                                                success: false,
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.1,
                                      ),
                                      foregroundColor: AppColors.accentOrange,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: vm.isLoadingHint
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.accentOrange,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.lightbulb_outline,
                                                size: 18,
                                                color: AppColors.accentOrange,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'HINT',
                                                style: GoogleFonts.pressStart2p(
                                                  fontSize: 11,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                if (stage.nextStageNo == null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentOrange.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accentOrange
                                            .withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.flag,
                                          size: 16,
                                          color: AppColors.accentOrange,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'LAST STAGE',
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 10,
                                            color: AppColors.accentOrange,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (vm.errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    vm.errorMessage!,
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 8,
                                      color: Colors.red.shade300,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
