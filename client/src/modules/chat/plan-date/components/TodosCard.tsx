import React, { useState } from 'react';
import { Check, Pencil, Trash2, Plus } from 'lucide-react';
import { planDateTheme } from '../theme';
import { TodoItem } from '../types';

interface TodosCardProps {
  todos: TodoItem[];
  onTodosChange: (todos: TodoItem[]) => void;
}

export const TodosCard: React.FC<TodosCardProps> = ({ todos, onTodosChange }) => {
  const [editMode, setEditMode] = useState(false);
  const [newTodoText, setNewTodoText] = useState('');

  const toggleTodo = (id: string | number) => {
    if (editMode) return;
    const updated = todos.map((todo) =>
      todo.id === id ? { ...todo, done: !todo.done } : todo
    );
    onTodosChange(updated);
  };

  const deleteTodo = (id: string | number) => {
    const updated = todos.filter((todo) => todo.id !== id);
    onTodosChange(updated);
  };

  const addTodo = () => {
    if (!newTodoText.trim()) return;
    const newTodo: TodoItem = {
      id: Date.now(),
      text: newTodoText.trim(),
      done: false,
    };
    onTodosChange([...todos, newTodo]);
    setNewTodoText('');
  };

  const doneCount = todos.filter((t) => t.done).length;
  const totalCount = todos.length;

  return (
    <div
      style={{
        backgroundColor: planDateTheme.colors.card,
        border: `1px solid ${planDateTheme.colors.cardBorder}`,
        borderRadius: `${planDateTheme.borderRadius.card}px`,
        padding: `${planDateTheme.spacing.cardPadding}px`,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '12px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <h3
            style={{
              fontSize: '16px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.text,
              margin: 0,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            To Do's
          </h3>
          <span
            style={{
              fontSize: '12px',
              fontWeight: planDateTheme.typography.weights.bold,
              color: planDateTheme.colors.accentText,
              fontFamily: planDateTheme.typography.fontFamily,
            }}
          >
            {doneCount} of {totalCount} done
          </span>
        </div>
        <button
          onClick={() => setEditMode(!editMode)}
          aria-label={editMode ? 'Done editing' : 'Edit todos'}
          style={{
            height: '44px',
            borderRadius: `${planDateTheme.borderRadius.inner}px`,
            background: editMode ? planDateTheme.gradients.primary : planDateTheme.colors.raisedButton,
            border: editMode ? 'none' : `1px solid ${planDateTheme.colors.raisedButtonBorder}`,
            color: editMode ? '#FFFFFF' : planDateTheme.colors.accentPink4,
            fontSize: '14px',
            fontWeight: planDateTheme.typography.weights.semibold,
            fontFamily: planDateTheme.typography.fontFamily,
            padding: '0 16px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
          }}
        >
          {editMode ? (
            'Done'
          ) : (
            <>
              <Pencil size={16} />
              Edit
            </>
          )}
        </button>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '10px' }}>
        {todos.map((todo) => (
          <div
            key={todo.id}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              minHeight: `${planDateTheme.sizes.todoRowMinHeight}px`,
              padding: '4px 0',
            }}
          >
            {!editMode && (
              <button
                onClick={() => toggleTodo(todo.id)}
                aria-label={todo.done ? 'Mark as undone' : 'Mark as done'}
                style={{
                  width: `${planDateTheme.sizes.checkbox}px`,
                  height: `${planDateTheme.sizes.checkbox}px`,
                  borderRadius: '9px',
                  background: todo.done ? planDateTheme.gradients.primary : 'transparent',
                  border: todo.done ? 'none' : `1.5px solid #6B5C80`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  flexShrink: 0,
                  padding: 0,
                  minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                  minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
                }}
              >
                {todo.done && <Check size={14} color="#FFFFFF" strokeWidth={3} />}
              </button>
            )}

            <span
              style={{
                flex: 1,
                fontSize: '15px',
                fontWeight: planDateTheme.typography.weights.semibold,
                color: todo.done && !editMode ? planDateTheme.colors.muted : planDateTheme.colors.text,
                textDecoration: todo.done && !editMode ? 'line-through' : 'none',
                fontFamily: planDateTheme.typography.fontFamily,
              }}
            >
              {todo.text}
            </span>

            {editMode && (
              <button
                onClick={() => deleteTodo(todo.id)}
                aria-label="Delete todo"
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: `${planDateTheme.borderRadius.inner}px`,
                  backgroundColor: '#2A1522',
                  border: `1px solid #4A2A3E`,
                  color: planDateTheme.colors.accentPink4,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  flexShrink: 0,
                  padding: 0,
                  minWidth: `${planDateTheme.sizes.minTouchTarget}px`,
                  minHeight: `${planDateTheme.sizes.minTouchTarget}px`,
                }}
              >
                <Trash2 size={18} />
              </button>
            )}
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
        <div
          style={{
            flex: 1,
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            height: '48px',
            borderRadius: `${planDateTheme.borderRadius.inner}px`,
            backgroundColor: planDateTheme.colors.innerField,
            border: '1px dashed #4A3A5E',
            padding: '0 12px',
          }}
        >
          <Plus size={18} color={planDateTheme.colors.accentText} />
          <input
            type="text"
            value={newTodoText}
            onChange={(e) => setNewTodoText(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && newTodoText.trim() && addTodo()}
            placeholder="Add a new to-do note..."
            style={{
              flex: 1,
              backgroundColor: 'transparent',
              border: 'none',
              color: planDateTheme.colors.text,
              fontSize: '14px',
              fontFamily: planDateTheme.typography.fontFamily,
              outline: 'none',
            }}
          />
        </div>
        <button
          onClick={addTodo}
          disabled={!newTodoText.trim()}
          aria-label="Add todo"
          style={{
            width: '48px',
            height: '48px',
            borderRadius: '12px',
            background: newTodoText.trim() ? 'linear-gradient(135deg, #e91e8c 0%, #a21caf 100%)' : planDateTheme.colors.idleChip,
            border: 'none',
            color: '#FFFFFF',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: newTodoText.trim() ? 'pointer' : 'not-allowed',
            padding: 0,
            flexShrink: 0,
            opacity: newTodoText.trim() ? 1 : 0.5,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="22" y1="2" x2="11" y2="13"></line>
            <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
          </svg>
        </button>
      </div>
    </div>
  );
};
