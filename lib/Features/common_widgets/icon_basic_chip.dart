import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class IconBasicChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const IconBasicChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: getTextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
