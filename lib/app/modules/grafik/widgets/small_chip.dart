import 'package:flutter/material.dart';

class SmallChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const SmallChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? Colors.white : Colors.white.withOpacity(0.12);
    final textColor = selected ? Colors.black87 : Colors.white;
    final iconColor = selected ? Colors.black87 : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
