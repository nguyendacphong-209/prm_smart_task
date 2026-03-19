import 'package:prm_smart_task/features/project/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjectsByWorkspace({required String workspaceId});

  Future<Project> createProject({
    required String workspaceId,
    required String name,
    String? description,
  });

  Future<Project> updateProject({
    required String projectId,
    required String name,
    String? description,
  });

  Future<void> deleteProject({required String projectId});
}
