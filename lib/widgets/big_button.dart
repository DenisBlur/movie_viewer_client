import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  const BigButton({super.key, required this.onTap, required this.title, required this.icon, this.w = 250, this.h = 250, this.iconSize = 36, this.enable = true});

  final VoidCallback onTap;
  final String title;
  final IconData icon;

  final bool? enable;
  final double? w;
  final double? h;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: null,
      borderRadius: BorderRadius.circular(16),
      onTap: enable! ? onTap : null,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}
