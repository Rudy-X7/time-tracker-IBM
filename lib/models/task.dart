class Task {
  final String id;
  final String name;
  final String projectId;

  Task({
    required this.id, 
      required this.name, 
        required this.projectId
    });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      projectId: json['projectId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'projectId': projectId};
  }
}
