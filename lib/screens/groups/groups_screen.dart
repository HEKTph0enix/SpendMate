import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/group_card.dart';
import '../../widgets/empty_state.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_icon_button.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          NeumorphicIconButton(
            icon: Icons.search,
            onPressed: () {
              // Search groups (simplified for now)
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<GroupProvider, SettingsProvider>(
        builder: (context, groupProvider, settingsProvider, child) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.groups.isEmpty) {
            return EmptyState(
              icon: Icons.group_outlined,
              title: 'No Groups',
              message: 'Create a group to start splitting expenses with friends.',
              buttonText: 'Create Group',
              onButtonPressed: () => _navigateToCreateGroup(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];
              
              // We need member count and user balance for the card.
              // For a complete implementation, the GroupProvider should probably cache these
              // for the list view, or we use FutureBuilders here. 
              // To keep it clean and fast, we'll use a FutureBuilder for now to fetch stats per group.
              
              return FutureBuilder(
                future: Future.wait([
                  groupProvider.activeGroup?.id == group.id 
                      ? Future.value(groupProvider.activeGroupUsers.length)
                      : Future.value(0), // Simplified: In real app, fetch count from repo
                  groupProvider.activeGroup?.id == group.id
                      ? Future.value(groupProvider.activeGroupBalances[settingsProvider.currentUserId] ?? 0.0)
                      : Future.value(0.0), // Simplified
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  // Fallback values since we aren't pre-fetching all balances for the list in this v1
                  // A full implementation would aggregate these in a SQL query.
                  int memberCount = 0;
                  double userBalance = 0.0;
                  
                  if (snapshot.hasData) {
                    // memberCount = snapshot.data![0];
                    // userBalance = snapshot.data![1];
                  }

                  return GroupCard(
                    group: group,
                    memberCount: 0, // Placeholder for v1 list view
                    userBalance: 0.0, // Placeholder for v1 list view
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailScreen(groupId: group.id),
                        ),
                      ).then((_) {
                        groupProvider.loadGroups();
                      });
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: NeumorphicButton(
          onPressed: () => _navigateToCreateGroup(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.group_add),
              SizedBox(width: 8),
              Text('New Group', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }
}
