DateTime roundToNextQuarterHour(DateTime now) {
  int minute = now.minute;
  int roundedMinute;

  // Se já está num múltiplo de 15, mantemos igual
  if (minute % 15 == 0) {
    roundedMinute = minute;
  } else {
    // Arredonda para cima
    roundedMinute = ((minute ~/ 15) + 1) * 15;
    if (roundedMinute == 60) {
      // Passa para próxima hora
      roundedMinute = 0;
      now = now.add(Duration(hours: 1));
    }
  }

  return DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    roundedMinute,
  );
}
