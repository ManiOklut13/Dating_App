import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'date_plan_models.dart';

/// Sent date invites for the current session, shared with the chat tab so the
/// Requests list can show them after the planner is dismissed.
final dateInvitesProvider =
    NotifierProvider<DateInvitesNotifier, List<DateInvite>>(
  DateInvitesNotifier.new,
);

class DateInvitesNotifier extends Notifier<List<DateInvite>> {
  @override
  List<DateInvite> build() => const [];

  void add(DateInvite invite) => state = [...state, invite];
}
