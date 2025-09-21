import 'package:flutter/material.dart';
import '../utils.dart';

class TimePickerDropdown extends StatefulWidget {
  final VoidCallback? onChanged;
  final int? initialHour;
  final int? initialMinute;
  
  const TimePickerDropdown({
    super.key, 
    this.onChanged,
    this.initialHour,
    this.initialMinute,
  });

  @override
  TimePickerDropdownState createState() => TimePickerDropdownState();
}

class TimePickerDropdownState extends State<TimePickerDropdown> {
  int? selectedHour;
  int? selectedMinute;

  @override
  void initState() {
    super.initState();
    // Set initial values if provided
    selectedHour = widget.initialHour;
    selectedMinute = widget.initialMinute;
  }

  // Dropdown de horas (0-23) com item "Hora atual"
  List<DropdownMenuItem<int?>> buildHourItems() {
    List<DropdownMenuItem<int?>> items = [];

    items.add(DropdownMenuItem<int?>(value: -1, child: Text('Hora atual')));

    for (int h = 0; h < 24; h++) {
      items.add(
        DropdownMenuItem<int?>(
          value: h,
          child: Text(h.toString().padLeft(2, '0')),
        ),
      );
    }
    return items;
  }

  // Dropdown de minutos fixos
  List<DropdownMenuItem<int?>> buildMinuteItems() {
    return [0, 15, 30, 45].map((m) {
      return DropdownMenuItem<int?>(
        value: m,
        child: Text(m.toString().padLeft(2, '0')),
      );
    }).toList();
  }

  void selectCurrentTime() {
    DateTime now = DateTime.now();
    DateTime rounded = roundToNextQuarterHour(now);

    setState(() {
      selectedHour = rounded.hour;
      selectedMinute = rounded.minute;
    });
    widget.onChanged?.call();
  }

  bool get isConfirmEnabled => selectedHour != null && selectedMinute != null;
  
  bool get isTimeSelected => selectedHour != null && selectedMinute != null;
  
  void setTime(int hour, int minute) {
    setState(() {
      selectedHour = hour;
      selectedMinute = minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
              // Dropdown de hora
              Expanded(
                child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 12.0,
                  ),
                ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedHour,
                      hint: Text("Hora"),
                      items: buildHourItems(),
                      onChanged: (value) {
                        if (value == -1) {
                          selectCurrentTime();
                        } else {
                          setState(() {
                            selectedHour = value;
                            selectedMinute = null; // reseta minutos até escolher
                          });
                        }
                        widget.onChanged?.call();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Minuto',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 12.0,
                  ),
                ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedMinute,
                      hint: Text("Minuto"),
                      items: buildMinuteItems(),
                      onChanged: selectedHour == null
                          ? null
                          : (value) {
                              setState(() => selectedMinute = value);
                              widget.onChanged?.call();
                            },
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
