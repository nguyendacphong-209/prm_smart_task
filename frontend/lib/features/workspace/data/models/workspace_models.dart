import 'package:prm_smart_task/features/workspace/domain/entities/workspace.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';

class WorkspaceModel {
  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.myRole,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final String myRole;
  final DateTime? createdAt;

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      myRole: json['myRole']?.toString() ?? 'member',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Workspace toEntity() {
    return Workspace(
      id: id,
      name: name,
      ownerId: ownerId,
      myRole: myRole,
      createdAt: createdAt,
    );
  }
}

class WorkspaceMemberModel {
  const WorkspaceMemberModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
    this.invitationStatus = 'accepted',
  });

  final String id;
  final String userId;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final String invitationStatus;

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? 'member',
      invitationStatus: json['invitationStatus']?.toString() ?? 'accepted',
    );
  }

  WorkspaceMember toEntity() {
    return WorkspaceMember(
      id: id,
      userId: userId,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      role: role,
      invitationStatus: invitationStatus,
    );
  }
}
