import 'package:askence/theme/colors.dart';
import 'package:askence/widgets/side_bar_button.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = true;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: isCollapsed ? 64 : 150,
      color: AppColors.sideNav,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.auto_awesome_mosaic_rounded,
            color: AppColors.iconGrey,
            size: isCollapsed ? 30 : 60,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: isCollapsed
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: Icons.add,
                  text: "Home",
                ),
                SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: Icons.search,
                  text: "Search",
                ),
                SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: Icons.language,
                  text: "Spaces",
                ),
                SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: Icons.auto_awesome,
                  text: "Discover",
                ),
                SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: Icons.cloud_outlined,
                  text: "Library",
                ),

                const Spacer(),

                const SizedBox(height: 16),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isCollapsed = !isCollapsed;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              margin: EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                isCollapsed
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
                color: AppColors.iconGrey,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
