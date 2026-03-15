import 'dart:ui';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double? height;
  final double? width;
  final List<Color>? gradientColors;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height,
    this.width,
    this.gradientColors,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading || widget.onPressed == null;
    final baseColor = widget.backgroundColor ?? const Color(0xFF7FB6DE);
    final defaultGradient = widget.gradientColors ??
        const [
          Color(0xCC8FD8F4),
          Color(0xCCBCA3F2),
        ];
    final effectiveTextColor = widget.textColor ??
        (widget.isOutlined
            ? (widget.backgroundColor ?? AppColors.primary)
            : (widget.backgroundColor == null ? AppColors.textMainLight : Colors.white));

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: disabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: Container(
              width: widget.width,
              height: widget.height ?? 50,
              decoration: BoxDecoration(
                gradient: widget.isOutlined
                    ? LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.32),
                          Colors.white.withValues(alpha: 0.18),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.backgroundColor == null
                            ? defaultGradient
                            : [
                                baseColor.withValues(alpha: 0.9),
                                baseColor.withValues(alpha: 0.75),
                              ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isOutlined
                      ? (widget.backgroundColor ?? AppColors.primary).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.24),
                  width: 1.2,
                ),
                boxShadow: disabled
                    ? []
                    : [
                        BoxShadow(
                          color: baseColor.withValues(alpha: 0.22),
                          offset: const Offset(0, 6),
                          blurRadius: 14,
                          spreadRadius: -6,
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: _buildChild(context, effectiveTextColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context, Color textColor) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          height: 1,
        );

    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: textColor, size: 20),
            child: widget.icon!,
          ),
          const SizedBox(width: 8),
          Text(widget.text, style: textStyle),
        ],
      );
    }

    return Text(widget.text, style: textStyle);
  }
}
