import 'package:flutter/material.dart';
import 'package:prm_smart_task/core/theme/app_messenger.dart';

class InviteMemberPayload {
  const InviteMemberPayload({required this.email, required this.role});

  final String email;
  final String role;
}

class InviteMemberDialog extends StatefulWidget {
  const InviteMemberDialog({super.key});

  @override
  State<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<InviteMemberDialog> {
  final TextEditingController _emailController = TextEditingController();
  String _role = 'member';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mời thành viên'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(
              labelText: 'Vai trò',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'member', child: Text('Member')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (value) {
              setState(() {
                _role = value ?? 'member';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            final email = _emailController.text.trim();
            if (email.isEmpty || !email.contains('@')) {
              showAppSnack('Email không hợp lệ');
              return;
            }

            Navigator.of(context).pop(
              InviteMemberPayload(
                email: email,
                role: _role,
              ),
            );
          },
          child: const Text('Mời'),
        ),
      ],
    );
  }
}