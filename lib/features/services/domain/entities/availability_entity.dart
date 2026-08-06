import 'package:equatable/equatable.dart';

class AvailabilityEntity extends Equatable {
  final String schedulingModel;
  final int leadTimeMinutes;
  final List<DayEntity> days;

  const AvailabilityEntity({
    required this.schedulingModel,
    required this.leadTimeMinutes,
    required this.days,
  });

  @override
  List<Object?> get props => [schedulingModel, leadTimeMinutes, days];
}

class DayEntity extends Equatable {
  final String date;
  final List<SlotEntity> slots;

  const DayEntity({
    required this.date,
    required this.slots,
  });

  @override
  List<Object?> get props => [date, slots];
}

class SlotEntity extends Equatable {
  final String uuid;
  final String startsAt;
  final String endsAt;
  final int remaining;
  final String offeringUuid;
  final String offeringCode;

  const SlotEntity({
    required this.uuid,
    required this.startsAt,
    required this.endsAt,
    required this.remaining,
    required this.offeringUuid,
    required this.offeringCode,
  });

  // Get time display (e.g., "07:30 - 08:00")
  String get timeDisplay {
    try {
      final start = DateTime.parse(startsAt);
      final end = DateTime.parse(endsAt);
      return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '$startsAt - $endsAt';
    }
  }

  bool get isAvailable => remaining > 0;

  @override
  List<Object?> get props => [
        uuid,
        startsAt,
        endsAt,
        remaining,
        offeringUuid,
        offeringCode,
      ];
}
