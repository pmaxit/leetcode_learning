// class to execute future task

class TaskExecution {
  final Future Function() task;
  final String taskName;
  final Future Function()? onError;
  final Future Function()? onDone;
  final Future Function()? beforeStart;

  TaskExecution({
    required this.task,
    required this.taskName,
    this.onError,
    this.onDone,
    this.beforeStart,
  });

  Future execute() async {
    if (beforeStart != null) {
      await beforeStart!();
    }
    try {
      await task();
      if (onDone != null) {
        await onDone!();
      }
    } catch (e) {
      print('Error in task: $taskName');
      print(e);
      if (onError != null) {
        await onError!();
      }
    }
  }

  @override
  String toString() {
    return 'TaskExecution: {taskName: $taskName}';
  }

  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
    };
  }

  TaskExecution copyWith({
    Future Function()? task,
    String? taskName,
    Future Function()? onError,
    Future Function()? onDone,
    Future Function()? beforeStart,
  }) {
    return TaskExecution(
      task: task ?? this.task,
      taskName: taskName ?? this.taskName,
      onError: onError ?? this.onError,
      onDone: onDone ?? this.onDone,
      beforeStart: beforeStart ?? this.beforeStart,
    );
  }

  TaskExecution fromJson(Map<String, dynamic> json) {
    return TaskExecution(
      task: json['task'],
      taskName: json['taskName'],
      onError: json['onError'],
      onDone: json['onDone'],
      beforeStart: json['beforeStart'],
    );
  }
}