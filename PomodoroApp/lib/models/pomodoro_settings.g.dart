// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PomodoroSettingsAdapter extends TypeAdapter<PomodoroSettings> {
  @override
  final int typeId = 0;

  @override
  PomodoroSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSettings(
      workDuration: fields[0] as int,
      shortBreakDuration: fields[1] as int,
      longBreakDuration: fields[2] as int,
      sessionsBeforeLongBreak: fields[3] as int,
      autoStartBreaks: fields[4] as bool,
      autoStartPomodoros: fields[5] as bool,
      soundEnabled: fields[6] as bool,
      notificationsEnabled: fields[7] as bool,
      tickingSoundEnabled: fields[8] as bool,
      volume: fields[9] as double,
      dailyGoal: fields[10] as int,
      languageCode: fields[11] as String?,
      totalCoins: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.workDuration)
      ..writeByte(1)
      ..write(obj.shortBreakDuration)
      ..writeByte(2)
      ..write(obj.longBreakDuration)
      ..writeByte(3)
      ..write(obj.sessionsBeforeLongBreak)
      ..writeByte(4)
      ..write(obj.autoStartBreaks)
      ..writeByte(5)
      ..write(obj.autoStartPomodoros)
      ..writeByte(6)
      ..write(obj.soundEnabled)
      ..writeByte(7)
      ..write(obj.notificationsEnabled)
      ..writeByte(8)
      ..write(obj.tickingSoundEnabled)
      ..writeByte(9)
      ..write(obj.volume)
      ..writeByte(10)
      ..write(obj.dailyGoal)
      ..writeByte(11)
      ..write(obj.languageCode)
      ..writeByte(12)
      ..write(obj.totalCoins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
