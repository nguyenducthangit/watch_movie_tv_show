import 'package:flutter/material.dart';
import 'package:watch_movie_tv_show/app/config/theme/app_colors.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Bắt sự kiện chạm cả vùng trống
      child: Container(
        // Dùng Container trong suốt để giữ kích thước cố định, tránh layout bị nhảy
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: isSelected
                  ? Curves.easeOutBack
                  : Curves.easeOut, // Fix crash: easeOutBack gây overshoot âm cho shadow
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                shape: BoxShape.circle,
                // Hiệu ứng phát sáng nhẹ (Glow) khi chọn
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                // Khi chọn thì icon to hơn 1 chút
                size: isSelected ? 26 : 24,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            // 2. Text nằm dưới, không đẩy ngang
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11, // Font nhỏ tinh tế
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
