import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/meeting.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/confirm.dart';

class MeetingForm extends StatefulWidget {
  const MeetingForm({super.key, this.meeting});
  final Meeting? meeting;

  @override
  State<MeetingForm> createState() => _MeetingFormState();
}

class _MeetingFormState extends State<MeetingForm> {
  final _formKey = GlobalKey<FormState>();
  late final Meeting _original;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  Category? _category;
  DateTime? _date;
  TimeOfDay? _time;
  late bool _online;
  late final Object _initialValues;
  bool _saving = false;
  bool _allowPop = false;
  bool _asking = false;

  Object get _values => (
    _title.text, _place.text, _limit.text, _description.text,
    _category, _online, _date, _time,
  );

  bool get _dirty => _values != _initialValues;

  DateTime? get _when {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void initState() {
    super.initState();
    _original = widget.meeting ?? Meeting.empty();
    _title = TextEditingController(text: _original.title);
    _place = TextEditingController(text: _original.place);
    _limit = TextEditingController(text: _original.limit.toString());
    _description = TextEditingController(text: _original.description ?? '');
    _category = _original.category;
    _online = _original.online;
    final when = _original.when;
    _date = DateTime(when.year, when.month, when.day);
    _time = TimeOfDay.fromDateTime(when);
    _dateText = TextEditingController(text: '${formatDate(when)} ${when.year}');
    _timeText = TextEditingController(text: formatTime(when));
    _initialValues = _values;
  }

  @override
  void dispose() {
    for (final controller in [_title, _place, _limit, _description, _dateText, _timeText]) {
      controller.dispose();
    }
    for (final focus in [_titleFocus, _placeFocus, _limitFocus, _descriptionFocus, _dateFocus, _timeFocus]) {
      focus.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 100),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _date = selected;
      _dateText.text = '${formatDate(selected)} ${selected.year}';
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (!mounted || selected == null) return;
    setState(() {
      _time = selected;
      _timeText.text = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    if (_saving || _formKey.currentState?.validate() != true) return;
    final description = _description.text.trim();
    final meeting = _original.copyWith(
      title: _title.text.trim(),
      category: _category,
      when: _when,
      place: _place.text.trim(),
      limit: int.tryParse(_limit.text.trim()),
      online: _online,
      description: description,
      clearDescription: description.isEmpty,
    );
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _allowPop = true;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context, meeting);
  }

  Future<void> _onPop(bool didPop, Meeting? result) async {
    if (didPop || _saving || _asking) return;
    _asking = true;
    final discard = await confirm(context,
      title: 'Discard changes?',
      message: 'Your unsaved changes will be lost.',
      action: 'Discard',
    );
    if (!mounted) return;
    _asking = false;
    if (discard != true) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration _decoration(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder());

  void _dismiss(PointerDownEvent event) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) => PopScope<Meeting>(
    canPop: !_saving && (_allowPop || !_dirty),
    onPopInvokedWithResult: _onPop,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.meeting == null ? 'New meeting' : 'Edit meeting')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: AbsorbPointer(
                absorbing: _saving,
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: () => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      TextFormField(
                        controller: _title, focusNode: _titleFocus,
                        decoration: _decoration('Title'), maxLength: 60,
                        keyboardType: TextInputType.text, textInputAction: TextInputAction.next,
                        onTapOutside: _dismiss, validator: validateTitle,
                        onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                      ),
                      DropdownButtonFormField<Category>(
                        initialValue: _category,
                        decoration: _decoration('Subject'),
                        items: [for (final category in Category.values)
                          DropdownMenuItem(value: category, child: Text(category.label)),
                        ],
                        onChanged: (value) => setState(() => _category = value),
                        validator: (value) => value == null ? 'Choose a subject' : null,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Online meeting'),
                        value: _online,
                        onChanged: (value) => setState(() => _online = value),
                      ),
                      TextFormField(
                        controller: _place, focusNode: _placeFocus,
                        decoration: _decoration(_online ? 'Meeting link' : 'Place'),
                        keyboardType: _online ? TextInputType.url : TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        onTapOutside: _dismiss, validator: (value) => validatePlace(value, _online),
                        onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                      ),
                      TextFormField(
                        controller: _limit, focusNode: _limitFocus,
                        decoration: _decoration('Maximum participants'),
                        keyboardType: TextInputType.number, textInputAction: TextInputAction.next,
                        onTapOutside: _dismiss, validator: (value) => validateLimit(value, _original.count),
                        onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                      ),
                      TextFormField(
                        controller: _dateText, focusNode: _dateFocus,
                        decoration: _decoration('Date'), readOnly: true,
                        keyboardType: TextInputType.datetime, textInputAction: TextInputAction.next,
                        onTapOutside: _dismiss, onTap: _pickDate,
                        validator: (_) => validateWhen(_when, widget.meeting == null),
                        onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                      ),
                      TextFormField(
                        controller: _timeText, focusNode: _timeFocus,
                        decoration: _decoration('Time'), readOnly: true,
                        keyboardType: TextInputType.datetime, textInputAction: TextInputAction.next,
                        onTapOutside: _dismiss, onTap: _pickTime,
                        validator: (_) => validateWhen(_when, widget.meeting == null),
                        onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                      ),
                      TextFormField(
                        controller: _description, focusNode: _descriptionFocus,
                        decoration: _decoration('Description (optional)'), maxLength: 500,
                        minLines: 2, maxLines: 4,
                        keyboardType: TextInputType.multiline, textInputAction: TextInputAction.done,
                        onTapOutside: _dismiss, validator: validateDescription,
                        onFieldSubmitted: (_) => _save(),
                      ),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save meeting'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
