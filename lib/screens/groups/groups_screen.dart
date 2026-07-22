import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/neobrutal/neobrutal_card.dart';
import '../../widgets/neobrutal/neobrutal_button.dart';
import '../../utils/date_formatter.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Consumer2<GroupProvider, SettingsProvider>(
        builder: (context, groupProvider, settingsProvider, child) {
          if (groupProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ─── Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Groups',
                            style: AppTextStyles.pageHeading(isDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and split expenses with friends',
                          style: AppTextStyles.cardSubtitle(isDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  NeoBrutalButton(
                    onPressed: () => _navigateToCreateGroup(context),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 6),
                        Text('Create Group'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Content ─────────────────────────────
              if (groupProvider.groups.isEmpty)
                _buildEmptyState(context, isDark)
              else
                ...groupProvider.groups.asMap().entries.map((entry) {
                  final index = entry.key;
                  final group = entry.value;
                  final cardColor = AppColors.getCardAccentColors(isDark)[
                      index % AppColors.getCardAccentColors(isDark).length];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeoBrutalCard(
                      backgroundColor: cardColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GroupDetailScreen(groupId: group.id),
                          ),
                        ).then((_) {
                          groupProvider.loadGroups();
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: AppTextStyles.sectionHeading(isDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.getSurface(isDark),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.getBorder(isDark),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
                          if (group.description != null &&
                              group.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              group.description!,
                              style: AppTextStyles.body(isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            height: 2,
                            color: AppColors.getBorder(isDark),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.group,
                                      size: 16,
                                      color:
                                          AppColors.getTextSecondary(isDark)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Group',
                                    style: AppTextStyles.bodySmall(isDark),
                                  ),
                                ],
                              ),
                              Text(
                                'Updated: ${DateFormatter.formatDateOnly(group.updatedAt)}',
                                style: AppTextStyles.bodySmall(isDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getCardAccentColors(isDark)[0],
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.getBorder(isDark),
                width: AppSpacing.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getBorder(isDark),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.group_outlined,
              size: 56,
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No groups yet',
            style: AppTextStyles.sectionHeading(isDark),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Create a group to start splitting expenses with friends',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(isDark).copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
          const SizedBox(height: 28),
          NeoBrutalButton(
            onPressed: () => _navigateToCreateGroup(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_add, size: 20),
                SizedBox(width: 8),
                Text('Create Group'),
              ],
            ),
          ),
        ],
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
