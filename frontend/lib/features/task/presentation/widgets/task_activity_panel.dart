import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';

class TaskActivityPanel extends ConsumerStatefulWidget {
  const TaskActivityPanel({super.key, required this.taskId});
  final String taskId;
  @override
  ConsumerState<TaskActivityPanel> createState() => _TaskActivityPanelState();
}

class _TaskActivityPanelState extends ConsumerState<TaskActivityPanel> {
  final List<Map<String, dynamic>> _items = [];
  bool _loading = false, _last = false;
  String? _error;
  bool _retryReset = false;
  int _page = 0;
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _retryReset = reset;
    });
    final page = reset ? 0 : _page;
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '/api/tasks/${widget.taskId}/activities',
            queryParameters: {'page': page},
          );
      final data = response.data as Map<String, dynamic>;
      final entries = (data['content'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(entries);
        _page = page + 1;
        _last = data['last'] == true;
      });
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Không tải được lịch sử. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _value(dynamic value, String field) {
    if (value == null || value.toString().isEmpty) return 'Chưa có';
    final text = value.toString();
    if (field == 'status')
      return text.replaceFirst(RegExp(r' \[[^\]]+\]$'), '');
    if (field == 'deadline') return _date(text);
    return text;
  }

  String _date(String text) {
    final date = DateTime.tryParse(text)?.toLocal();
    if (date == null) return text;
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const labels = {
      'title': 'Tiêu đề',
      'description': 'Mô tả',
      'assignees': 'Người phụ trách',
      'deadline': 'Deadline',
      'status': 'Trạng thái',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lịch sử hoạt động',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Làm mới lịch sử',
                  onPressed: _loading ? null : () => _load(reset: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (_items.isEmpty && !_loading && _error == null)
              const Text('Chưa có thay đổi được ghi nhận.'),
            for (final event in _items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event['actorName']} • ${_date(event['createdAt'].toString())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      labels[event['field']] ?? event['field'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SelectableText(
                      'Trước: ${_value(event['oldValue'], event['field'])}\nSau: ${_value(event['newValue'], event['field'])}',
                    ),
                    const Divider(),
                  ],
                ),
              ),
            if (_error != null) Text(_error!),
            if (_loading) const LinearProgressIndicator(),
            if (!_loading && _error != null)
              TextButton(
                onPressed: () => _load(reset: _retryReset),
                child: const Text('Thử lại'),
              ),
            if (!_loading && !_last && _error == null && _items.isNotEmpty)
              TextButton(
                onPressed: () => _load(),
                child: const Text('Xem thêm'),
              ),
          ],
        ),
      ),
    );
  }
}
