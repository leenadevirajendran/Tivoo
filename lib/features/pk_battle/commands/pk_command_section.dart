// Command section: Command List, input bar and the lower panel.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';
import '../../live_stream/presentation/widgets/purchase_stars_sheet.dart';

/// Full-width bottom area on one background that runs to the screen edge:
///   [Command List ...............] [Gift card | ♥ Like | ↪ Share]
///   [😊] [Type a message...] [•••]
class PkLowerSection extends StatelessWidget {
  final Widget commandList;
  final Widget rightColumn;
  final Widget inputBar;

  const PkLowerSection({super.key, required this.commandList, required this.rightColumn, required this.inputBar});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;
    final systemPaddingBottom = mediaQuery.padding.bottom;
    final isKeyboardOpen = viewInsetsBottom > 50;
    final effectiveBottom = isKeyboardOpen ? 6.0 : (systemPaddingBottom + 8.0);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutQuad,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(10, 8, 10, effectiveBottom),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF0171340), LuxeColors.bg, LuxeColors.bgBottom],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: const Color(0x77FFC928)),
          boxShadow: const [
            BoxShadow(color: Color(0x447B4DFF), blurRadius: 24, offset: Offset(0, -4)),
            BoxShadow(color: Color(0x22FFC928), blurRadius: 12, offset: Offset(0, -2)),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final rightWidth = (constraints.maxWidth * 0.27).clamp(92.0, 130.0);
            final hasEnoughHeight = constraints.maxHeight > 90;
            return Column(
              children: [
                if (hasEnoughHeight)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: commandList),
                        const SizedBox(width: 8),
                        SizedBox(width: rightWidth, child: rightColumn),
                      ],
                    ),
                  ),
                if (hasEnoughHeight) const SizedBox(height: 8),
                inputBar,
              ],
            );
          },
        ),
      ),
    );
  }
}

class PkCommandList extends StatelessWidget {
  final List<LiveComment> comments;
  final ScrollController controller;
  final VoidCallback onLiveTap;
  final ValueChanged<LiveComment>? onUserTap;

  const PkCommandList({
    super.key,
    required this.comments,
    required this.controller,
    required this.onLiveTap,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return PkNeonBox(
      radius: 22,
      borderColors: LuxeColors.goldToNeon,
      glow: const Color(0x337B4DFF),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  const PkGradientIcon(
                    Icons.sms_outlined,
                    size: 22,
                    colors: [LuxeColors.goldLight, LuxeColors.goldDeep],
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Comment List',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _LivePill(onTap: onLiveTap),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: ListView.separated(
                controller: controller,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                itemCount: comments.length,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                ),
                itemBuilder: (_, index) => _CommandRow(
                  comment: comments[comments.length - 1 - index],
                  onUserTap: onUserTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  final VoidCallback onTap;
  const _LivePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        decoration: BoxDecoration(
          color: LuxeColors.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2EE59D),
                boxShadow: [BoxShadow(color: Color(0xAA2EE59D), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Live',
              style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  final LiveComment comment;
  final ValueChanged<LiveComment>? onUserTap;
  const _CommandRow({required this.comment, this.onUserTap});

  static final DateFormat _time = DateFormat('hh:mm a');
  static const _ringColors = [LuxeColors.gold, LuxeColors.violet, LuxeColors.blue, LuxeColors.pink];

  bool get _isGift => comment.type == LiveCommentType.gift || comment.message.startsWith('sent ');
  bool get _isVip => PkDemoData.vipNames.contains(comment.userName);

  @override
  Widget build(BuildContext context) {
    final ring = _ringColors[comment.userName.codeUnits.fold<int>(0, (a, b) => a + b) % _ringColors.length];
    final messageColor = _isGift ? LuxeColors.gold : const Color(0xFFEDE7F6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onUserTap?.call(comment),
            child: Container(
              padding: const EdgeInsets.all(1.8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring, width: 1.8),
                boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.45), blurRadius: 8)],
              ),
              child: CustomAvatar(radius: 15, assetPath: comment.userAssetPath ?? AppAssets.status4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onUserTap?.call(comment),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_isVip) ...[const SizedBox(width: 5), const PkGoldCrown(size: 13)],
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: messageColor, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _time.format(comment.timestamp),
              style: const TextStyle(color: LuxeColors.textDim, fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive inline input bar: [😊] [TextField: Type a message... -> Send] [Wallet]
class PkInputBar extends StatefulWidget {
  final VoidCallback onEmojiTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onWalletTap;
  final ValueChanged<String>? onSend;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const PkInputBar({
    super.key,
    required this.onEmojiTap,
    this.onMessageTap,
    this.onMoreTap,
    this.onWalletTap,
    this.onSend,
    this.controller,
    this.focusNode,
  });

  @override
  State<PkInputBar> createState() => _PkInputBarState();
}

class _PkInputBarState extends State<PkInputBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PkNeonBox(
      radius: 32,
      borderColors: LuxeColors.goldToNeon,
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final circle = (constraints.maxWidth / 8.2).clamp(36.0, 46.0);
          return Row(
            children: [
              PkPanelCircle(
                size: circle,
                accent: LuxeColors.gold,
                onTap: widget.onEmojiTap,
                label: 'Emoji',
                child: Icon(Icons.sentiment_satisfied_alt_rounded, color: LuxeColors.gold, size: circle * 0.62),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: circle,
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E0B2C),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: _hasText ? LuxeColors.gold : LuxeColors.purple.withValues(alpha: 0.55),
                      width: _hasText ? 1.4 : 1.0,
                    ),
                    boxShadow: _hasText
                        ? [
                            BoxShadow(
                              color: LuxeColors.gold.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          cursorColor: LuxeColors.gold,
                          cursorWidth: 2.2,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: Color(0xFF9E9EAF),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _hasText
                            ? GestureDetector(
                                onTap: _send,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [LuxeColors.gold, Color(0xFFFFA000)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x66FFD600),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.black, size: 16),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PkPanelCircle(
                size: circle,
                accent: const Color(0xFFFFB800),
                onTap: widget.onWalletTap ?? () => PurchaseStarsSheet.show(context),
                onLongPress: widget.onMoreTap,
                label: 'Wallet',
                child: Padding(
                  padding: EdgeInsets.all(circle * 0.12),
                  child: Image.asset(
                    'assets/stars/wallet.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFFFFD700), size: circle * 0.55),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
