class UserSettings {
  String personName;
  String companyName;
  double salary;
  String phone;
  double overtimeRate;
  String? profilePhotoPath;
  String selectedTheme;
  List<String> holidays;

  String diurnoStart;
  String diurnoEnd;
  String vespertinoStart;
  String vespertinoEnd;
  String nocturnoStart;
  String nocturnoEnd;

  UserSettings({
    this.personName = '',
    this.companyName = '',
    this.salary = 0.0,
    this.phone = '',
    this.overtimeRate = 210.49,
    this.profilePhotoPath,
    this.selectedTheme = 'dark',
    this.holidays = const [],
    this.diurnoStart = '06:00',
    this.diurnoEnd = '15:00',
    this.vespertinoStart = '14:00',
    this.vespertinoEnd = '22:00',
    this.nocturnoStart = '22:00',
    this.nocturnoEnd = '06:00',
  });

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'companyName': companyName,
      'salary': salary,
      'phone': phone,
      'overtimeRate': overtimeRate,
      'profilePhotoPath': profilePhotoPath,
      'selectedTheme': selectedTheme,
      'holidays': holidays,
      'diurnoStart': diurnoStart,
      'diurnoEnd': diurnoEnd,
      'vespertinoStart': vespertinoStart,
      'vespertinoEnd': vespertinoEnd,
      'nocturnoStart': nocturnoStart,
      'nocturnoEnd': nocturnoEnd,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      personName: map['personName'] ?? '',
      companyName: map['companyName'] ?? '',
      salary: (map['salary'] ?? 0.0).toDouble(),
      phone: map['phone'] ?? '',
      overtimeRate: (map['overtimeRate'] ?? 210.49).toDouble(),
      profilePhotoPath: map['profilePhotoPath'],
      selectedTheme: map['selectedTheme'] ?? 'dark',
      holidays: List<String>.from(map['holidays'] ?? []),
      diurnoStart: map['diurnoStart'] ?? '06:00',
      diurnoEnd: map['diurnoEnd'] ?? '15:00',
      vespertinoStart: map['vespertinoStart'] ?? '14:00',
      vespertinoEnd: map['vespertinoEnd'] ?? '22:00',
      nocturnoStart: map['nocturnoStart'] ?? '22:00',
      nocturnoEnd: map['nocturnoEnd'] ?? '06:00',
    );
  }
}
