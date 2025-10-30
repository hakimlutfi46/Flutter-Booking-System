import 'package:flutter/material.dart';
import 'package:flutter_booking_system/presentation/parent_features/my_bookings/controllers/my_bookings.controller.dart';

class BookingTabBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(BookingStatusFilter) onChanged;

  const BookingTabBar({super.key, required this.onChanged});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      onTap: (index) => onChanged(BookingStatusFilter.values[index]),
      tabs: const [
        Tab(icon: Icon(Icons.upcoming_outlined), text: 'Upcoming'),
        Tab(icon: Icon(Icons.history_outlined), text: 'Past'),
        Tab(icon: Icon(Icons.cancel_outlined), text: 'Cancelled'),
      ],
    );
  }
}
