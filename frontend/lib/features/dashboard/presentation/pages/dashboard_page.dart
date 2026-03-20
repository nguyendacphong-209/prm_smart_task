import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/dashboard/application/providers/dashboard_providers.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/project_dashboard.dart';
import 'package:prm_smart_task/features/dashboard/domain/entities/user_dashboard.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  List<MapEntry<String, int>> _sortedEntries(Map<String, int> values) {
    final entries = values.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Widget _metricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _distributionCard(
    BuildContext context, {
    required String title,
    required Map<String, int> values,
  }) {
    final entries = _sortedEntries(values);

    if (entries.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Chưa có dữ liệu'),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
                    ),
                    child: Text(entry.value.toString()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSummary(BuildContext context, UserDashboard dashboard) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Dashboard', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Thống kê số lượng task cá nhân và trạng thái xử lý hiện tại.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 160,
                child: _metricTile(
                  context,
                  title: 'Được giao',
                  value: dashboard.totalAssignedTasks.toString(),
                  icon: Icons.assignment_ind_outlined,
                ),
              ),
              SizedBox(
                width: 160,
                child: _metricTile(
                  context,
                  title: 'Hoàn thành',
                  value: dashboard.completedTasks.toString(),
                  icon: Icons.task_alt_rounded,
                ),
              ),
              SizedBox(
                width: 160,
                child: _metricTile(
                  context,
                  title: 'Quá hạn',
                  value: dashboard.overdueTasks.toString(),
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              SizedBox(
                width: 160,
                child: _metricTile(
                  context,
                  title: 'Sắp đến hạn',
                  value: dashboard.dueSoonTasks.toString(),
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummary(BuildContext context, ProjectDashboard dashboard) {
    final completion = dashboard.completionPercentage.clamp(0, 100);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboard.projectName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Text('Hoàn thành: ${completion.toStringAsFixed(2)}%'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  context,
                  title: 'Tổng task',
                  value: dashboard.totalTasks.toString(),
                  icon: Icons.list_alt_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  context,
                  title: 'Đã xong',
                  value: dashboard.completedTasks.toString(),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);

    ref.listen(dashboardControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(dashboardControllerProvider.notifier).loadDashboard(
                    forceReload: true,
                  );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: state.isLoading
              ? const TabSkeletonView(cardCount: 3)
              : state.errorMessage != null && state.userDashboard == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        child: ErrorStateView(
                          title: 'Không thể tải dashboard',
                          message: state.errorMessage!,
                          actionLabel: 'Thử lại',
                          onAction: () {
                            ref
                                .read(dashboardControllerProvider.notifier)
                                .loadDashboard(forceReload: true);
                          },
                        ),
                      ),
                    )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    if (state.userDashboard != null)
                      _buildUserSummary(context, state.userDashboard!),
                    const SizedBox(height: 14),
                    if (state.userDashboard == null)
                      GlassCard(
                        child: const EmptyStateView(
                          icon: Icons.insights_outlined,
                          title: 'Chưa có dữ liệu cá nhân',
                          message: 'Khi bạn được giao task, dashboard sẽ hiển thị số liệu tại đây.',
                        ),
                      )
                    else ...[
                      _distributionCard(
                        context,
                        title: 'Task theo độ ưu tiên',
                        values: state.userDashboard!.tasksByPriority,
                      ),
                      const SizedBox(height: 10),
                      _distributionCard(
                        context,
                        title: 'Task theo trạng thái',
                        values: state.userDashboard!.tasksByStatus,
                      ),
                    ],
                    const SizedBox(height: 14),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Dashboard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          if (state.projectOptions.isEmpty)
                            const EmptyStateView(
                              icon: Icons.folder_open_rounded,
                              title: 'Chưa có project để theo dõi',
                              message: 'Hãy tạo project trong workspace để xem tiến độ chi tiết.',
                            )
                          else ...[
                            DropdownButtonFormField<String>(
                              initialValue: state.selectedProjectId,
                              decoration: const InputDecoration(
                                labelText: 'Chọn project',
                                prefixIcon: Icon(Icons.folder_special_outlined),
                              ),
                              items: state.projectOptions
                                  .map(
                                    (item) => DropdownMenuItem<String>(
                                      value: item.projectId,
                                      child: Text(item.displayLabel),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (projectId) {
                                if (projectId == null || projectId.isEmpty) {
                                  return;
                                }

                                ref
                                    .read(dashboardControllerProvider.notifier)
                                    .selectProject(projectId);
                              },
                            ),
                            const SizedBox(height: 12),
                            if (state.isProjectLoading)
                              Column(
                                children: const [
                                  SkeletonBox(height: 18, width: 220),
                                  SizedBox(height: 10),
                                  SkeletonBox(height: 14),
                                  SizedBox(height: 8),
                                  SkeletonBox(height: 14, width: 180),
                                ],
                              )
                            else if (state.projectDashboard == null)
                              const EmptyStateView(
                                icon: Icons.stacked_bar_chart_rounded,
                                title: 'Chưa có dữ liệu project',
                                message: 'Project được chọn chưa có dữ liệu thống kê.',
                              )
                            else ...[
                              _buildProjectSummary(
                                context,
                                state.projectDashboard!,
                              ),
                              const SizedBox(height: 10),
                              _distributionCard(
                                context,
                                title: 'Task theo status của project',
                                values: state.projectDashboard!.tasksByStatus,
                              ),
                              const SizedBox(height: 10),
                              _distributionCard(
                                context,
                                title: 'Task theo priority của project',
                                values: state.projectDashboard!.tasksByPriority,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
