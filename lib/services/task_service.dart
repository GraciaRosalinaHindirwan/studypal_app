import 'package:hive/hive.dart';
import 'package:studypal/models/task.dart';

class TaskService {
  final Box<Task> _taskBox;   
  TaskService(this._taskBox);

  //create
  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  //read: ambil semua task 
  List<Task> getTasks() {
    return _taskBox.values.toList();
  }

  //read: ambil task berdasarkan id 
  Task? getTaskById(String id) {
    return _taskBox.get(id);
  }

  //update
  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  //delete 
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }
}