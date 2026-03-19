import 'package:prm_smart_task/features/project/data/datasources/project_remote_data_source.dart';
import 'package:prm_smart_task/features/project/domain/entities/project.dart';
import 'package:prm_smart_task/features/project/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._remote);

  final ProjectRemoteDataSource _remote;

  @override
  Future<List<Project>> getProjectsByWorkspace({required String workspaceId}) async {
    final projects = await _remote.getProjectsByWorkspace(workspaceId: workspaceId);
    return projects.map((item) => item.toEntity()).toList();
  }

  @override
  Future<Project> createProject({
    required String workspaceId,
    required String name,
    String? description,
  }) async {
    final project = await _remote.createProject(
      workspaceId: workspaceId,
      name: name,
      description: description,
    );
    return project.toEntity();
  }

  @override
  Future<Project> updateProject({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final project = await _remote.updateProject(
      projectId: projectId,
      name: name,
      description: description,
    );
    return project.toEntity();
  }

  @override
  Future<void> deleteProject({required String projectId}) {
    return _remote.deleteProject(projectId: projectId);
  }
}
