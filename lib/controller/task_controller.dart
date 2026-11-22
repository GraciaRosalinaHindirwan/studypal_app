import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:studypal/models/task.dart';
import 'package:studypal/services/notification_service.dart';
import 'package:studypal/services/task_service.dart';

class TaskController extends GetxController{
  late final TaskService _taskService;

  //setiap kali task bertambah / berkurang dia otomatis refresh diri (observable)
  final RxList<Task> tasks = <Task>[].obs; 

  //fungsi yang dijalankan pertama kali ketika controller dibuat. 
  @override
  void onInit() {
    super.onInit(); 
    final taskBox = Hive.box<Task>('tasks');
    _taskService = TaskService(taskBox); 

    // Ambil data dari database Hive saat aplikasi pertama kali dibuka
    fetchTasks(); 

    //tiap ada task baru panggil fetchTask
    taskBox.watch().listen((event) {
      fetchTasks();
    });
  }

   // Fungsi untuk menarik seluruh task dari Hive ke dalam memori
  void fetchTasks(){
    tasks.assignAll(_taskService.getTasks()); 
  }

  //cek apakah suatu tanggal adalah hari ini 
  bool _isToday(DateTime? date){
    if(date == null) return false; 
    final now = DateTime.now(); 
    return date.year == now.year &&
      date.month == now.month && 
      date.day == now.day; 
  }

  //ambil tugas yang due datenya hari ini 
  List<Task> get todayTasks {
    return tasks.where((task) => _isToday(task.dueDate)).toList(); 
  }

  //total jumlah tugas hari ini 
  int get totalToday => todayTasks.length;

  // Menghitung berapa tugas hari ini yang Done
  int get completeToday => todayTasks.where((task) => task.isCompleted == true).length;

  // Menghitung berapa tugas hari ini yang Todo
  int get todoToday => todayTasks.where((task) => task.isCompleted != true).length;

  // Menghitung persentase progress (0% sampai 100%)
  int get percentage {
    if (totalToday == 0) return 0;
    return ((completeToday / totalToday) * 100).round().clamp(0, 100);
  }

  String get progressMessage {
    if (totalToday == 0) {
      return "No Tasks Schedule for today yet";
    } else if (percentage == 100) {
      return "Awesome! All today's tasks are done";
    } else {
      return "Great, your today's plan is almost done";
    }
  }

  //CRUD 
  // Menambah task baru
  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    fetchTasks(); // update list data, layar otomatis refresh!
  }

  // Mengubah/Update task
  Future<void> updateTask(Task task) async {
    await _taskService.updateTask(task);
    fetchTasks();
  }

  // Menghapus task
  Future<void> deleteTask(Task task) async {
    try {
      // Batalkan notifikasi
      await NotificationService.instance.cancelTaskReminders(task);
      // Hapus dari Hive
      await _taskService.deleteTask(task.id);
      // Update list data
      fetchTasks();
      // Tampilkan pemberitahuan hijau/sukses ke user tanpa butuh 'context'
      Get.snackbar(
        'Berhasil',
        'Tugas "${task.title}" berhasil dihapus!',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),   
      );
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
    }
  }
}