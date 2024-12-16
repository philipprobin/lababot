import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsPressed;

  const CustomAppBar({
    this.onSettingsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SVG Banner (flexible size)
            SvgPicture.asset(
              'assets/vector/banner.svg',
              width: 150, // Adjust banner width
              colorFilter: const ColorFilter.mode(
                Color(0xFF102E44), // Icon color
                BlendMode.srcIn,
              ),
              semanticsLabel: 'App Bar Icon',
            ),
            // Settings Icon
              IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
              onPressed: onSettingsPressed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0); // Adjust height as needed
}
