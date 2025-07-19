import 'package:askence/theme/colors.dart';
import 'package:flutter/material.dart';

class SideBarButton extends StatelessWidget {
  final bool isCollapsed;
  final IconData icon;
  final String text;
  const SideBarButton({
    super.key,
    required this.isCollapsed,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCollapsed
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Icon(icon, color: AppColors.iconGrey, size: 24),
        ),
        isCollapsed
            ? SizedBox()
            : Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textGrey,
                ),
              ),
      ],
    );
  }
}
