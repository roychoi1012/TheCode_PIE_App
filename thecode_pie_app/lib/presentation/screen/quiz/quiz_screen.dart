import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';
import 'package:thecode_pie_app/core/services/ad_manager_service.dart';
import 'package:thecode_pie_app/core/services/sound_effects_service.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';
import 'package:thecode_pie_app/quiz/data/data_source/progress_storage.dart';

import '../../component/retro_background.dart';
import '../../component/retro_glass_card.dart';
import '../../component/premium_purchase_dialog.dart';
import '../../component/quiz_image.dart';
import '../../component/settings_button.dart';
import '../auth/auth_view_model.dart';
import '../../purchase/purchase_view_model.dart';
import '../stage_select/stage_select_screen.dart';
import 'quiz_view_model.dart';
import 'quiz_screen_root.dart';
import '../../../providers/app_providers.dart';
import '../../component/banner_ad_box.dart';
import '../../component/drawing_board.dart';

class QuizScreen extends StatefulWidget {
  final int episodeId;
  final String episodeCode;
  final int stageNo;

  const QuizScreen({
    super.key,
    required this.episodeId,
    required this.episodeCode,
    required this.stageNo,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final DrawingBoardController _drawingController = DrawingBoardController();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _questionAreaKey = GlobalKey();
  final GlobalKey _imageAreaKey = GlobalKey();
  Rect? _drawingBounds;
  double _drawingStrokeScale = 1.0;
  bool _hasLoadedStage = false;
  bool _showWrongAnswer = false;
  bool _isReturningToStageSelect = false;
  late final AnimationController _wrongAnswerController;

  final AdManagerService _adManager = AdManagerService();

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
          child: QuizScreenRoot(
            episodeId: widget.episodeId,
            episodeCode: widget.episodeCode,
            stageNo: stageNo,
          ),
        ),
      ),
    );
  }

  Future<void> _goToStageSelect() async {
    if (_isReturningToStageSelect) return;
    _isReturningToStageSelect = true;

    var currentStageNo = widget.stageNo;
    var highestStageNo = widget.stageNo;

    try {
      final start = await context.read<QuizViewModel>().resolveStartProgress();
      currentStageNo = start.stageNo;
      highestStageNo = start.highestStageNo ?? start.stageNo;
    } catch (_) {
      final lastClearedStageNo = await ProgressStorage.getLastClearedStageNo(
        episodeId: widget.episodeId,
      );
      final localHighestStageNo = lastClearedStageNo + 1;
      if (localHighestStageNo > highestStageNo) {
        highestStageNo = localHighestStageNo;
        currentStageNo = localHighestStageNo;
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StageSelectScreen(
          episodeId: widget.episodeId,
          episodeCode: widget.episodeCode,
          currentStageNo: currentStageNo,
          highestStageNo: highestStageNo,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wrongAnswerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    // ?붾㈃ 吏꾩엯 ?쒖젏??"留덉?留됱쑝濡???怨??쇰줈 媛꾩＜?섏뿬 ???
    ProgressStorage.saveLastProgress(
      episodeId: widget.episodeId,
      stageNo: widget.stageNo,
    );

    final currentUser = Provider.of<AuthViewModel>(
      context,
      listen: false,
    ).currentUser;
    final purchaseViewModel = Provider.of<PurchaseViewModel>(
      context,
      listen: false,
    );
    final adUserId =
        currentUser?.providerUserId ?? currentUser?.id?.toString() ?? '';
    if (!purchaseViewModel.skipsHintAds &&
        adUserId.isNotEmpty &&
        widget.episodeCode.isNotEmpty) {
      _adManager.loadAd(
        userId: adUserId,
        episodeCode: widget.episodeCode,
        stageNo: widget.stageNo,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _answerController.dispose();
    _answerFocusNode.dispose();
    _wrongAnswerController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncDrawingBounds();
    });
  }

  Future<void> _showHintDialog(String hint) async {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (dialogContext) {
        final maxHeight = MediaQuery.sizeOf(dialogContext).height * 0.72;

        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            'HINT',
            style: TextStyle(
              fontFamily: AppFonts.title,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.crust,
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Text(
                hint,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: SoundEffectsService().withSelect(
                () => Navigator.of(dialogContext).pop(),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pumpkin,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAndShowHint(QuizViewModel vm) async {
    final hint = await vm.loadHint(
      episodeId: widget.episodeId,
      stageNo: widget.stageNo,
    );

    if (!mounted) return;

    if (hint != null) {
      await _showHintDialog(hint.content);
    }
  }

  Future<_HintAccessAction?> _showHintAccessDialog() {
    return showDialog<_HintAccessAction>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) => const _HintAccessDialog(),
    );
  }

  Future<void> _handleHintPressed(QuizViewModel vm) async {
    final purchaseViewModel = Provider.of<PurchaseViewModel>(
      context,
      listen: false,
    );
    if (purchaseViewModel.skipsHintAds) {
      await _loadAndShowHint(vm);
      return;
    }

    final action = await _showHintAccessDialog();
    if (!mounted || action == null) return;

    if (action == _HintAccessAction.premium) {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => const PremiumPurchaseDialog(),
      );
      return;
    }

    final didShowAd = await _adManager.showAdWhenReady(
      onRewardEarned: () async {
        final hasHintAccess = await vm.waitForHintAccess(
          episodeId: widget.episodeId,
          stageNo: widget.stageNo,
          attempts: 8,
          delay: const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        if (!hasHintAccess) {
          return;
        }

        await _loadAndShowHint(vm);
      },
    );

    if (!didShowAd && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('광고를 준비 중입니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _submitAnswer(QuizViewModel vm) async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    final result = await vm.submitAnswer(
      episodeId: widget.episodeId,
      stageNo: widget.stageNo,
      answer: answer,
    );
    if (!mounted || result == null) return;

    _answerController.clear();

    if (!result.isCorrect) {
      await SoundEffectsService().playWrong();
      await _triggerWrongAnswerFeedback();
      return;
    }

    await SoundEffectsService().playCorrect();
    final progress = await vm.completeStage(
      episodeId: widget.episodeId,
      stageNo: widget.stageNo,
    );
    if (!mounted || progress == null) return;

    final next = progress.nextStageNo;
    if (next != null) {
      await _goToStage(stageNo: next);
    }
  }

  Future<void> _triggerWrongAnswerFeedback() async {
    if (_showWrongAnswer) return;

    setState(() => _showWrongAnswer = true);
    _wrongAnswerController.repeat();

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    _wrongAnswerController
      ..stop()
      ..reset();
    setState(() => _showWrongAnswer = false);
  }

  void _reloadStage(QuizViewModel vm) {
    vm.loadStage(episodeId: widget.episodeId, stageNo: widget.stageNo);
  }

  void _syncDrawingBounds() {
    final stackContext = _stackKey.currentContext;
    final imageContext = _imageAreaKey.currentContext;
    if (stackContext == null || imageContext == null) return;

    final stackBox = stackContext.findRenderObject() as RenderBox?;
    final imageBox = imageContext.findRenderObject() as RenderBox?;
    if (stackBox == null || imageBox == null || !imageBox.hasSize) {
      return;
    }

    final transform = imageBox.getTransformTo(stackBox);
    final nextBounds = MatrixUtils.transformRect(
      transform,
      Offset.zero & imageBox.size,
    );
    final nextStrokeScale = imageBox.size.width == 0
        ? 1.0
        : (nextBounds.width / imageBox.size.width).clamp(0.1, 1.0);
    if (_drawingBounds == nextBounds &&
        _drawingStrokeScale == nextStrokeScale) {
      return;
    }
    setState(() {
      _drawingBounds = nextBounds;
      _drawingStrokeScale = nextStrokeScale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goToStageSelect();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          key: _stackKey,
          children: [
            const RetroBackground(),
            SafeArea(
              child: Consumer<QuizViewModel>(
                builder: (context, vm, _) {
                  final removesAds = context
                      .watch<PurchaseViewModel>()
                      .removesAds;
                  final isKeyboardOpen =
                      MediaQuery.viewInsetsOf(context).bottom > 0;
                  final showBanner = !removesAds && !isKeyboardOpen;
                  // Consumer ?대??먯꽌 ??踰덈쭔 loadStage ?몄텧
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
                  if (stage != null && !vm.isLoadingStage) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _syncDrawingBounds();
                    });
                  }

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      showBanner ? BannerAdBox.height + 8 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _QuizTopBar(
                          drawingController: _drawingController,
                          isLoadingHint: vm.isLoadingHint,
                          onHint: () => _handleHintPressed(vm),
                          onHome: () => Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst),
                        ),
                        const SizedBox(height: 55),
                        Expanded(
                          child: vm.isLoadingStage
                              ? const _QuizLoadingView()
                              : stage == null
                              ? _QuizErrorView(
                                  message: vm.errorMessage,
                                  onRetry: () => _reloadStage(vm),
                                )
                              : _QuizStageBody(
                                  stage: stage,
                                  questionAreaKey: _questionAreaKey,
                                  imageAreaKey: _imageAreaKey,
                                  errorMessage: vm.errorMessage,
                                  answerController: _answerController,
                                  answerFocusNode: _answerFocusNode,
                                  wrongAnswerAnimation: _wrongAnswerController,
                                  showWrongAnswer: _showWrongAnswer,
                                  isSubmitting: vm.isSubmitting,
                                  onRefresh: () => _reloadStage(vm),
                                  onSubmit: () => _submitAnswer(vm),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showWrongAnswer ? 1 : 0,
                  duration: const Duration(milliseconds: 80),
                  child: ColoredBox(
                    color: const Color(0xFF841D22).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            DrawingBoard(
              controller: _drawingController,
              showFloatingButton: false,
              topInset: 72,
              drawingBounds: _drawingBounds,
              strokeScale: _drawingStrokeScale,
            ),
            const _BottomBannerAd(),
          ],
        ),
      ),
    );
  }
}

class _QuizTopBar extends StatelessWidget {
  const _QuizTopBar({
    required this.drawingController,
    required this.isLoadingHint,
    required this.onHint,
    required this.onHome,
  });

  final DrawingBoardController drawingController;
  final bool isLoadingHint;
  final VoidCallback onHint;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.home_rounded,
            tooltip: '홈',
            onTap: onHome,
          ),
          const SizedBox(width: 10),
          const Spacer(),
          _HeaderIconButton(
            icon: Icons.lightbulb_outline_rounded,
            tooltip: '힌트',
            onTap: isLoadingHint ? null : onHint,
            isLoading: isLoadingHint,
          ),
          const SizedBox(width: 8),
          ListenableBuilder(
            listenable: drawingController,
            builder: (context, _) {
              return _HeaderIconButton(
                icon: drawingController.isActive
                    ? Icons.close_rounded
                    : Icons.brush_rounded,
                tooltip: drawingController.isActive ? '그리기 종료' : '그리기',
                onTap: drawingController.toggle,
              );
            },
          ),
          const SizedBox(width: 8),
          const SettingsButton(
            color: AppColors.textOnPumpkin,
            borderAlpha: 0.3,
          ),
        ],
      ),
    );
  }
}

enum _HintAccessAction { ad, premium }

class _HintAccessDialog extends StatelessWidget {
  const _HintAccessDialog();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD6A84F);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 320,
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassCardBackground),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55210F20),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 34),
                    const Expanded(
                      child: Text(
                        'HINT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.title,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.crust,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(8, 0),
                      child: IconButton(
                        onPressed: SoundEffectsService().withSelect(
                          () => Navigator.of(context).pop(),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: AppColors.crust,
                        tooltip: '닫기',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '광고를 보고 이번 스테이지의 힌트를 받거나, 프리미엄 패키지로 힌트 무제한 제공과 광고 제거를 함께 이용할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: SoundEffectsService().withSelect(
                      () => Navigator.of(context).pop(_HintAccessAction.ad),
                    ),
                    icon: const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 20,
                    ),
                    label: const Text('광고보고 힌트받기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crust,
                      foregroundColor: AppColors.textOnPumpkin,
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: SoundEffectsService().withSelect(
                      () =>
                          Navigator.of(context).pop(_HintAccessAction.premium),
                    ),
                    icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                    label: const Text('프리미엄 패키지 구매하기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: const BorderSide(color: gold, width: 1.4),
                      textStyle: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizStageBody extends StatelessWidget {
  const _QuizStageBody({
    required this.stage,
    required this.questionAreaKey,
    required this.imageAreaKey,
    required this.errorMessage,
    required this.answerController,
    required this.answerFocusNode,
    required this.wrongAnswerAnimation,
    required this.showWrongAnswer,
    required this.isSubmitting,
    required this.onRefresh,
    required this.onSubmit,
  });

  final StageInfoModel stage;
  final Key questionAreaKey;
  final Key imageAreaKey;
  final String? errorMessage;
  final TextEditingController answerController;
  final FocusNode answerFocusNode;
  final Animation<double> wrongAnswerAnimation;
  final bool showWrongAnswer;
  final bool isSubmitting;
  final VoidCallback onRefresh;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
        final availableHeight = constraints.maxHeight - keyboardHeight - 12;
        final estimatedContentHeight =
            constraints.maxWidth + (stage.nextStageNo == null ? 220 : 176);
        final contentHeight = math.min(availableHeight, constraints.maxHeight);
        final mainHeight = math.max(0.0, contentHeight);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: mainHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: estimatedContentHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [..._mainChildren(), ..._errorChildren()],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _mainChildren() {
    return [
      _QuestionTitle(stage: stage),
      const SizedBox(height: 25),
      _QuestionArea(
        key: questionAreaKey,
        imageKey: imageAreaKey,
        stage: stage,
        onRefresh: onRefresh,
      ),
      const SizedBox(height: 20),
      _AnswerDock(
        controller: answerController,
        focusNode: answerFocusNode,
        wrongAnswerAnimation: wrongAnswerAnimation,
        showWrongAnswer: showWrongAnswer,
        isSubmitting: isSubmitting,
        isLastStage: stage.nextStageNo == null,
        onSubmit: onSubmit,
      ),
    ];
  }

  List<Widget> _errorChildren() {
    if (errorMessage == null) return const [];
    return [const SizedBox(height: 8), _InlineError(message: errorMessage!)];
  }
}

class _QuestionArea extends StatelessWidget {
  const _QuestionArea({
    super.key,
    required this.imageKey,
    required this.stage,
    required this.onRefresh,
  });

  final Key imageKey;
  final StageInfoModel stage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: RetroGlassCard(
          width: null,
          padding: const EdgeInsets.all(14),
          borderColor: AppColors.glassCardBackground,
          child: QuizImage(
            key: imageKey,
            imageUrl: stage.imageUrl,
            onRefresh: onRefresh,
            showShadow: false,
            showBorder: false,
          ),
        ),
      ),
    );
  }
}

class _QuestionTitle extends StatelessWidget {
  const _QuestionTitle({required this.stage});

  final StageInfoModel stage;

  @override
  Widget build(BuildContext context) {
    final title = stage.title.trim();
    final text = title.isEmpty
        ? 'STAGE ${stage.stageNo}.'
        : 'STAGE ${stage.stageNo}. $title';

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 6),
      child: Text(
        text,
        textAlign: TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppFonts.title,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.textOnPumpkin.withValues(alpha: 0.92),
          height: 1.08,
        ),
      ),
    );
  }
}

