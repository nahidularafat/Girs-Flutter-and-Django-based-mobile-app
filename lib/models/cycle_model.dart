class SymptomLog {
  final int? id;
  final String date;
  final String symptom;
  final int severity;
  final String? notes;

  SymptomLog({
    this.id,
    required this.date,
    required this.symptom,
    this.severity = 1,
    this.notes,
  });

  factory SymptomLog.fromJson(Map<String, dynamic> json) => SymptomLog(
    id: json['id'],
    date: json['date'] ?? '',
    symptom: json['symptom'] ?? '',
    severity: json['severity'] ?? 1,
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'symptom': symptom,
    'severity': severity,
    'notes': notes ?? '',
  };
}

class CycleLog {
  final int? id;
  final String startDate;
  final String? endDate;
  final String? flowIntensity;
  final String? notes;
  final int? duration;
  final List<SymptomLog> symptoms;

  CycleLog({
    this.id,
    required this.startDate,
    this.endDate,
    this.flowIntensity,
    this.notes,
    this.duration,
    this.symptoms = const [],
  });

  factory CycleLog.fromJson(Map<String, dynamic> json) => CycleLog(
    id: json['id'],
    startDate: json['start_date'] ?? '',
    endDate: json['end_date'],
    flowIntensity: json['flow_intensity'],
    notes: json['notes'],
    duration: json['duration'],
    symptoms: (json['symptoms'] as List<dynamic>? ?? [])
        .map((s) => SymptomLog.fromJson(s))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'start_date': startDate,
    'end_date': endDate,
    'flow_intensity': flowIntensity,
    'notes': notes ?? '',
  };
}

class PredictionData {
  final String lastPeriodDate;
  final String nextPeriodDate;
  final String nextPeriodDateEarly;
  final String nextPeriodDateLate;
  final String ovulationDate;
  final String fertileWindowStart;
  final String fertileWindowEnd;
  final int avgCycleLength;
  final int avgPeriodDuration;
  final int confidenceDays;
  final int numCyclesUsed;
  final int currentCycleDay;
  final String currentPhase;
  final int daysUntilNextPeriod;

  PredictionData({
    required this.lastPeriodDate,
    required this.nextPeriodDate,
    required this.nextPeriodDateEarly,
    required this.nextPeriodDateLate,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.avgCycleLength,
    required this.avgPeriodDuration,
    required this.confidenceDays,
    required this.numCyclesUsed,
    required this.currentCycleDay,
    required this.currentPhase,
    required this.daysUntilNextPeriod,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) => PredictionData(
    lastPeriodDate: json['last_period_date'] ?? '',
    nextPeriodDate: json['next_period_date'] ?? '',
    nextPeriodDateEarly: json['next_period_date_early'] ?? '',
    nextPeriodDateLate: json['next_period_date_late'] ?? '',
    ovulationDate: json['ovulation_date'] ?? '',
    fertileWindowStart: json['fertile_window_start'] ?? '',
    fertileWindowEnd: json['fertile_window_end'] ?? '',
    avgCycleLength: json['avg_cycle_length'] ?? 28,
    avgPeriodDuration: json['avg_period_duration'] ?? 5,
    confidenceDays: json['confidence_days'] ?? 7,
    numCyclesUsed: json['num_cycles_used'] ?? 0,
    currentCycleDay: json['current_cycle_day'] ?? 1,
    currentPhase: json['current_phase'] ?? 'follicular',
    daysUntilNextPeriod: json['days_until_next_period'] ?? 0,
  );
}

class GuidanceData {
  final String phase;
  final int cycleDay;
  final List<String> loggedSymptoms;
  final String guidanceTitle;
  final String guidanceContent;
  final String guidanceSource;
  final String disclaimer;

  GuidanceData({
    required this.phase,
    required this.cycleDay,
    required this.loggedSymptoms,
    required this.guidanceTitle,
    required this.guidanceContent,
    required this.guidanceSource,
    required this.disclaimer,
  });

  factory GuidanceData.fromJson(Map<String, dynamic> json) => GuidanceData(
    phase: json['phase'] ?? 'follicular',
    cycleDay: json['cycle_day'] ?? 1,
    loggedSymptoms: List<String>.from(json['logged_symptoms'] ?? []),
    guidanceTitle: json['guidance']?['title'] ?? 'Today\'s Tip',
    guidanceContent: json['guidance']?['content'] ?? '',
    guidanceSource: json['guidance']?['source'] ?? 'fallback',
    disclaimer: json['disclaimer'] ?? '',
  );
}
