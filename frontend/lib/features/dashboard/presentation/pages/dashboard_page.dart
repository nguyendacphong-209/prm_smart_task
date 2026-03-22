import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
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
  ProviderSubscription<dynamic>? _dashboardSubscription;

  void _showSnack(String message) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Color> _chartPalette(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Color.alphaBlend(
        colorScheme.primary.withValues(alpha: isDark ? 0.26 : 0.20),
        colorScheme.surface,
      ),
      Color.alphaBlend(
        colorScheme.secondary.withValues(alpha: isDark ? 0.24 : 0.18),
        colorScheme.surface,
      ),
    ];
  }

  Color _successColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      colorScheme.secondary.withValues(alpha: 0.55),
      colorScheme.primary.withValues(alpha: 0.45),
    );
  }

  List<MapEntry<String, int>> _sortedEntries(Map<String, int> values) {
    final entries = values.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  String _compactNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }

  String _percentageText(double value) {
    if (value.isNaN || value.isInfinite) return '0%';
    return '${value.toStringAsFixed(0)}%';
  }

  Widget _metricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.14),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.70),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _distributionChart(BuildContext context, List<MapEntry<String, int>> entries) {
    final sum = entries.fold<int>(0, (acc, e) => acc + e.value);
    final chartPalette = _chartPalette(context);
    if (sum == 0) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: Text(
          'Chưa có dữ liệu',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SizedBox(
      height: 172,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 42,
              sectionsSpace: 3,
              pieTouchData: PieTouchData(enabled: false),
              sections: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value.value;
                final color = chartPalette[index % chartPalette.length];
                final percent = (value / sum) * 100;
                return PieChartSectionData(
                  value: value.toDouble(),
                  color: color,
                  radius: 58,
                  title: percent >= 9 ? '${percent.round()}%' : '',
                  titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                );
              }).toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _compactNumber(sum),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                'Tổng task',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _distributionLegendRow(
    BuildContext context, {
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final ratio = total <= 0 ? 0.0 : value / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _percentageText(ratio * 100),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: color.withValues(alpha: 0.18),
                ),
                child: Text(_compactNumber(value)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: ratio,
              valueColor: AlwaysStoppedAnimation(color),
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricGrid(BuildContext context, List<Widget> tiles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final spacing = 10.0;
        final tileWidth = (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles
              .map(
                (tile) => SizedBox(
                  width: tileWidth,
                  child: tile,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _distributionCard(
    BuildContext context, {
    required String title,
    required Map<String, int> values,
  }) {
    final entries = _sortedEntries(values);
    final total = entries.fold<int>(0, (acc, e) => acc + e.value);
    final chartPalette = _chartPalette(context);

    if (entries.isEmpty) {
      return GlassCard(
        style: GlassCardStyle.liquid,
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
      style: GlassCardStyle.liquid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _distributionChart(context, entries),
          const SizedBox(height: 8),
          ...entries.asMap().entries.map((item) {
            final index = item.key;
            final entry = item.value;
            final color = chartPalette[index % chartPalette.length];
            return _distributionLegendRow(
              context,
              label: entry.key,
              value: entry.value,
              total: total,
              color: color,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUserSummary(BuildContext context, UserDashboard dashboard) {
    final assigned = dashboard.totalAssignedTasks;
    final completionRate = assigned <= 0
        ? 0.0
        : ((dashboard.completedTasks / assigned) * 100).clamp(0, 100).toDouble();

    return GlassCard(
      style: GlassCardStyle.spotlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('My Dashboard', style: Theme.of(context).textTheme.titleLarge),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                ),
                child: Text(
                  'Done ${_percentageText(completionRate)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Thống kê số lượng task cá nhân và trạng thái xử lý hiện tại.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _metricGrid(
            context,
            [
              _metricTile(
                context,
                title: 'Được giao',
                value: dashboard.totalAssignedTasks.toString(),
                icon: Icons.person_add_alt_1,
                color: Theme.of(context).colorScheme.primary,
                subtitle: 'Tổng task của bạn',
              ),
              _metricTile(
                context,
                title: 'Hoàn thành',
                value: dashboard.completedTasks.toString(),
                icon: Icons.check_circle_outline,
                color: _successColor(context),
                subtitle: 'Đã xử lý xong',
              ),
              _metricTile(
                context,
                title: 'Quá hạn',
                value: dashboard.overdueTasks.toString(),
                icon: Icons.warning_amber_outlined,
                color: Theme.of(context).colorScheme.error,
                subtitle: 'Cần ưu tiên xử lý',
              ),
              _metricTile(
                context,
                title: 'Sắp đến hạn',
                value: dashboard.dueSoonTasks.toString(),
                icon: Icons.schedule_outlined,
                color: Theme.of(context).colorScheme.secondary,
                subtitle: 'Chuẩn bị deadline',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummary(BuildContext context, ProjectDashboard dashboard) {
    final completion = dashboard.completionPercentage.clamp(0, 100).toDouble();

    return GlassCard(
      style: GlassCardStyle.liquid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dashboard.projectName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.14),
                ),
                child: Text(
                  _percentageText(completion),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn thành ${completion.toStringAsFixed(2)}% • ${dashboard.completedTasks}/${dashboard.totalTasks} task',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  context,
                  title: 'Tổng task',
                  value: dashboard.totalTasks.toString(),
                  icon: Icons.list,
                  color: Theme.of(context).colorScheme.tertiary,
                  subtitle: 'Khối lượng hiện tại',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  context,
                  title: 'Đã xong',
                  value: dashboard.completedTasks.toString(),
                  icon: Icons.verified_outlined,
                  color: _successColor(context),
                  subtitle: 'Task hoàn tất',
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

    _dashboardSubscription = ref.listenManual(
      dashboardControllerProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          _showSnack(next.errorMessage!);
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardControllerProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _dashboardSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);

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
                        style: GlassCardStyle.liquid,
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
                      style: GlassCardStyle.spotlight,
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
