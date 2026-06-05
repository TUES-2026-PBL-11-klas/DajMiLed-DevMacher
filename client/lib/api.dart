import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth.dart' as auth;

const _base = 'http://localhost:8080';

class ApiClient {
  static Future<Map<String, String>> _headers() async {
    final token = await auth.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _checked(Future<http.Response> call) async {
    final res = await call;
    if (res.statusCode == 401) await auth.logout();
    return res;
  }

  static Future<http.Response> get(String path) async =>
      _checked(http.get(Uri.parse('$_base$path'), headers: await _headers()));

  static Future<http.Response> post(String path, Object body) async =>
      _checked(http.post(Uri.parse('$_base$path'),
          headers: await _headers(), body: jsonEncode(body)));

  static Future<http.Response> put(String path, Object body) async =>
      _checked(http.put(Uri.parse('$_base$path'),
          headers: await _headers(), body: jsonEncode(body)));

  static Future<http.Response> delete(String path) async =>
      _checked(http.delete(Uri.parse('$_base$path'), headers: await _headers()));

  static Future<http.Response> apply(int projectId, int taskId) =>
      post('/api/projects/$projectId/tasks/$taskId/applications', {});

  static Future<http.Response> getTaskApplications(int projectId, int taskId) =>
      get('/api/projects/$projectId/tasks/$taskId/applications');

  static Future<http.Response> updateApplicationStatus(
          int projectId, int taskId, int appId, String status) =>
      put('/api/projects/$projectId/tasks/$taskId/applications/$appId',
          {'status': status});

  static Future<http.Response> withdrawApplication(
          int projectId, int taskId, int appId) =>
      delete('/api/projects/$projectId/tasks/$taskId/applications/$appId');

  static Future<http.Response> getMyApplications() =>
      get('/api/users/me/applications');

  static Future<http.Response> getUserById(int id) =>
      get('/api/users/$id');

  static Future<http.Response> createProject(String title, String? description) =>
      post('/api/projects', {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  static Future<http.Response> createTask(int projectId, String title, String? description) =>
      post('/api/projects/$projectId/tasks', {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
      });

  static Future<http.Response> addSkillToTask(int projectId, int taskId, int skillId) =>
      post('/api/projects/$projectId/tasks/$taskId/skills/$skillId', {});

  static Future<http.Response> searchSkills(String query) =>
      get('/api/skills/search?q=${Uri.encodeQueryComponent(query)}');

  static Future<http.Response> createSkill(String name) =>
      post('/api/skills', {'name': name});

  static Future<http.Response> getAllSkills() =>
      get('/api/skills');

  static Future<http.Response> addSkillToUser(int skillId) =>
      post('/api/users/me/skills/$skillId', {});

  static Future<http.Response> removeSkillFromUser(int skillId) =>
      delete('/api/users/me/skills/$skillId');

  static Future<http.Response> getRelevantTasks() =>
      get('/api/users/me/relevant-tasks');
}

class SkillTagDto {
  final int id;
  final String name;
  const SkillTagDto({required this.id, required this.name});
  factory SkillTagDto.fromJson(Map<String, dynamic> j) =>
      SkillTagDto(id: (j['id'] as num).toInt(), name: j['name'] as String);
}

class UserSummaryDto {
  final int id;
  final String email, firstName, lastName;
  final String? username;
  const UserSummaryDto(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      this.username});
  factory UserSummaryDto.fromJson(Map<String, dynamic> j) => UserSummaryDto(
        id: (j['id'] as num).toInt(),
        email: j['email'] as String,
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        username: j['username'] as String?,
      );
  String get displayName => username ?? '$firstName $lastName';
}

class UserDto {
  final int id;
  final String email, firstName, lastName;
  final String? username, discordTag, githubLink, bio, education;
  final List<SkillTagDto> skills;
  const UserDto(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      this.username,
      this.discordTag,
      this.githubLink,
      this.bio,
      this.education,
      required this.skills});
  factory UserDto.fromJson(Map<String, dynamic> j) => UserDto(
        id: (j['id'] as num).toInt(),
        email: j['email'] as String,
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        username: j['username'] as String?,
        discordTag: j['discordTag'] as String?,
        githubLink: j['githubLink'] as String?,
        bio: j['bio'] as String?,
        education: j['education'] as String?,
        skills: (j['skills'] as List<dynamic>? ?? [])
            .map((s) => SkillTagDto.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}'
      '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
  String get fullName => '$firstName $lastName';
}

class ProjectTaskDto {
  final int id;
  final String title;
  final String? description;
  final List<SkillTagDto> requiredSkills;
  const ProjectTaskDto(
      {required this.id,
      required this.title,
      this.description,
      required this.requiredSkills});
  factory ProjectTaskDto.fromJson(Map<String, dynamic> j) => ProjectTaskDto(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String,
        description: j['description'] as String?,
        requiredSkills: (j['requiredSkills'] as List<dynamic>? ?? [])
            .map((s) => SkillTagDto.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class ProjectDto {
  final int id;
  final UserSummaryDto owner;
  final String title;
  final String? description;
  final List<ProjectTaskDto> tasks;
  const ProjectDto(
      {required this.id,
      required this.owner,
      required this.title,
      this.description,
      required this.tasks});
  factory ProjectDto.fromJson(Map<String, dynamic> j) => ProjectDto(
        id: (j['id'] as num).toInt(),
        owner: UserSummaryDto.fromJson(j['owner'] as Map<String, dynamic>),
        title: j['title'] as String,
        description: j['description'] as String?,
        tasks: (j['tasks'] as List<dynamic>? ?? [])
            .map((t) => ProjectTaskDto.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
  List<String> get allSkillNames =>
      tasks.expand((t) => t.requiredSkills.map((s) => s.name)).toSet().toList();
}

class ApplicationDto {
  final int id;
  final int taskId;
  final int applicantId;
  final String status;
  const ApplicationDto(
      {required this.id,
      required this.taskId,
      required this.applicantId,
      required this.status});
  factory ApplicationDto.fromJson(Map<String, dynamic> j) => ApplicationDto(
        id: (j['id'] as num).toInt(),
        taskId: (j['taskId'] as num).toInt(),
        applicantId: (j['applicantId'] as num).toInt(),
        status: j['status'] as String,
      );
  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
}
