import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/features/auth/application/providers/auth_providers.dart';
import 'package:prm_smart_task/features/auth/presentation/pages/change_password_page.dart';
import 'package:prm_smart_task/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:prm_smart_task/features/auth/presentation/pages/login_page.dart';
import 'package:prm_smart_task/features/auth/presentation/pages/register_page.dart';
import 'package:prm_smart_task/features/home/presentation/pages/home_shell.dart';
import 'package:prm_smart_task/features/kanban/presentation/pages/kanban_board_page.dart';
import 'package:prm_smart_task/features/project/presentation/pages/project_list_page.dart';
import 'package:prm_smart_task/features/task/presentation/pages/task_detail_page.dart';
import 'package:prm_smart_task/features/task/presentation/pages/task_list_page.dart';
import 'package:prm_smart_task/features/workspace/presentation/pages/create_workspace_page.dart';
import 'package:prm_smart_task/features/workspace/presentation/pages/workspace_detail_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Home Shell (requires auth)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),

      // Profile Sub-routes (accessed from home shell)
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),

      GoRoute(
        path: '/workspaces/create',
        builder: (context, state) => const CreateWorkspacePage(),
      ),

      // Workspace Routes (requires auth + workspace membership)
      GoRoute(
        path: '/workspaces/:id',
        builder: (context, state) {
          final workspaceId = state.pathParameters['id'] ?? '';
          return WorkspaceDetailPage(workspaceId: workspaceId);
        },
      ),
      GoRoute(
        path: '/workspaces/:id/projects',
        builder: (context, state) {
          final workspaceId = state.pathParameters['id'] ?? '';
          return ProjectListPage(workspaceId: workspaceId);
        },
      ),
      GoRoute(
        path: '/projects/:id/tasks',
        builder: (context, state) {
          final projectId = state.pathParameters['id'] ?? '';
          final workspaceId = state.uri.queryParameters['workspaceId'] ?? '';
          final projectName = state.uri.queryParameters['projectName'];

          return TaskListPage(
            projectId: projectId,
            workspaceId: workspaceId,
            projectName: projectName,
          );
        },
      ),
      GoRoute(
        path: '/projects/:id/kanban',
        builder: (context, state) {
          final projectId = state.pathParameters['id'] ?? '';
          final workspaceId = state.uri.queryParameters['workspaceId'] ?? '';
          final projectName = state.uri.queryParameters['projectName'];

          return KanbanBoardPage(
            projectId: projectId,
            workspaceId: workspaceId,
            projectName: projectName,
          );
        },
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id'] ?? '';
          final projectId = state.uri.queryParameters['projectId'] ?? '';
          final workspaceId = state.uri.queryParameters['workspaceId'] ?? '';
          final projectName = state.uri.queryParameters['projectName'];

          return TaskDetailPage(
            taskId: taskId,
            projectId: projectId,
            workspaceId: workspaceId,
            projectName: projectName,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final path = state.matchedLocation;

      // Route classification
      final isAuthScreen = path == '/login' || path == '/register';
      final isHomeScreen = path == '/home';
      final isProfileDependentScreen = path.startsWith('/profile/');
      final isProtectedScreen =
          isHomeScreen || isProfileDependentScreen || path.startsWith('/workspaces');

      // Redirect unauthenticated users to login
      if (!isAuth && isProtectedScreen) {
        return '/login';
      }

      // Redirect authenticated users from auth screens to home
      if (isAuth && isAuthScreen) {
        return '/home';
      }

      return null;
    },
  );
});
