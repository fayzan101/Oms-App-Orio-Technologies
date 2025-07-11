import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CustomDateSelector extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const CustomDateSelector({
    Key? key,
    required this.initialStartDate,
    required this.initialEndDate,
  }) : super(key: key);

  @override
  State<CustomDateSelector> createState() => _CustomDateSelectorState();
}

class _CustomDateSelectorState extends State<CustomDateSelector> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _showStartCalendar = false;
  bool _showEndCalendar = false;
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _startController.text = _dateFormat.format(_startDate);
    _endController.text = _dateFormat.format(_endDate);
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _onStartDateChanged(String value) {
    try {
      final parsed = _dateFormat.parseStrict(value);
      setState(() {
        _startDate = parsed;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
          _endController.text = _dateFormat.format(_endDate);
        }
      });
    } catch (_) {
      // Do NOT update _startDate if invalid
    }
  }

  void _onEndDateChanged(String value) {
    try {
      final parsed = _dateFormat.parseStrict(value);
      setState(() {
        _endDate = parsed;
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate;
          _startController.text = _dateFormat.format(_startDate);
        }
      });
    } catch (_) {
      // Do NOT update _endDate if invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 32, // Increased top padding for notch
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _dateField(
                  label: 'Start Date',
                  controller: _startController,
                  onChanged: (val) {
                    _onStartDateChanged(val);
                    _formKey.currentState?.validate();
                  },
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        _startController.text = _dateFormat.format(picked);
                        if (_endDate.isBefore(_startDate)) {
                          _endDate = _startDate;
                          _endController.text = _dateFormat.format(_endDate);
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _dateField(
                  label: 'End Date',
                  controller: _endController,
                  onChanged: (val) {
                    _onEndDateChanged(val);
                    _formKey.currentState?.validate();
                  },
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                        _endController.text = _dateFormat.format(picked);
                        if (_endDate.isBefore(_startDate)) {
                          _startDate = _endDate;
                          _startController.text = _dateFormat.format(_startDate);
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop<DateTimeRange>(
                          DateTimeRange(start: _startDate, end: _endDate),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required void Function(String) onChanged,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: false,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
          onPressed: onTap,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter $label';
        }
        try {
          _dateFormat.parseStrict(value);
        } catch (_) {
          return 'Invalid date (dd-MM-yyyy)';
        }
        return null;
      },
      onChanged: onChanged,
      onTap: () {
        // Only open calendar if user taps the icon, not the field
      },
    );
  }

  Widget _calendar({
    Key? key,
    required DateTime focusedDay,
    required DateTime selectedDay,
    required void Function(DateTime, DateTime) onDaySelected,
  }) {
    return TableCalendar(
      key: key,
      firstDay: DateTime(2020),
      lastDay: DateTime.now(),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: onDaySelected,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: true,
        rightChevronVisible: true,
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Color(0xFF0A253B), shape: BoxShape.circle),
      ),
    );
  }

  // Helper to check if a date string is valid
  bool _isValidDate(String value) {
    try {
      _dateFormat.parseStrict(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Helper to clamp a date to the allowed calendar range
  DateTime _clampToRange(DateTime date) {
    final firstDay = DateTime(2020);
    final lastDay = DateTime.now();
    if (date.isBefore(firstDay)) return firstDay;
    if (date.isAfter(lastDay)) return lastDay;
    return date;
  }
} 