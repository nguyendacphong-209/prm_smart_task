import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';
import 'package:prm_smart_task/core/theme/app_theme.dart';
import 'package:prm_smart_task/features/kanban/application/providers/kanban_providers.dart';
import 'package:prm_smart_task/features/kanban/domain/entities/kanban_task_card.dart';
import 'package:prm_smart_task/features/kanban/presentation/widgets/create_status_dialog.dart';
import 'package:prm_smart_task/shared/widgets/empty_state_view.dart';
import 'package:prm_smart_task/shared/widgets/error_state_view.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/skeleton_loading.dart';
import 'package:prm_smart_task/shared/widgets/status_chip.dart';

class KanbanBoardPage extends ConsumerStatefulWidget {
  const KanbanBoardPage({
    super.key,
    required this.projectId,
    required this.workspaceId,
    this.projectName,
  });

  final String projectId;
  final String workspaceId;
  final String? projectName;

  @override
  ConsumerState<KanbanBoardPage> createState() => _KanbanBoardPageState();
}

class _KanbanBoardPageState extends ConsumerState<KanbanBoardPage> {
  final ScrollController _boardScrollController = ScrollController();

  void _showSnack(String message) {
    showAppSnack(message);
  }

  @override
  void dispose() {
    _boardScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kanbanControllerProvider.notifier).loadBoard(projectId: widget.projectId);
    });
  }

  Future<void> _reload() {
    return ref.read(kanbanControllerProvider.notifier).loadBoard(
          projectId: widget.projectId,
          forceReload: true,
        );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không deadline';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  void _autoScrollByPointer(double globalDx) {
    if (!_boardScrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    const edgeThreshold = 72.0;
    const maxStep = 22.0;

    double delta = 0;
    if (globalDx < edgeThreshold) {
      final intensity = ((edgeThreshold - globalDx) / edgeThreshold).clamp(0.0, 1.0);
      delta = -maxStep * intensity;
    } else if (globalDx > screenWidth - edgeThreshold) {
      final intensity =
          ((globalDx - (screenWidth - edgeThreshold)) / edgeThreshold).clamp(0.0, 1.0);
      delta = maxStep * intensity;
    }

    if (delta == 0) return;

    final position = _boardScrollController.position;
    final nextOffset =
        (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((nextOffset - position.pixels).abs() > 0.5) {
      _boardScrollController.jumpTo(nextOffset);
    }
  }

  Color _statusColor(BuildContext context, int position) {
    final scheme = Theme.of(context).colorScheme;
    final palette = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.primaryContainer,
      scheme.secondaryContainer,
    ];

    final index = (position <= 0 ? 0 : position - 1) % palette.length;
    return palette[index];
  }

  Future<void> _showCreateStatusDialog() async {
    final statusName = await showDialog<String>(
      context: context,
      builder: (_) => const CreateStatusDialog(),
    );

    if (!mounted || statusName == null) return;

    final success = await ref
        .read(kanbanControllerProvider.notifier)
        .createStatus(projectId: widget.projectId, name: statusName);

    if (!mounted) return;
    final state = ref.read(kanbanControllerProvider);
    _showSnack(
      success
          ? 'Tạo status thành công'
          : (state.errorMessage ?? 'Không thể tạo status'),
    );
  }

  Future<void> _moveTask({
    required KanbanTaskCard task,
    required String statusId,
  }) async {
    if (task.statusId == statusId) return;

    final success = await ref.read(kanbanControllerProvider.notifier).moveTaskToStatus(
          projectId: widget.projectId,
          taskId: task.id,
          statusId: statusId,
        );

    if (!mounted) return;
    if (!success) {
      final state = ref.read(kanbanControllerProvider);
      _showSnack(state.errorMessage ?? 'Không thể di chuyển task');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kanbanControllerProvider);
    final colors = AppBackground.colors(Theme.of(context).brightness);
    final board = state.board;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.projectName?.isNotEmpty == true
              ? 'Kanban - ${widget.projectName}'
              : 'Kanban Board',
        ),
        actions: [
          IconButton(
            onPressed: state.isSubmitting ? null : _showCreateStatusDialog,
            icon: const Icon(Icons.add_chart_rounded),
            tooltip: 'Tạo status',
          ),
          IconButton(
            onPressed: _reload,
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
          child: state.isLoading && board == null
              ? const TabSkeletonView(cardCount: 3)
              : state.errorMessage != null && board == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                        style: GlassCardStyle.liquid,
                        child: ErrorStateView(
                          title: 'Không thể tải Kanban',
                          message: state.errorMessage!,
                          actionLabel: 'Thử lại',
                          onAction: _reload,
                        ),
                      ),
                    )
                  : board == null || board.columns.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: GlassCard(
                            style: GlassCardStyle.liquid,
                            child: EmptyStateView(
                              icon: Icons.view_kanban_outlined,
                              title: 'Chưa có cột Kanban',
                              message: 'Tạo status mới để bắt đầu quản lý board.',
                              actionLabel: 'Tạo status',
                              onAction: _showCreateStatusDialog,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final columnWidth =
                                (constraints.maxWidth - 48).clamp(260.0, 420.0).toDouble();

                            return ListView.builder(
                              controller: _boardScrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                              itemCount: board.columns.length,
                              itemBuilder: (context, index) {
                                final column = board.columns[index];
                                final statusColor = _statusColor(context, column.position);

                                return SizedBox(
                                  width: columnWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: GlassCard(
                                      style: GlassCardStyle.liquid,
                                      child: DragTarget<KanbanTaskCard>(
                                        onWillAcceptWithDetails: (details) {
                                          final incoming = details.data;
                                          return incoming.statusId != column.id;
                                        },
                                        onAcceptWithDetails: (details) {
                                          _moveTask(task: details.data, statusId: column.id);
                                        },
                                        builder: (context, candidateData, rejectedData) {
                                          final isHovering = candidateData.isNotEmpty;
                                          final hasRejected = rejectedData.isNotEmpty;

                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 160),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  statusColor.withValues(alpha: 0.18),
                                                  statusColor.withValues(alpha: 0.07),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: statusColor.withValues(
                                                  alpha: isHovering ? 0.66 : 0.28,
                                                ),
                                                width: isHovering ? 1.8 : 1.2,
                                              ),
                                              color: statusColor.withValues(
                                                alpha: isHovering
                                                    ? 0.15
                                                    : (hasRejected ? 0.11 : 0.08),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: statusColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        column.name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(999),
                                                        color: statusColor.withValues(
                                                          alpha: 0.2,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${column.tasks.length}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                if (column.tasks.isEmpty)
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'Kéo task vào đây',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Expanded(
                                                    child: ListView.separated(
                                                      itemCount: column.tasks.length,
                                                      separatorBuilder:
                                                          (context, itemIndex) =>
                                                              const SizedBox(height: 8),
                                                      itemBuilder: (context, taskIndex) {
                                                        final task =
                                                            column.tasks[taskIndex];
                                                        return Draggable<KanbanTaskCard>(
                                                          data: task,
                                                          maxSimultaneousDrags: 1,
                                                          onDragUpdate: (details) {
                                                            _autoScrollByPointer(
                                                              details.globalPosition.dx,
                                                            );
                                                          },
                                                          feedback: Material(
                                                            color: Colors.transparent,
                                                            child: SizedBox(
                                                              width: columnWidth - 40,
                                                              child: _KanbanTaskCardView(
                                                                task: task,
                                                                formatDate: _formatDate,
                                                              ),
                                                            ),
                                                          ),
                                                          childWhenDragging: Opacity(
                                                            opacity: 0.45,
                                                            child: _KanbanTaskCardView(
                                                              task: task,
                                                              formatDate: _formatDate,
                                                            ),
                                                          ),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius.circular(14),
                                                            onTap: () => context.push(
                                                              '/tasks/${task.id}?projectId=${widget.projectId}&workspaceId=${widget.workspaceId}&projectName=${Uri.encodeComponent(widget.projectName ?? board.projectName)}',
                                                            ),
                                                            child: _KanbanTaskCardView(
                                                              task: task,
                                                              formatDate: _formatDate,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

class _KanbanTaskCardView extends StatelessWidget {
  const _KanbanTaskCardView({
    required this.task,
    required this.formatDate,
  });

  final KanbanTaskCard task;
  final String Function(DateTime?) formatDate;

  String _priorityLabel(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return 'High';
      case 'low':
        return 'Low';
      default:
        return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          StatusChip(
            label: _priorityLabel(task.priority),
            type: task.priority,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
              ),
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.13),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_outlined, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formatDate(task.deadline),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
