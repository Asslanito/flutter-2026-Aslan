sealed class Countdown {
  const Countdown();

  factory Countdown.at(DateTime start, DateTime now) {
    final elapsed = now.difference(start);
    if (elapsed.isNegative) return Upcoming(start.difference(now));
    if (elapsed < const Duration(hours: 1)) return Started(elapsed);
    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}

String countdownLabel(Countdown countdown) => switch (countdown) {
  Upcoming(:final remaining) when remaining.inDays > 0 =>
    'In ${remaining.inDays} days',
  Upcoming(:final remaining) when remaining.inHours > 0 =>
    'In ${remaining.inHours} hours',
  Upcoming(:final remaining) => 'In ${remaining.inMinutes + 1} min',
  Started() => 'Started',
  Ended() => 'Ended',
};
