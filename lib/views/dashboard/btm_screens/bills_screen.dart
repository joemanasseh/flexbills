import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BillsPaymentPage extends StatelessWidget {
  final List<Map<String, dynamic>> billCategories = [
    {'title': 'Electricity', 'icon': Icons.bolt},
    {'title': 'E-Commerce', 'icon': Icons.shopping_cart},
    {'title': 'Mobile & Data', 'icon': Icons.phone_iphone},
    {'title': 'Transportation', 'icon': Icons.directions_bus},
    {'title': 'TV & Internet', 'icon': Icons.tv},
    {'title': 'Pharmacy', 'icon': Icons.local_pharmacy},
    {'title': 'Tickets', 'icon': Icons.confirmation_number},
    {'title': 'Hotel', 'icon': Icons.hotel},
    {'title': 'Flight', 'icon': Icons.flight},
    {'title': 'Fuel', 'icon': Icons.local_gas_station},
    {'title': 'Food & Drink', 'icon': Icons.fastfood},
  ];

  // Removed const from the constructor
  BillsPaymentPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills Payment'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 items per row
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: billCategories.length,
                itemBuilder: (context, index) {
                  return _buildBillCategoryItem(
                    billCategories[index]['title']!,
                    billCategories[index]['icon']!,
                  );
                },
              ),
            ),
            // You can add a section for "My Cards" below the grid view
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'My Cards',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCategoryItem(String title, IconData iconData) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(
            iconData,
            size: 40.w,
            color: Colors.green, // Set the icon color to green
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
