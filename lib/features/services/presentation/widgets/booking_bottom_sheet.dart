import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/features/services/data/booking_repository.dart';
import 'package:sampatti_bazar/features/services/domain/booking_model.dart';
import 'package:uuid/uuid.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class BookingBottomSheet extends StatefulWidget {
  final PropertyModel property;
  final String buyerId;

  const BookingBottomSheet({
    super.key,
    required this.property,
    required this.buyerId,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  final List<TimeOfDay> _timeSlots = [
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
    const TimeOfDay(hour: 17, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _syncToCalendar(DateTime bookingDateTime) {
    final Event event = Event(
      title: 'Site Visit: ${widget.property.title}',
      description: 'Site visit for property located at ${widget.property.location}',
      location: widget.property.location,
      startDate: bookingDateTime,
      endDate: bookingDateTime.add(const Duration(hours: 1)),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.sp)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule Site Visit',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: context.primaryTextColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: AppTheme.primaryBlue),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Available Time Slots',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: context.primaryTextColor,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 45.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final time = _timeSlots[index];
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : context.cardColor,
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : context.borderColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      time.format(context),
                      style: TextStyle(
                        color: isSelected ? Colors.white : context.primaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 32.h),
          Consumer(
            builder: (context, ref, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedDay == null || _selectedTime == null || _isSubmitting)
                      ? null
                      : () async {
                          setState(() => _isSubmitting = true);
                          try {
                            final bookingDateTime = DateTime(
                              _selectedDay!.year,
                              _selectedDay!.month,
                              _selectedDay!.day,
                              _selectedTime!.hour,
                              _selectedTime!.minute,
                            );

                            final booking = BookingModel(
                              id: const Uuid().v4(),
                              propertyId: widget.property.id,
                              propertyTitle: widget.property.title,
                              propertyLocation: widget.property.location,
                              propertyImageUrl: widget.property.imageUrls.isNotEmpty ? widget.property.imageUrls[0] : null,
                              buyerId: widget.buyerId,
                              ownerId: widget.property.ownerId,
                              bookingDate: bookingDateTime,
                              status: 'pending',
                              createdAt: DateTime.now(),
                            );

                            await ref.read(bookingRepositoryProvider).addBooking(booking);
                            
                            _syncToCalendar(bookingDateTime);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Site visit requested successfully!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
