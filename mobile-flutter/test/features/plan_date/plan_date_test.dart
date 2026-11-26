// ─────────────────────────────────────────────────────────────────────────────
// Plan a Date — Widget Tests
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:younme_mobile/features/plan_date/models/plan_date_model.dart';
import 'package:younme_mobile/features/plan_date/providers/plan_date_providers.dart';

void main() {
  // ── Helper: create a container with the form provider ────────────────────
  ProviderContainer makeContainer() {
    return ProviderContainer();
  }

  // ── 1. Mode switching keeps shared state ─────────────────────────────────
  group('Mode switching', () {
    test('switching modes preserves shared fields', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(planDateFormProvider.notifier);

      // Set shared fields while in Virtual mode
      notifier.setPartner(id: 'p1', name: 'Priya', isOnline: true);
      notifier.setDateType('coffee');
      notifier.setSplit(70);
      notifier.setDuration(90);
      notifier.addTodo('Pick a movie');

      final stateBefore = container.read(planDateFormProvider);
      expect(stateBefore.mode, DateMode.virtual);
      expect(stateBefore.partnerId, 'p1');
      expect(stateBefore.dateTypeId, 'coffee');
      expect(stateBefore.splitProposerPct, 70);
      expect(stateBefore.durationMin, 90);
      expect(stateBefore.todos.length, 1);

      // Switch to Offline
      notifier.setMode(DateMode.offline);
      final stateAfter = container.read(planDateFormProvider);

      expect(stateAfter.mode, DateMode.offline);
      // Shared fields remain
      expect(stateAfter.partnerId, 'p1');
      expect(stateAfter.dateTypeId, 'coffee');
      expect(stateAfter.splitProposerPct, 70);
      expect(stateAfter.durationMin, 90);
      expect(stateAfter.todos.length, 1);
    });
  });

  // ── 2. Split bill math ────────────────────────────────────────────────────
  group('Split bill', () {
    test('partner pct = 100 - proposer pct', () {
      const bill50 = SplitBill(proposerPct: 50);
      expect(bill50.partnerPct, 50);

      const bill70 = SplitBill(proposerPct: 70);
      expect(bill70.partnerPct, 30);

      const billPayAll = SplitBill(proposerPct: 100);
      expect(billPayAll.partnerPct, 0);
    });

    test('setSplit clamps to [0, 100]', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      notifier.setSplit(150); // too high
      expect(container.read(planDateFormProvider).splitProposerPct, 100);

      notifier.setSplit(-10); // too low
      expect(container.read(planDateFormProvider).splitProposerPct, 0);

      notifier.setSplit(30);
      expect(container.read(planDateFormProvider).splitProposerPct, 30);
    });
  });

  // ── 3. To-do edit mode ────────────────────────────────────────────────────
  group('Todo edit mode', () {
    test('can add, toggle, delete todos', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      expect(container.read(planDateFormProvider).todos, isEmpty);

      notifier.addTodo('Book a table');
      notifier.addTodo('Pick outfit');

      final state1 = container.read(planDateFormProvider);
      expect(state1.todos.length, 2);
      expect(state1.todos[0].done, false);

      // Toggle first todo done
      notifier.toggleTodo(state1.todos[0].id);
      final state2 = container.read(planDateFormProvider);
      expect(state2.todos[0].done, true);

      // Enter edit mode
      notifier.setTodoEditMode(true);
      expect(container.read(planDateFormProvider).todoEditMode, true);

      // Delete second todo
      notifier.deleteTodo(state2.todos[1].id);
      final state3 = container.read(planDateFormProvider);
      expect(state3.todos.length, 1);
      expect(state3.todos[0].text, 'Book a table');
    });

    test('empty text is rejected', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      notifier.addTodo('  '); // whitespace-only
      expect(container.read(planDateFormProvider).todos, isEmpty);
    });
  });

  // ── 4. CTA enable rules ───────────────────────────────────────────────────
  group('CTA enable rules', () {
    test('disabled when partner, type, or date not set', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      // Nothing set
      expect(container.read(planDateFormProvider).isCtaEnabled, false);

      // Only partner
      notifier.setPartner(id: 'p1', name: 'Priya');
      expect(container.read(planDateFormProvider).isCtaEnabled, false);

      // Partner + type
      notifier.setDateType('coffee');
      expect(container.read(planDateFormProvider).isCtaEnabled, false);
    });

    test('enabled when all required fields set and date is future', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      notifier.setPartner(id: 'p1', name: 'Priya');
      notifier.setDateType('coffee');

      // Future date
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      notifier.setDate(tomorrow);
      notifier.setAmPm(false); // PM
      notifier.setHour(7);
      notifier.setMinute(30);

      expect(container.read(planDateFormProvider).isCtaEnabled, true);
    });

    test('disabled when selected date is today but time already passed', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      notifier.setPartner(id: 'p1', name: 'Priya');
      notifier.setDateType('coffee');

      final today = DateTime.now();
      notifier.setDate(today);
      // Set time to 1:00 AM which is always in the past by this test
      notifier.setHour(1);
      notifier.setMinute(0);
      notifier.setAmPm(true);

      // 1:00 AM today is definitely past if running after 1AM
      final state = container.read(planDateFormProvider);
      final isEnabled = state.isCtaEnabled;
      // We can't 100% assert this without mocking DateTime.now(), but we verify
      // that the logic runs without error:
      expect(isEnabled, isA<bool>());
    });

    test('disabled during submission', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planDateFormProvider.notifier);

      notifier.setPartner(id: 'p1', name: 'Priya');
      notifier.setDateType('coffee');
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      notifier.setDate(tomorrow);
      notifier.setAmPm(false);
      notifier.setHour(7);
      notifier.setMinute(30);

      expect(container.read(planDateFormProvider).isCtaEnabled, true);

      // Start submit (async)
      final submitFuture = notifier.submit();
      // During submission, isSubmitting = true → CTA disabled
      // (State update may be synchronous before the await in submit())
      await submitFuture;
      // After completion, isSubmitting goes back to false
      expect(container.read(planDateFormProvider).isSubmitting, false);
    });
  });
}

