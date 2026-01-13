import 'package:flutter/material.dart';

const Color _kGoldPrimary = Color(0xFFD4AF37);
const Color _kGoldGlow = Color(0xFFF8E79C);
const Color _kDarkBackground = Color(0xFF1E1E1E);

/// Expandable Search Bar
/// Transitions from a Search Icon to a full-width Search Input
class ExpandableSearchBar extends StatefulWidget {
  const ExpandableSearchBar({
    super.key,
    required this.isExpanded,
    required this.onExpand,
    required this.onCollapse,
    this.onChanged,
  });

  final bool isExpanded;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final ValueChanged<String>? onChanged;

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // Auto-focus when expanded
    if (widget.isExpanded) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(ExpandableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _focusNode.requestFocus();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _focusNode.unfocus();
      _controller.clear();
      widget.onChanged?.call('');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: widget.isExpanded ? MediaQuery.of(context).size.width - 40 : 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isExpanded ? _kDarkBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: widget.isExpanded
                  ? Border.all(color: _kGoldPrimary, width: 1.5)
                  : null, // No border when collapsed
              boxShadow: widget.isExpanded
                  ? [
                      BoxShadow(
                        color: _kGoldGlow.withValues(alpha: 0.3 * _glowAnimation.value),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: widget.isExpanded ? _buildExpandedView() : _buildCollapsedView(),
          ),
        );
      },
    );
  }

  /// Collapsed View: Just the Search Icon
  Widget _buildCollapsedView() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onExpand,
        borderRadius: BorderRadius.circular(30),
        child: const Center(child: Icon(Icons.search_rounded, color: Colors.white, size: 28)),
      ),
    );
  }

  /// Expanded View: Input Field + Close Button
  Widget _buildExpandedView() {
    return Row(
      children: [
        const SizedBox(width: 16),
        const Icon(Icons.search_rounded, color: _kGoldPrimary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            cursorColor: _kGoldPrimary,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: _kGoldPrimary.withValues(alpha: 0.5), fontSize: 16),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onCollapse,
          icon: const Icon(Icons.close, color: _kGoldPrimary, size: 22),
          splashRadius: 20,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
