import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/features/workspace/application/providers/workspace_providers.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace.dart';
import 'package:prm_smart_task/features/workspace/domain/entities/workspace_member.dart';
import 'package:prm_smart_task/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:prm_smart_task/features/workspace/presentation/pages/workspace_detail_page.dart';

import '../test_utils/red_screen_guard.dart';

class _FakeWorkspaceRepository implements WorkspaceRepository {
  final Workspace _workspace = Workspace(
    id: 'workspace-1',
    name: 'Workspace Test',
    ownerId: 'owner-1',
    myRole: 'owner',
    createdAt: DateTime(2026, 1, 1),
  );

  final List<WorkspaceMember> _members = const [
    WorkspaceMember(
      id: 'member-1',
      userId: 'user-1',
      email: 'owner@example.com',
      fullName: 'Owner One',
      avatarUrl: null,
      role: 'owner',
    ),
  ];

  @override
  Future<WorkspaceMember> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    throw Exception('Không tìm thấy người dùng');
  }

  @override
  Future<Workspace> getWorkspaceDetail({required String workspaceId}) async {
    return _workspace;
  }

  @override
  Future<List<WorkspaceMember>> getWorkspaceMembers({
    required String workspaceId,
  }) async {
    return _members;
  }

  @override
  Future<List<WorkspaceMember>> getWorkspaceAssignees({
    required String workspaceId,
  }) async {
    return _members;
  }

  @override
  Future<List<Workspace>> getMyWorkspaces() async {
    return [_workspace];
  }

  @override
  Future<Workspace> createWorkspace({required String name}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWorkspace({required String workspaceId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Workspace> updateWorkspace({
    required String workspaceId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WorkspaceMember> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WorkspaceMember> approveMemberInvitation({
    required String workspaceId,
    required String userId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectMemberInvitation({
    required String workspaceId,
    required String userId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('invite with non-existing email shows error and no red-screen', (
    tester,
  ) async {
    await runWithRedScreenGuard(tester, () async {
      final fakeRepository = _FakeWorkspaceRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workspaceRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: MaterialApp(
            scaffoldMessengerKey: appScaffoldMessengerKey,
            home: const WorkspaceDetailPage(workspaceId: 'workspace-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mời thành viên').first);
      await tester.pumpAndSettle();

      final inviteDialog = find.byType(AlertDialog);
      final emailField = find.descendant(
        of: inviteDialog,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == 'Email',
        ),
      );
      final submitInviteButton = find.descendant(
        of: inviteDialog,
        matching: find.widgetWithText(FilledButton, 'Mời'),
      );

      await tester.enterText(
        emailField,
        'unknown@example.com',
      );
      await tester.tap(submitInviteButton);
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy người dùng'), findsOneWidget);
    });
  });
}