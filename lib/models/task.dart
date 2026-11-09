import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject{
  //task 
  @HiveField(0)
  final String id; 
  @HiveField(1)
  String title; 
  @HiveField(2)
  String description; 
  @HiveField(3)
  bool isCompleted; 

  //location
  @HiveField(4)
  String? locationName;
  @HiveField(5)
  String? locationAddress;
  @HiveField(6)
  double? latitude;
  @HiveField(7)
  double? longitude;

  //due date 
  @HiveField(8)
  DateTime? dueDate;

  //reminder 
  @HiveField(9)
  List<int> reminderMinutes;
  @HiveField(10)
  Map<int, int> notificationIds;

  @HiveField(11)
  final DateTime createdAt;

  //constructor 
  Task({
    required this.id, 
    required this.title, 
    required this.description, 
    this.isCompleted = false,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.dueDate,
    this.reminderMinutes = const [],
    this.notificationIds = const {},
    required this.createdAt,
  }); 
}