import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/features/auth/presentation/pages/profile_page.dart';
import 'package:prm_smart_task/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:prm_smart_task/features/notification/application/providers/notification_providers.dart';
import 'package:prm_smart_task/features/notification/presentation/pages/notification_page.dart';
import 'package:prm_smart_task/features/workspace/presentation/pages/workspace_list_page.dart';
import 'package:prm_smart_task/shared/widgets/glass_card.dart';
import 'package:prm_smart_task/shared/widgets/notification_badge.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _selectedIndex = 0;

  final List<({String label, IconData icon, IconData selectedIcon, Widget page})>
      _tabs = [
    (
      label: 'Dashboard',
      icon: Icons.pie_chart,
      selectedIcon: Icons.pie_chart,
      page: const DashboardPage(),
    ),
    (
      label: 'Workspaces',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      page: const WorkspaceListPage(),
    ),
    (
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      page: const NotificationPage(),
    ),
    (
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      page: const ProfilePage(),
    ),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).refreshUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreadCount = ref.watch(
      notificationControllerProvider.select((state) => state.unreadCount),
    );

    return Scaffold(
      body: _tabs[_selectedIndex].page,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: GlassCard(
          style: GlassCardStyle.liquid,
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: NavigationBar(
            height: 70,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTabSelected,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            indicatorColor: colorScheme.primary.withValues(alpha: 0.22),
            destinations: _tabs
                .asMap()
                .entries
                .map(
                  (entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    final isNotificationTab = index == 2;

                    return NavigationDestination(
                      icon: isNotificationTab
                          ? NotificationBadge(
                              count: unreadCount,
                              child: Icon(tab.icon),
                            )
                          : Icon(tab.icon),
                      selectedIcon: isNotificationTab
                          ? NotificationBadge(
                              count: unreadCount,
                              child: Icon(tab.selectedIcon),
                            )
                          : Icon(tab.selectedIcon),
                      label: tab.label,
                    );
                  },
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
