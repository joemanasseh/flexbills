import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/currency_flag_util.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bindings/on_refresh.dart';
import '../../../controller/dashboard/btm_navs_controller/home_controller.dart';
import '../../../controller/dashboard/dashboard_controller.dart';
import '../../../routes/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  HomeController get controller => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _pageController.addListener(() {
      final page = (_pageController.page ?? 0).round();
      if (page != _currentPage) setState(() => _currentPage = page);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = isDark
        ? CustomColor.primaryDarkScaffoldBackgroundColor
        : CustomColor.primaryLightScaffoldBackgroundColor;

    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        backgroundColor: scaffoldColor,
        body: Obx(() {
          if (controller.isLoading) return const CustomLoadingWidget();
          if (controller.hasError || controller.homeModel == null) {
            return _buildErrorState(context, isDark);
          }
          return RefreshIndicator(
            backgroundColor: isDark
                ? CustomColor.primaryDarkColor
                : CustomColor.primaryLightColor,
            color: CustomColor.whiteColor,
            onRefresh: onRefresh,
            child: _buildContent(context, isDark),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 60, color: textColor.withOpacity(0.4)),
          SizedBox(height: Dimensions.marginSizeVertical),
          Text(
            'Could not load dashboard',
            style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize3,
                fontWeight: FontWeight.w600,
                color: textColor),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 0.5),
          TextButton(
            onPressed: controller.homeDataFetch,
            child: Text('Retry',
                style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize4,
                    color: CustomColor.primaryLightColor)),
          ),
        ],
      ),
    );
  }

  static const _displayCurrencies = ['USD', 'EUR', 'GBP', 'CHF'];

  Widget _buildContent(BuildContext context, bool isDark) {
    final wallets = controller.homeModel!.data.userWallet
        .where((w) => _displayCurrencies.contains(w.currencyCode))
        .toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: Dimensions.paddingSizeVertical * 2),
      children: [
        _buildBalanceSection(context, isDark, wallets),
        SizedBox(height: Dimensions.marginSizeVertical),
        _buildActionButtonsSection(context, isDark),
        SizedBox(height: Dimensions.marginSizeVertical),
        _buildTransactionsSection(context, isDark),
      ],
    );
  }

  Widget _buildBalanceSection(
      BuildContext context, bool isDark, List<dynamic> wallets) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: logo + notification
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                Dimensions.paddingSizeVertical * 0.5,
            left: Dimensions.paddingSizeHorizontal,
            right: Dimensions.paddingSizeHorizontal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => Text(
                    controller.firstname.value.isEmpty
                        ? 'FlexBills'
                        : controller.firstname.value,
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize2,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  )),
              Row(
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize5,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.55),
                    ),
                  ),
                  SizedBox(width: Dimensions.marginSizeHorizontal * 0.6),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.notificationScreen),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: textColor.withOpacity(0.7),
                      size: Dimensions.iconSizeLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: Dimensions.marginSizeVertical * 0.8),

        // Wallet cards
        SizedBox(
          height: 190,
          child: wallets.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: wallets.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      _buildBalanceCard(wallets[index], index, isDark),
                )
              : _buildNoWalletCard(isDark),
        ),

        // Page indicators
        if (wallets.length > 1)
          Padding(
            padding: EdgeInsets.only(top: Dimensions.marginSizeVertical * 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                wallets.length,
                (index) => GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: index == _currentPage ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: index == _currentPage
                          ? (isDark
                              ? CustomColor.primaryDarkColor
                              : CustomColor.primaryLightColor)
                          : (isDark
                              ? CustomColor.whiteColor.withOpacity(0.2)
                              : CustomColor.blackColor.withOpacity(0.15)),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard(dynamic wallet, int index, bool isDark) {
    final color =
        isDark ? CustomColor.primaryDarkColor : CustomColor.primaryLightColor;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * 0.5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * 0.9,
        vertical: Dimensions.paddingSizeVertical * 0.75,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  color.withOpacity(0.25),
                  CustomColor.secondaryDarkColor.withOpacity(0.9),
                ]
              : [
                  color.withOpacity(0.08),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Card header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wallet.currencyCode,
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize3,
                  fontWeight: FontWeight.w700,
                  color: textColor.withOpacity(0.9),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: color.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    flagUrl(wallet.currencyCode),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: color.withOpacity(0.15),
                      child: Icon(Icons.currency_exchange,
                          color: color, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize6,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${wallet.currencySymbol}${makeBalance(wallet.balance.toString(), wallet.currencyType == "FIAT" ? 2 : 6)}",
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize1,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Footer
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: Dimensions.headingTextSize5,
                color: textColor.withOpacity(0.4),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${wallet.name} · ${wallet.currencyCode}',
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize6,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms);
  }

  Widget _buildNoWalletCard(bool isDark) {
    final color =
        isDark ? CustomColor.primaryDarkColor : CustomColor.primaryLightColor;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeHorizontal),
      padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 40,
            color: textColor.withOpacity(0.35),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 0.4),
          Text(
            'No wallets available',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize4,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.6),
            ),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 0.25),
          Text(
            'Create a wallet to get started',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize6,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection(BuildContext context, bool isDark) {
    final color =
        isDark ? CustomColor.primaryDarkColor : CustomColor.primaryLightColor;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize3,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),

          SizedBox(height: Dimensions.marginSizeVertical * 0.7),

          Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeVertical * 0.75,
              horizontal: Dimensions.paddingSizeHorizontal * 0.25,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius * 2),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.withOpacity(0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.add_rounded,
                  label: "Add",
                  color: CustomColor.greenColor,
                  onTap: () {
                    final wallets = controller.homeModel?.data.userWallet;
                    if (wallets != null && wallets.isNotEmpty) {
                      Get.toNamed(Routes.addMoneyScreen,
                          arguments: wallets.first);
                    } else {
                      Get.snackbar('No Wallet', 'Please create a wallet first',
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                ),
                _buildActionButton(
                  icon: Icons.send_rounded,
                  label: "Send",
                  color: color,
                  onTap: () {
                    final wallets = controller.homeModel?.data.userWallet;
                    if (wallets != null && wallets.isNotEmpty) {
                      Get.toNamed(Routes.moneyOutScreen,
                          arguments: wallets.first);
                    } else {
                      Get.snackbar('No Wallet', 'Please create a wallet first',
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                ),
                _buildActionButton(
                  icon: Icons.swap_horiz_rounded,
                  label: "Convert",
                  color: CustomColor.thirdColor,
                  onTap: () => Get.toNamed(Routes.moneyExchangeScreen),
                ),
                _buildActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: "Bills",
                  color: CustomColor.orangeColor,
                  onTap: () => Get.find<DashboardController>().selectedIndex.value = 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius * 2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * 0.3,
          vertical: Dimensions.paddingSizeVertical * 0.3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border:
                    Border.all(color: color.withOpacity(0.18), width: 1.5),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.35),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize6,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context, bool isDark) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.grey.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHorizontal * 0.85,
              vertical: Dimensions.paddingSizeVertical * 0.75,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize3,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.transactionsScreen),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeHorizontal * 0.5,
                      vertical: Dimensions.paddingSizeVertical * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius:
                          BorderRadius.circular(Dimensions.radius * 2),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View all',
                          style: GoogleFonts.inter(
                            fontSize: Dimensions.headingTextSize6,
                            fontWeight: FontWeight.w600,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: textColor.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.1),
          ),

          _buildTransactionsList(context, isDark),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, bool isDark) {
    final transactions = controller.homeModel?.data.transactions ?? [];

    if (transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal,
          vertical: Dimensions.paddingSizeVertical * 1.5,
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.5),
            Text(
              'No transactions yet',
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize4,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.3),
            Text(
              'Your transactions will appear here',
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize5,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final count = transactions.length > 5 ? 5 : transactions.length;
    return Column(
      children: [
        for (int i = 0; i < count; i++) ...[
          _buildTransactionItem(transactions[i], i, isDark),
          if (i < count - 1)
            Divider(
              height: 1,
              indent: Dimensions.paddingSizeHorizontal * 0.85,
              endIndent: Dimensions.paddingSizeHorizontal * 0.85,
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.08),
            ),
        ],
      ],
    );
  }

  Widget _buildTransactionItem(
      dynamic transaction, int index, bool isDark) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    final accentColor = _getTransactionColor(transaction);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * 0.85,
        vertical: Dimensions.paddingSizeVertical * 0.6,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radius),
            ),
            child: Icon(
              _getTransactionIcon(transaction),
              color: accentColor,
              size: 20,
            ),
          ),

          SizedBox(width: Dimensions.marginSizeHorizontal * 0.6),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.transactionType.replaceAll('-', ' '),
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize4,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTransactionDate(transaction.createdAt.toString()),
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize6,
                    color: textColor.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${makeBalance(transaction.totalPayable)} ${transaction.senderCurrencyCode}',
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize4,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                '#${transaction.trxId}',
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize6,
                  color: textColor.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 60).ms);
  }

  // Helpers

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatTransactionDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateString;
    }
  }

  Color _getTransactionColor(dynamic transaction) {
    final type = (transaction.transactionType as String).toLowerCase();
    if (type.contains('out') || type.contains('withdraw')) {
      return CustomColor.redColor;
    } else if (type.contains('add') || type.contains('deposit')) {
      return CustomColor.greenColor;
    }
    return CustomColor.primaryLightColor;
  }

  IconData _getTransactionIcon(dynamic transaction) {
    final type = (transaction.transactionType as String).toLowerCase();
    if (type.contains('out') || type.contains('withdraw')) {
      return Icons.arrow_upward_rounded;
    } else if (type.contains('add') || type.contains('deposit')) {
      return Icons.arrow_downward_rounded;
    } else if (type.contains('bill')) {
      return Icons.receipt_long_rounded;
    }
    return Icons.swap_horiz_rounded;
  }

}
