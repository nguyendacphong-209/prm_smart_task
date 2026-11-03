import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:prm_smart_task/core/network/dio_client.dart';

class LabelManagementPage extends ConsumerStatefulWidget {
  const LabelManagementPage({super.key, required this.projectId});
  final String projectId;
  @override
  ConsumerState<LabelManagementPage> createState() =>
      _LabelManagementPageState();
}

class _LabelManagementPageState extends ConsumerState<LabelManagementPage> {
  List<Map<String, dynamic>> _labels = [];
  bool _loading = true;
  String? _error;
  String get _path => '/api/projects/${widget.projectId}/labels';
  @override
  void initState() {
    super.initState();
    _load();
  }

  String _message(Object error) {
    if (error is DioException) {
      if (error.response?.statusCode == 403) {
        return 'Chỉ chủ workspace hoặc admin được quản lý nhãn.';
      }
      if (error.response?.statusCode == 401) {
        return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';
      }
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return 'Không kết nối được máy chủ. Vui lòng thử lại.';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ref.read(dioProvider).get(_path);
      final labels = (response.data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (mounted) {
        setState(() => _labels = labels);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = _message(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Color _color(String? hex) => Color(
    0xFF000000 |
        (int.tryParse((hex ?? '').replaceFirst('#', ''), radix: 16) ??
            0x607D8B),
  );

  Future<void> _edit([Map<String, dynamic>? label]) async {
    final name = TextEditingController(text: label?['name'] as String? ?? '');
    final color = TextEditingController(
      text: label?['color'] as String? ?? '#2196F3',
    );
    final form = GlobalKey<FormState>();
    bool saving = false;
    String? error;
    final route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            title: Text(label == null ? 'Tạo nhãn' : 'Sửa nhãn'),
            content: SizedBox(
              width: 380,
              child: Form(
                key: form,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: name,
                        enabled: !saving,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          labelText: 'Tên nhãn',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Nhập tên nhãn'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: color,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Mã màu',
                          hintText: '#2196F3',
                        ),
                        onChanged: (_) => update(() {}),
                        validator: (v) =>
                            RegExp(
                              r'^#[0-9a-fA-F]{6}$',
                            ).hasMatch(v?.trim() ?? '')
                            ? null
                            : 'Nhập mã màu dạng #RRGGBB',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final hex in [
                            '#2196F3',
                            '#F44336',
                            '#4CAF50',
                            '#FF9800',
                            '#9C27B0',
                            '#607D8B',
                          ])
                            IconButton(
                              tooltip: hex,
                              onPressed: saving
                                  ? null
                                  : () => update(() => color.text = hex),
                              icon: Icon(
                                color.text.toUpperCase() == hex
                                    ? Icons.check_circle
                                    : Icons.circle,
                                color: _color(hex),
                              ),
                            ),
                        ],
                      ),
                      Chip(
                        avatar: Icon(Icons.label, color: _color(color.text)),
                        label: const Text('Màu nhãn'),
                      ),
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) {
                          return;
                        }
                        update(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          final data = {
                            'name': name.text.trim(),
                            'color': color.text.trim().toUpperCase(),
                          };
                          final dio = ref.read(dioProvider);
                          if (label == null) {
                            await dio.post(_path, data: data);
                          } else {
                            await dio.put('$_path/${label['id']}', data: data);
                          }
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            update(() {
                              saving = false;
                              error = _message(e);
                            });
                          }
                        }
                      },
                child: Text(saving ? 'Đang lưu…' : 'Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
    final saved = await Navigator.of(context).push(route);
    await route.completed;
    name.dispose();
    color.dispose();
    if (saved == true && mounted) {
      await _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhãn?'),
        content: Text(
          'Xóa nhãn "${label['name']}" khỏi project và các task đang dùng. Task vẫn được giữ. Không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa nhãn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(dioProvider).delete('$_path/${label['id']}');
      if (mounted) {
        await _load();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_message(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quản lý nhãn'),
      actions: [
        IconButton(
          tooltip: 'Làm mới',
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _loading ? null : () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Tạo nhãn'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!),
                TextButton(onPressed: _load, child: const Text('Thử lại')),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const Text(
                'Chủ workspace hoặc admin có thể tạo, sửa và xóa nhãn.',
              ),
              const SizedBox(height: 12),
              if (_labels.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Chưa có nhãn. Tạo nhãn đầu tiên cho project.'),
                ),
              for (final label in _labels)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.label,
                      color: _color(label['color'] as String?),
                    ),
                    title: Text(label['name'] as String? ?? ''),
                    subtitle: Text(label['color'] as String? ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Sửa nhãn',
                          onPressed: () => _edit(label),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Xóa nhãn',
                          onPressed: () => _delete(label),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );
}
