import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';

enum TimerMode {
  stopwatch,
  pomodoro,
}

class TaskTimeTrackerWidget extends StatefulWidget {
  const TaskTimeTrackerWidget({
    super.key,
    required this.taskId,
    this.initialEstimatedHours = 4.0,
    this.onTimeRecorded,
  });

  final String taskId;
  final double initialEstimatedHours;
  final void Function(double totalActualHours)? onTimeRecorded;

  @override
  State<TaskTimeTrackerWidget> createState() => _TaskTimeTrackerWidgetState();
}

class _TaskTimeTrackerWidgetState extends State<TaskTimeTrackerWidget> {
  TimerMode _mode = TimerMode.stopwatch;

  // Timer states
  Timer? _timer;
  bool _isRunning = false;
  int _elapsedSeconds = 0; // Total accumulated working seconds
  int _pomodoroRemainingSeconds = 25 * 60; // 25 minutes for Pomodoro

  // Stats
  late double _estimatedHours;

  @override
  void initState() {
    super.initState();
    _estimatedHours = widget.initialEstimatedHours;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;

        if (_mode == TimerMode.pomodoro) {
          if (_pomodoroRemainingSeconds > 0) {
            _pomodoroRemainingSeconds--;
          } else {
            _pauseTimer();
            showAppSnack('🎉 Hết 25 phút Pomodoro! Hãy nghỉ giải lao 5 phút nào.');
            _pomodoroRemainingSeconds = 25 * 60; // Reset Pomodoro session
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _elapsedSeconds = 0;
      _pomodoroRemainingSeconds = 25 * 60;
    });
    showAppSnack('Đã đặt lại bộ đếm thời gian');
  }

  void _saveTime() {
    final actualHours = _elapsedSeconds / 3600.0;
    widget.onTimeRecorded?.call(actualHours);
    showAppSnack('Đã lưu thời gian làm việc: ${_formatHours(actualHours)}!');
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatHours(double hours) {
    if (hours < 0.1) {
      final mins = (hours * 60).round();
      return '$mins phút';
    }
    return '${hours.toStringAsFixed(1)} giờ';
  }

  Widget _buildEfficiencyBadge(double actualHours) {
    if (actualHours <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Chưa bấm giờ làm việc',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    final diffHours = _estimatedHours - actualHours;
    final efficiencyPercent = (_estimatedHours / actualHours) * 100;

    final isFaster = diffHours >= 0;
    final badgeColor = isFaster ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFaster ? Icons.speed : Icons.warning_amber_rounded,
                size: 18,
                color: badgeColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Hiệu suất: ${efficiencyPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isFaster
                ? '🎉 Hoàn thành tốt! Nhanh hơn dự kiến ${_formatHours(diffHours.abs())}'
                : '⚠️ Đã vượt quá thời gian dự kiến ${_formatHours(diffHours.abs())}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actualHours = _elapsedSeconds / 3600.0;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Mode Selector
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Bộ đếm thời gian & Pomodoro',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SegmentedButton<TimerMode>(
                segments: const [
                  ButtonSegment(
                    value: TimerMode.stopwatch,
                    label: Text('Đếm giờ'),
                    icon: Icon(Icons.timer_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: TimerMode.pomodoro,
                    label: Text('25m Pomodoro'),
                    icon: Icon(Icons.local_fire_department, size: 16),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  _pauseTimer();
                  setState(() {
                    _mode = selection.first;
                  });
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Digital Timer Display
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isRunning
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRunning
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: _isRunning ? 2 : 1,
                ),
                boxShadow: _isRunning
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    _mode == TimerMode.stopwatch
                        ? _formatDuration(_elapsedSeconds)
                        : _formatDuration(_pomodoroRemainingSeconds),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _isRunning ? theme.colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isRunning
                        ? (_mode == TimerMode.pomodoro
                            ? '🔥 Đang tập trung Pomodoro...'
                            : '⚡ Đang bấm giờ làm việc...')
                        : 'Sẵn sàng bắt đầu',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _isRunning ? theme.colorScheme.primary : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                FilledButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Bắt đầu làm'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause_rounded),
                  label: const Text('Tạm dừng'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Đặt lại'),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Lưu thời gian làm',
                icon: const Icon(Icons.save_outlined),
                onPressed: actualHours > 0 ? _saveTime : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comparison Section: Estimated vs Actual Hours
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 Dự kiến (AI / Plan)',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatHours(_estimatedHours),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⏱️ Thực tế (Actual)',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatHours(actualHours),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Efficiency Feedback Badge
          _buildEfficiencyBadge(actualHours),
        ],
      ),
    );
  }
}
