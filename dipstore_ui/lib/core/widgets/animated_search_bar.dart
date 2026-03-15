import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';
import 'package:dipstore_ui/core/services/store_service.dart';

class AnimatedSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final TextEditingController? controller;

  const AnimatedSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.controller,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isHovered = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasOwnController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _hasOwnController = true;
    }
  }

  @override
  void didUpdateWidget(AnimatedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (widget.controller != null) {
        if (_hasOwnController) {
          _controller.dispose();
          _hasOwnController = false;
        }
        _controller = widget.controller!;
      } else {
        _controller = TextEditingController();
        _hasOwnController = true;
      }
    }
  }

  @override
  void dispose() {
    if (_hasOwnController) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // ignore: deprecated_member_use
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 54,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20), // More rounded
            border: _isHovered
                // ignore: deprecated_member_use
                ? Border.all(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  )
                : null, // No border by default for cleaner look
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    // ignore: deprecated_member_use
                    ? AppColors.primary.withOpacity(0.08)
                    // ignore: deprecated_member_use
                    : Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(
                    color: AppColors.textMainLight, // Explicitly dark text
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? "Find businesses...",
                    hintStyle: TextStyle(
                      color: AppColors.textSubLight, // Explicit grey for hint
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      context.read<StoreService>().addRecentSearch(
                        value.trim(),
                      );
                    }
                    widget.onSubmitted?.call(value);
                  },
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                  },
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
