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
    return ChangeNotifierProvider(
      create: (_) => MealViewModel(),
      child: Consumer2<AuthViewModel, MealViewModel>(
        builder: (context, authViewModel, mealViewModel, _) {
          if (authViewModel.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Meal Calendar',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  mealViewModel.loadUserMeals(
                                    authViewModel.currentUser!.id,
                                    _focusedDay,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
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
                              // Load meals for the new month
                              mealViewModel.loadUserMeals(
                                authViewModel.currentUser!.id,
                                focusedDay,
                              );
                            },
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                final isActive = mealViewModel.getMealStatus(date);
                                return Positioned(
                                  bottom: 1,
                                  child: Container(
                                    width: 40,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.green : Colors.red,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isActive ? 'ON' : 'OFF',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Meal for ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('ON'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mealViewModel.getMealStatus(_selectedDay)
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  mealViewModel.toggleMealStatus(
                                    authViewModel.currentUser!.id,
                                    _selectedDay,
                                    true,
                                  );
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.cancel),
                                label: const Text('OFF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !mealViewModel.getMealStatus(_selectedDay)
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  mealViewModel.toggleMealStatus(
                                    authViewModel.currentUser!.id,
                                    _selectedDay,
                                    false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}