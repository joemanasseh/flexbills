import 'package:adescrow_app/utils/basic_screen_imports.dart';

class BreadcrumbBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> crumbs;

  const BreadcrumbBar({super.key, required this.crumbs});

  @override
  Size get preferredSize => const Size.fromHeight(26.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return SizedBox(
      height: 26.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * 0.8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < crumbs.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 13,
                    color: baseColor.withOpacity(0.3),
                  ),
                ),
              Text(
                crumbs[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: i == crumbs.length - 1
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: i == crumbs.length - 1
                      ? Theme.of(context).primaryColor
                      : baseColor.withOpacity(0.45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
