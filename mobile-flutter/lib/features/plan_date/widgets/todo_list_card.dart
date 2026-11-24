import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';
import '../providers/plan_date_provider.dart';

/// Editable date checklist with animated checkboxes and inline note entry.
class TodoListCard extends ConsumerStatefulWidget {
  const TodoListCard({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<TodoListCard> createState() => _TodoListCardState();
}

class _TodoListCardState extends ConsumerState<TodoListCard> {
  final _controller = TextEditingController();
  final _noteFocus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(planDateProvider(widget.chatId));
    final notifier = ref.read(planDateProvider(widget.chatId).notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.all(Radius.circular(PDRadius.card)),
        border: Border.fromBorderSide(BorderSide(color: PDColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text("To Do's", style: PDTextStyles.sectionTitle),
              const SizedBox(width: 8),
              Text(
                draft.todoProgress,
                style: const TextStyle(
                  color: PDColors.chooserPink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: draft.todoEditMode ? 'Done editing to-dos' : 'Edit to-dos',
                child: GestureDetector(
                  onTap: () =>
                      notifier.setTodoEditMode(!draft.todoEditMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: PDColors.gradientPink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: PDColors.gradientPink.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          draft.todoEditMode ? Icons.check : Icons.edit_outlined,
                          size: 14,
                          color: PDColors.chooserPink,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          draft.todoEditMode ? 'Done' : 'Edit',
                          style: const TextStyle(
                            color: PDColors.chooserPink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (draft.todos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Add a note to get started.',
                style: PDTextStyles.muted,
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < draft.todos.length; i++)
                  _TodoRow(
                    todo: draft.todos[i],
                    editMode: draft.todoEditMode,
                    onToggle: () => notifier.toggleTodo(draft.todos[i].id),
                    onDelete: () => notifier.deleteTodo(draft.todos[i].id),
                    onMoveUp: i > 0
                        ? () => notifier.reorderTodo(i, i - 1)
                        : null,
                    onMoveDown: i < draft.todos.length - 1
                        ? () => notifier.reorderTodo(i, i + 1)
                        : null,
                  ),
              ],
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Add to-do note',
                child: GestureDetector(
                  onTap: () => _noteFocus.requestFocus(),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: PDColors.gradientPink,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _noteFocus,
                  style: const TextStyle(
                    color: PDColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a new to-do note...',
                    hintStyle: const TextStyle(
                      color: PDColors.textMuted,
                      fontSize: 12.5,
                    ),
                    filled: true,
                    fillColor: PDColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PDColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PDColors.inputBorder),
                    ),
                  ),
                  onSubmitted: (_) => _addTodo(notifier),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: 'Send new to-do',
                child: GestureDetector(
                  onTap: () => _addTodo(notifier),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: PDGradients.selection,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, size: 17, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addTodo(PlanDateNotifier notifier) {
    notifier.addTodo(_controller.text);
    _controller.clear();
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    required this.todo,
    required this.editMode,
    required this.onToggle,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final TodoItem todo;
  final bool editMode;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Semantics(
            button: true,
            checked: todo.done,
            label: todo.text,
            child: GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: todo.done ? PDGradients.selection : null,
                  color: todo.done ? null : PDColors.controlFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: todo.done
                        ? PDColors.gradientPink
                        : PDColors.inputBorder,
                  ),
                ),
                child: AnimatedScale(
                  scale: todo.done ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              todo.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: todo.done ? PDColors.disabledText : PDColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                decoration: todo.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (editMode) ...[
            _MiniIconButton(
              icon: Icons.keyboard_arrow_up,
              label: 'Move ${todo.text} up',
              enabled: onMoveUp != null,
              onTap: onMoveUp,
            ),
            _MiniIconButton(
              icon: Icons.keyboard_arrow_down,
              label: 'Move ${todo.text} down',
              enabled: onMoveDown != null,
              onTap: onMoveDown,
            ),
            _MiniIconButton(
              icon: Icons.delete_outline,
              label: 'Delete ${todo.text}',
              enabled: true,
              onTap: onDelete,
              color: PDColors.chooserPink,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.color = PDColors.textMuted,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 18, color: color),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: kMinTouchTarget,
        ),
        padding: EdgeInsets.zero,
        tooltip: label,
      ),
    );
  }
}
