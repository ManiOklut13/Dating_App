// ─────────────────────────────────────────────────────────────────────────────
// Dress Code & Notes (Offline-only)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../plan_date_theme.dart';

const List<String> kDressCodes = [
  'Casual',
  'Smart casual',
  'Formal',
  'Cozy',
  'Theme night',
];

class DressCodeNotes extends StatefulWidget {
  final String? selectedCode;
  final String dressNote;
  final String partnerNote;
  final bool editMode;
  final ValueChanged<String?> onCodeChanged;
  final ValueChanged<String> onDressNoteChanged;
  final ValueChanged<String> onPartnerNoteChanged;
  final VoidCallback onToggleEditMode;

  const DressCodeNotes({
    super.key,
    required this.selectedCode,
    required this.dressNote,
    required this.partnerNote,
    required this.editMode,
    required this.onCodeChanged,
    required this.onDressNoteChanged,
    required this.onPartnerNoteChanged,
    required this.onToggleEditMode,
  });

  @override
  State<DressCodeNotes> createState() => _DressCodeNotesState();
}

class _DressCodeNotesState extends State<DressCodeNotes> {
  late final TextEditingController _dressCtrl;
  late final TextEditingController _partnerCtrl;

  @override
  void initState() {
    super.initState();
    _dressCtrl = TextEditingController(text: widget.dressNote);
    _partnerCtrl = TextEditingController(text: widget.partnerNote);
  }

  @override
  void dispose() {
    _dressCtrl.dispose();
    _partnerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Dress Code & Notes', style: PDTextStyles.sectionTitle),
              const Spacer(),
              Semantics(
                label: widget.editMode ? 'Done editing dress code' : 'Edit dress code',
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
          const SizedBox(height: 12),
          // ── Dress code chips ──────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kDressCodes.map((code) {
              final selected = widget.selectedCode == code;
              return Semantics(
                label: '$code dress code',
                selected: selected,
                button: true,
                enabled: widget.editMode,
                child: GestureDetector(
                  onTap: widget.editMode
                      ? () => widget.onCodeChanged(selected ? null : code)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected ? PDGradients.primary : null,
                      color: selected
                          ? null
                          : widget.editMode
                              ? PDColors.inputFill
                              : PDColors.disabledFill,
                      borderRadius: BorderRadius.circular(PDRadius.chip),
                      border: Border.all(
                        color: selected ? Colors.transparent : PDColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : widget.editMode
                                ? PDColors.textMuted
                                : PDColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // ── Note fields ────────────────────────────────────────────────────
          _noteField('Your dress note', _dressCtrl, widget.onDressNoteChanged),
          const SizedBox(height: 10),
          _noteField('Partner note', _partnerCtrl, widget.onPartnerNoteChanged),
        ],
      ),
    );
  }

  Widget _noteField(
    String hint,
    TextEditingController ctrl,
    ValueChanged<String> onChanged,
  ) {
    return AbsorbPointer(
      absorbing: !widget.editMode,
      child: Container(
        decoration: BoxDecoration(
          color: widget.editMode ? PDColors.inputFill : PDColors.disabledFill,
          borderRadius: BorderRadius.circular(PDRadius.input),
          border: Border.all(color: PDColors.inputBorder),
        ),
        child: TextField(
          controller: ctrl,
          maxLines: 3,
          style: PDTextStyles.body.copyWith(
            color: widget.editMode ? PDColors.textPrimary : PDColors.textMuted,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: widget.editMode ? hint : '$hint (tap Edit to write)',
            hintStyle: const TextStyle(color: PDColors.textMuted, fontSize: 13),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }
}

