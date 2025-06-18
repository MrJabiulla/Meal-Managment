import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/meal_viewmodel.dart';

class MealCalendarView extends StatefulWidget {
  const MealCalendarView({Key? key}) : super(key: key);

  @override
  State<MealCalendarView> createState() => _MealCalendarViewState();
}

class _MealCalendarViewState extends State<MealCalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return ChangeNotifierProvider(
      create: (_) => MealViewModel(),
      child: Consumer2<AuthViewModel, MealViewModel>(
        builder: (context, authViewModel, mealViewModel, _) {
          if (authViewModel.currentUser == null) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            );
          }

          // Load meals when user is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mealViewModel.isLoading && mealViewModel.userMeals.isEmpty) {
              mealViewModel.loadUserMeals(
                authViewModel.currentUser!.id,
                _focusedDay,
              );
            }
          });

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor.withOpacity(0.95),
                    backgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Header section with glassmorphism
                  Container(
                    margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: Colors.white,
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.2),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.98),
                          Colors.white.withOpacity(0.92),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.50),
                          // blurRadius: 18,
                          // offset: const Offset(0, 8),
                        ),
                      ],
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meal Calendar',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: primaryColor.withOpacity(0.7),
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: const Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('MMMM yyyy').format(_focusedDay),
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Material(
                        //   color: Colors.white.withOpacity(0.18),
                        //   shape: const CircleBorder(),
                        //   elevation: 0,
                        //   child: IconButton(
                        //     icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 26),
                        //     onPressed: () {
                        //       mealViewModel.loadUserMeals(
                        //         authViewModel.currentUser!.id,
                        //         _focusedDay,
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  /// Calendar Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: primaryColor.withOpacity(0.22),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.withOpacity(0.98),
                                Colors.white.withOpacity(0.92),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              headerVisible: false,
                              daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                weekendStyle: TextStyle(
                                  color: primaryColor.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                markerSize: 8,
                                markersMaxCount: 3,
                              ),
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                });
                                mealViewModel.loadUserMeals(
                                  authViewModel.currentUser!.id,
                                  focusedDay,
                                );
                              },
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  final isActive = mealViewModel.getMealStatus(date);
                                  return Positioned(
                                    bottom: 2,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 42,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.green.shade600
                                            : Colors.redAccent.shade400,
                                        borderRadius: BorderRadius.circular(7),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isActive ? Colors.green : Colors.red).withOpacity(0.32),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          isActive ? 'ON' : 'OFF',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Selected Date Section
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: primaryColor.withOpacity(0.22),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.withOpacity(0.98),
                              Colors.white.withOpacity(0.92),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.13),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Meal Status',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check_circle_rounded),
                                        label: const Text('ON'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: mealViewModel.getMealStatus(_selectedDay)
                                              ? Colors.grey.shade400
                                              : Colors.green.shade600,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          elevation: mealViewModel.getMealStatus(_selectedDay) ? 7 : 2,
                                          shadowColor: Colors.green.withOpacity(0.5),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          mealViewModel.toggleMealStatus(
                                            authViewModel.currentUser!.id,
                                            _selectedDay,
                                            true,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.cancel_rounded),
                                        label: const Text('OFF'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: !mealViewModel.getMealStatus(_selectedDay)
                                              ? Colors.grey.shade400
                                              : Colors.redAccent.shade400,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          elevation: !mealViewModel.getMealStatus(_selectedDay) ? 7 : 2,
                                          shadowColor: Colors.red.withOpacity(0.5),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          mealViewModel.toggleMealStatus(
                                            authViewModel.currentUser!.id,
                                            _selectedDay,
                                            false,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}