import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/widgets/card/booking_card.dart';
import 'package:flutter_booking_system/presentation/widgets/booking_tabbar.dart';
import 'package:flutter_booking_system/presentation/widgets/empty_bookings.dart';
import 'package:flutter_booking_system/presentation/widgets/loading_spinner.dart';
import 'package:get/get.dart';
import '../controllers/my_bookings.controller.dart';

class MyBookingsScreen extends GetView<MyBookingsController> {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 1,
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Get.theme.primaryColor,
                        Get.theme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'My Bookings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: BookingTabBar(onChanged: controller.changeTab),
            ),
          ],
          body: Obx(() {
            if (controller.isLoading.value) return const LoadingSpinner();

            return TabBarView(
              children: BookingStatusFilter.values.map((filter) {
                final bookings = controller.getBookingsByFilter(filter);
                if (bookings.isEmpty) {
                  return EmptyBookings(status: filter);
                }
              return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: bookings.length,
                  itemBuilder: (_, i) {
                    final booking = bookings[i];
                    return BookingCard(
                      booking: booking,
                      isUpcoming: filter == BookingStatusFilter.upcoming,
                      controller: controller,
                    );
                  },
                );
              }).toList(),
            );
          }),
        ),
      ),
    );
  }
}
