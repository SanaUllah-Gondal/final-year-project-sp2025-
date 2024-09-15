import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AdvancedDateTimePicker extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final ValueChanged<DateTime> onDateTimeSelected;
  final String? label;
  final bool isRequired;
  final EdgeInsetsGeometry? margin;
  final bool showIcon;

  const AdvancedDateTimePicker({
    Key? key,
    this.initialDate,
    this.initialTime,
    required this.onDateTimeSelected,
    this.label,
    this.isRequired = false,
    this.margin,
    this.showIcon = true,
  }) : super(key: key);

  @override
  State<AdvancedDateTimePicker> createState() => _AdvancedDateTimePickerState();
}

class _AdvancedDateTimePickerState extends State<AdvancedDateTimePicker> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
  }

  String get _formattedDateTime {
    if (_selectedDate == null && _selectedTime == null) {
      return 'Select date and time';
    } else if (_selectedDate != null && _selectedTime == null) {
      return '${DateFormat('MMM dd, yyyy').format(_selectedDate!)} - Select time';
    } else if (_selectedDate == null && _selectedTime != null) {
      return 'Select date - ${_selectedTime!.format(context)}';
    } else {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DatePickerSheet(
        initialDate: _selectedDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });

      // After selecting date, open time picker automatically
      await Future.delayed(const Duration(milliseconds: 200));
      _selectTime();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TimePickerSheet(
        initialTime: _selectedTime ?? TimeOfDay.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _notifyDateTimeChange();
    }
  }

  void _notifyDateTimeChange() {
    if (_selectedDate != null && _selectedTime != null) {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      widget.onDateTimeSelected(dateTime);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    widget.label!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.isRequired)
                    const Text(
                      ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedDate != null && _selectedTime != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.showIcon)
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  if (widget.showIcon) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formattedDateTime,
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null && _selectedTime != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_selectedDate != null || _selectedTime != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: Colors.grey,
                      onPressed: _clearSelection,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;

  const _DatePickerSheet({required this.initialDate});

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return _buildSheetWrapper(
      context,
      title: 'Select Date',
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selected, _) {
                setState(() => _selectedDate = selected);
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _selectedDate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Next →',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TimePickerSheet extends StatefulWidget {
  final TimeOfDay initialTime;

  const _TimePickerSheet({required this.initialTime});

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  List<TimeOfDay> _generateSlots() {
    final List<TimeOfDay> slots = [];
    for (int hour = 7; hour <= 22; hour++) {
      for (int min = 0; min < 60; min += 30) {
        slots.add(TimeOfDay(hour: hour, minute: min));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _generateSlots();
    return _buildSheetWrapper(
      context,
      title: 'Select Time',
      child: Column(
        children: [
          Text(
            _selectedTime.format(context),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.6,
              ),
              itemCount: slots.length,
              itemBuilder: (_, i) {
                final t = slots[i];
                final isSelected = t.hour == _selectedTime.hour &&
                    t.minute == _selectedTime.minute;
                return InkWell(
                  onTap: () => setState(() => _selectedTime = t),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.format(context),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _selectedTime),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

Widget _buildSheetWrapper(BuildContext context,
    {required String title, required Widget child}) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.8,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );
}
