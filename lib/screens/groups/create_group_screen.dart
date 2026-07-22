import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/expense_group.dart';
import '../../models/user.dart';
import '../../providers/group_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/neobrutal/neobrutal_text_field.dart';
import '../../widgets/neobrutal/neobrutal_icon_button.dart';

class CreateGroupScreen extends StatefulWidget {
  final ExpenseGroup? groupToEdit;

  const CreateGroupScreen({super.key, this.groupToEdit});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _memberController = TextEditingController();

  final List<User> _members = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    // Add current user by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (settings.currentUser != null && _members.isEmpty) {
        setState(() {
          _members.add(settings.currentUser!);
        });
      }

      if (widget.groupToEdit != null) {
        _nameController.text = widget.groupToEdit!.name;
        _descController.text = widget.groupToEdit!.description ?? '';

        // In a real app, we would fetch the actual group members here
        // For now, it relies on the group provider's active users if editing from detail screen
        final groupProvider =
            Provider.of<GroupProvider>(context, listen: false);
        if (groupProvider.activeGroup?.id == widget.groupToEdit!.id) {
          setState(() {
            _members.clear();
            _members.addAll(groupProvider.activeGroupUsers);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberController.text.trim();
    if (name.isEmpty) return;

    // Check for duplicates
    if (_members.any((m) => m.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member "$name" already added')),
      );
      return;
    }

    setState(() {
      _members.add(User(
        id: _uuid.v4(),
        name: name,
        isCurrentUser: false,
      ));
      _memberController.clear();
    });
  }

  void _removeMember(int index) {
    // Prevent removing current user
    if (_members[index].isCurrentUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You cannot remove yourself from the group')),
      );
      return;
    }

    setState(() {
      _members.removeAt(index);
    });
  }

  void _saveGroup() async {
    if (_formKey.currentState!.validate()) {
      if (_members.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A group needs at least 2 members')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final group = ExpenseGroup(
        id: widget.groupToEdit?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        createdDate: widget.groupToEdit?.createdDate,
      );

      final provider = Provider.of<GroupProvider>(context, listen: false);

      if (widget.groupToEdit != null) {
        await provider.updateGroup(group, _members);
      } else {
        await provider.addGroup(group, _members);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.groupToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Group' : 'Create Group'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveGroup,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Group Name
            NeoBrutalTextField(
              controller: _nameController,
              labelText: 'Group Name',
              prefixIcon: const Icon(Icons.group),
              textCapitalization: TextCapitalization.words,
              validator: Validators.groupName,
            ),
            const SizedBox(height: 24),

            // Description
            NeoBrutalTextField(
              controller: _descController,
              labelText: 'Description (Optional)',
              prefixIcon: const Icon(Icons.description),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Members Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Group Members',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  '${_members.length} members',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add Member Input
            Row(
              children: [
                Expanded(
                  child: NeoBrutalTextField(
                    controller: _memberController,
                    labelText: 'Add a person',
                    hintText: 'e.g., Arun',
                    prefixIcon: const Icon(Icons.person_add),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addMember(),
                  ),
                ),
                const SizedBox(width: 12),
                NeoBrutalIconButton(
                  onPressed: _addMember,
                  icon: Icons.add,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Member List
            ...List.generate(_members.length, (index) {
              final member = _members[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    member.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(member.name),
                subtitle: member.isCurrentUser ? const Text('You') : null,
                trailing: member.isCurrentUser
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: theme.colorScheme.error,
                        onPressed: () => _removeMember(index),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
