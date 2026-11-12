// ─────────────────────────────────────────────────────────────────────────────
// To Do List Widget
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/plan_date_model.dart';
import '../plan_date_theme.dart';

class TodoList extends StatefulWidget {
  final List<TodoItem> todos;
  final bool editMode;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;
  final VoidCallback onToggleEditMode;

  const TodoList({
    super.key,
    required this.todos,
    required this.editMode,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
    required this.onToggleEditMode,
  });

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = widget.todos.where((t) => t.done).length;
    final total = widget.todos.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PDColors.card,
        borderRadius: BorderRadius.circular(PDRadius.card),
        border: Border.all(color: PDColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To Do\'s', style: PDTextStyles.sectionTitle),
                    if (total > 0)
                      Text(
                        '$doneCount of $total done',
                        style: PDTextStyles.muted.copyWith(
                          color: doneCount == total && total > 0
                              ? PDColors.textSuccess
                              : PDColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Semantics(
                label: widget.editMode ? 'Done editing to-dos' : 'Edit to-dos',
                button: true,
                child: TextButton(
                  onPressed: widget.onToggleEditMode,
                  style: TextButton.styleFrom(
                    foregroundColor: PDColors.textViolet,
                    minimumSize: const Size(kMinTouchTarget, kMinTouchTarget),
                  ),
                  child: Text(
                    widget.editMode ? 'Done' : 'Edit',
                    style: PDTextStyles.accent.copyWith(color: PDColors.textViolet),
                  ),
                ),
              ),
            ],
          ),
          if (widget.todos.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...widget.todos.map((todo) => _buildTodoRow(todo)),
          ],
          const SizedBox(height: 12),
          _buildAddInput(),
        ],
      ),
    );
  }

  Widget _buildTodoRow(TodoItem todo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Semantics(
            label: todo.done ? 'Mark ${todo.text} undone' : 'Mark ${todo.text} done',
            button: true,
            child: InkWell(
              onTap: () => widget.onToggle(todo.id),
              borderRadius: BorderRadius.circular(PDRadius.avatar),
              child: Container(
                width: kMinTouchTarget,
                height: kMinTouchTarget,
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: todo.done ? PDGradients.primary : null,
                    color: todo.done ? null : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: todo.done
                          ? Colors.transparent
                          : PDColors.chipBorder,
                      width: 1.5,
                    ),
                  ),
                  child: todo.done
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              todo.text,
              style: PDTextStyles.body.copyWith(
                decoration: todo.done ? TextDecoration.lineThrough : null,
                color: todo.done
                    ? PDColors.textMuted
                    : PDColors.textPrimary,
              ),
            ),
          ),
          if (widget.editMode) ...[
            const SizedBox(width: 8),
            Semantics(
              label: 'Delete ${todo.text}',
              button: true,
              child: InkWell(
                onTap: () => widget.onDelete(todo.id),
                borderRadius: BorderRadius.circular(PDRadius.avatar),
                child: Container(
                  width: kMinTouchTarget,
                  height: kMinTouchTarget,
                  alignment: Alignment.center,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1020),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PDColors.textAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(Icons.close, size: 14, color: PDColors.textAccent),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddInput() {
    return Container(
      height: kMinTouchTarget,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: PDColors.inputFill,
        borderRadius: BorderRadius.circular(PDRadius.input),
        border: Border.all(color: PDColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, size: 18, color: PDColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: PDTextStyles.body,
              onSubmitted: (val) {
                widget.onAdd(val);
                _ctrl.clear();
              },
              decoration: const InputDecoration(
                hintText: 'Add a new to-do note...',
                hintStyle: TextStyle(color: PDColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Semantics(
            label: 'Add to-do',
            button: true,
            child: InkWell(
              onTap: () {
                widget.onAdd(_ctrl.text);
                _ctrl.clear();
              },
              borderRadius: BorderRadius.circular(PDRadius.chip),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.send_rounded, size: 18, color: PDColors.textViolet),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

