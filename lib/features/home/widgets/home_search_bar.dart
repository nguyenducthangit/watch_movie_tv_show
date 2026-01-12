import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';
import 'package:watch_movie_tv_show/app/config/theme/m_text_theme.dart';
import 'package:watch_movie_tv_show/app/constants/app_strings.dart';

/// Home Search Bar Widget
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key, this.onChanged, this.onClear});
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: MTextTheme.body2Regular.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: MTextTheme.body2Regular.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              onPressed: _onClear,
              icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 20),
              splashRadius: 20,
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}
