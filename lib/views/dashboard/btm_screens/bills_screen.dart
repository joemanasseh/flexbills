import 'package:adescrow_app/controller/dashboard/bills/bills_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/basic_screen_imports.dart';

class BillsScreen extends GetView<BillsController> {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = isDark
        ? CustomColor.primaryDarkScaffoldBackgroundColor
        : CustomColor.primaryLightScaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: Obx(() {
                final query = controller.searchQuery.value.toLowerCase();
                final filtered = _allCategories
                    .where((c) => c.title.toLowerCase().contains(query))
                    .toList();
                final quickPay =
                    query.isEmpty ? _quickPayCategories : <_BillCategory>[];

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      bottom: Dimensions.paddingSizeVertical * 2),
                  children: [
                    if (quickPay.isNotEmpty) ...[
                      SizedBox(height: Dimensions.marginSizeVertical),
                      _buildSectionTitle('Quick Pay', context, isDark),
                      SizedBox(height: Dimensions.marginSizeVertical * 0.7),
                      _buildQuickPay(context, isDark, quickPay),
                      SizedBox(height: Dimensions.marginSizeVertical * 1.2),
                      _buildSectionTitle('All Categories', context, isDark),
                      SizedBox(height: Dimensions.marginSizeVertical * 0.7),
                    ] else ...[
                      SizedBox(height: Dimensions.marginSizeVertical),
                      _buildSectionTitle(
                          '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                          context,
                          isDark),
                      SizedBox(height: Dimensions.marginSizeVertical * 0.7),
                    ],
                    _buildCategoryGrid(context, isDark, filtered),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    return Container(
      padding: EdgeInsets.only(
        top: Dimensions.paddingSizeVertical * 0.75,
        left: Dimensions.paddingSizeHorizontal,
        right: Dimensions.paddingSizeHorizontal,
        bottom: Dimensions.paddingSizeVertical * 1.5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  CustomColor.primaryDarkColor.withOpacity(0.15),
                  CustomColor.secondaryDarkColor,
                ]
              : [
                  CustomColor.primaryLightColor.withOpacity(0.08),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimensions.radius * 3),
          bottomRight: Radius.circular(Dimensions.radius * 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay Bills',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize1,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 0.3),
          Text(
            'Fast, secure & instant bill payments',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize5,
              color: textColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 1.2),
          Container(
            height: 46,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeHorizontal * 0.7),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 20, color: textColor.withOpacity(0.4)),
                SizedBox(width: Dimensions.marginSizeHorizontal * 0.4),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize4,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search bills...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: Dimensions.headingTextSize4,
                        color: textColor.withOpacity(0.35),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Obx(() => controller.searchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.searchController.clear();
                          controller.onSearchChanged('');
                        },
                        child: Icon(Icons.close_rounded,
                            size: 18, color: textColor.withOpacity(0.4)),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, BuildContext context, bool isDark) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeHorizontal),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: Dimensions.headingTextSize3,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuickPay(
      BuildContext context, bool isDark, List<_BillCategory> items) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeHorizontal),
      child: Row(
        children: items
            .asMap()
            .entries
            .map((e) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: e.key < items.length - 1
                          ? Dimensions.paddingSizeHorizontal * 0.4
                          : 0,
                    ),
                    child: _buildQuickItem(context, e.value, isDark, e.key),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuickItem(
      BuildContext context, _BillCategory item, bool isDark, int index) {
    return InkWell(
      onTap: () => controller.openCategory(item.type, item.title),
      borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeVertical * 0.6),
        decoration: BoxDecoration(
          color: item.color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
          border: Border.all(color: item.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color, size: 26),
            SizedBox(height: Dimensions.marginSizeVertical * 0.3),
            Text(
              item.title,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize6,
                fontWeight: FontWeight.w600,
                color: item.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildCategoryGrid(
      BuildContext context, bool isDark, List<_BillCategory> categories) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    if (categories.isEmpty) {
      return Padding(
        padding:
            EdgeInsets.only(top: Dimensions.paddingSizeVertical * 2),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: textColor.withOpacity(0.2)),
              SizedBox(height: Dimensions.marginSizeVertical * 0.6),
              Text(
                'No categories found',
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize4,
                  color: textColor.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeHorizontal),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: Dimensions.marginSizeHorizontal * 0.5,
          mainAxisSpacing: Dimensions.marginSizeVertical * 0.5,
          childAspectRatio: 0.9,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) =>
            _buildCategoryCard(context, categories[index], isDark, index),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, _BillCategory item, bool isDark, int index) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return InkWell(
      onTap: () => controller.openCategory(item.type, item.title),
      borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
      child: Container(
        padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal * 0.55),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.12),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withOpacity(isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.35),
            Text(
              item.title,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize6,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: (index * 40).ms,
        );
  }
}

// ─────────────────────────── Local models ─────────────────────────────────────

class _BillCategory {
  final String title;
  final IconData icon;
  final Color color;
  final String type;
  const _BillCategory(this.title, this.icon, this.color, this.type);
}

const _quickPayCategories = [
  _BillCategory('Airtime', Icons.phone_android_rounded,
      CustomColor.greenColor, 'AIRTIME'),
  _BillCategory(
      'Data', Icons.wifi_rounded, CustomColor.primaryLightColor, 'DATA'),
  _BillCategory('Electricity', Icons.bolt_rounded,
      CustomColor.yellowColor, 'ELECTRICITY'),
  _BillCategory(
      'Cable TV', Icons.tv_rounded, CustomColor.thirdColor, 'CABLE-TV'),
];

const _allCategories = [
  _BillCategory('Airtime', Icons.phone_android_rounded,
      CustomColor.greenColor, 'AIRTIME'),
  _BillCategory(
      'Data', Icons.wifi_rounded, CustomColor.primaryLightColor, 'DATA'),
  _BillCategory('Electricity', Icons.bolt_rounded,
      CustomColor.yellowColor, 'ELECTRICITY'),
  _BillCategory(
      'Cable TV', Icons.tv_rounded, CustomColor.thirdColor, 'CABLE-TV'),
  _BillCategory(
      'Internet', Icons.router_rounded, CustomColor.blueColor, 'INTERNET'),
  _BillCategory(
      'Water', Icons.water_drop_rounded, Color(0xFF06B6D4), 'WATER'),
  _BillCategory('Fuel', Icons.local_gas_station_rounded,
      CustomColor.orangeColor, 'FUEL'),
  _BillCategory(
      'Education', Icons.school_rounded, Color(0xFF8B5CF6), 'EDUCATION'),
  _BillCategory('Transport', Icons.directions_bus_rounded,
      Color(0xFF10B981), 'TRANSPORT'),
  _BillCategory(
      'Insurance', Icons.shield_rounded, CustomColor.redColor, 'INSURANCE'),
  _BillCategory('Healthcare', Icons.local_hospital_rounded,
      Color(0xFFEC4899), 'HEALTHCARE'),
  _BillCategory(
      'Hotels', Icons.hotel_rounded, Color(0xFF6366F1), 'HOTELS'),
  _BillCategory(
      'Travel', Icons.flight_rounded, Color(0xFF0EA5E9), 'TRAVEL'),
  _BillCategory('Others', Icons.more_horiz_rounded,
      CustomColor.primaryLightTextColor, 'OTHERS'),
];