class _BottomBannerAd extends StatelessWidget {
  const _BottomBannerAd();

  @override
  Widget build(BuildContext context) {
    final removesAds = context.watch<PurchaseViewModel>().removesAds;
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (removesAds || isKeyboardOpen) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Center(
          child: SizedBox(
            width: screenWidth,
            height: BannerAdBox.height,
            child: BannerAdBox(width: screenWidth),
          ),
        ),
      ),
    );
  }
}

class _AnswerDock extends StatelessWidget {
  const _AnswerDock({
    required this.controller,
    required this.focusNode,
    required this.wrongAnswerAnimation,
    required this.showWrongAnswer,
    required this.isSubmitting,
    required this.isLastStage,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> wrongAnswerAnimation;
  final bool showWrongAnswer;
  final bool isSubmitting;
  final bool isLastStage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final fieldColor = showWrongAnswer
        ? const Color(0xFFC44441)
        : AppColors.surface.withValues(alpha: 0.92);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: wrongAnswerAnimation,
          builder: (context, child) {
            final offset = showWrongAnswer
                ? math.sin(wrongAnswerAnimation.value * math.pi * 2) * 5
                : 0.0;

            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textOnPumpkin.withValues(alpha: 0.28),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        );
                      }),
                    ],
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: showWrongAnswer ? '오답입니다.' : '정답 입력',
                      hintStyle: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: showWrongAnswer
                            ? Colors.white
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textOnPumpkin.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: IconButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  tooltip: '제출',
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.textOnPumpkin,
                          ),
                        )
                      : const Icon(Icons.keyboard_return_rounded, size: 25),
                  color: AppColors.textOnPumpkin,
                  disabledColor: AppColors.textOnPumpkin.withValues(
                    alpha: 0.34,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLastStage) ...[
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: _LastStageBadge(),
          ),
        ],
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: SoundEffectsService().withSelect(onTap),
      tooltip: tooltip,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.textOnPumpkin,
              ),
            )
          : Icon(icon, size: 22),
      color: AppColors.textOnPumpkin,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: AppColors.textOnPumpkin.withValues(alpha: 0.3),
          width: 1.2,
        ),
        minimumSize: const Size(42, 42),
        shape: const CircleBorder(),
      ),
    );
  }
}

class _LastStageBadge extends StatelessWidget {
  const _LastStageBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.pumpkin.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.pumpkin.withValues(alpha: 0.38)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 16, color: AppColors.pumpkin),
          SizedBox(width: 6),
          Text(
            'LAST',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.pumpkin,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizLoadingView extends StatelessWidget {
  const _QuizLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.pumpkin),
    );
  }
}

class _QuizErrorView extends StatelessWidget {
  const _QuizErrorView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RetroGlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.refresh_rounded, color: AppColors.crust, size: 34),
            const SizedBox(height: 12),
            const Text(
              '스테이지를 불러오지 못했습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              _InlineError(message: message!),
            ],
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: SoundEffectsService().withSelect(onRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pumpkin,
                foregroundColor: AppColors.textOnPumpkin,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'RETRY',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.red.shade300,
        height: 1.35,
      ),
    );
  }
}
