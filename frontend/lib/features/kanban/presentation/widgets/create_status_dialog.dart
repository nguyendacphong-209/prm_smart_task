import 'package:flutter/material.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';

class CreateStatusDialog extends StatefulWidget {
  const CreateStatusDialog({super.key});

  @override
  State<CreateStatusDialog> createState() => _CreateStatusDialogState();
}

class _CreateStatusDialogState extends State<CreateStatusDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo status mới'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Tên status',
          prefixIcon: Icon(Icons.add_card_outlined),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.length < 2) {
              showAppSnack('Tên status tối thiểu 2 ký tự');
              return;
            }
            Navigator.of(context).pop(name);
          },
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}