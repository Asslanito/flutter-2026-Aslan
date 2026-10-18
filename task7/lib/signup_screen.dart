import 'package:flutter/material.dart';

import 'summary_card.dart';

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm, _birthText]) {
      controller.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() == false) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _done = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  Future<void> _pickBirth() async {
    final birth = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (birth == null || mounted == false) return;
    setState(() {
      _birth = birth;
      _birthText.text = formatBirth(birth);
    });
  }

  void _startOver() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      for (final controller in [
        _name,
        _email,
        _password,
        _confirm,
        _birthText,
      ]) {
        controller.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  void _dismiss(PointerDownEvent event) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _done
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SummaryCard(
                    name: _name.text.trim(),
                    email: _email.text.trim(),
                    group: _group ?? '',
                    birth: _birth,
                  ),
                  TextButton(
                    onPressed: _startOver,
                    child: const Text('Start over'),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      onTapOutside: _dismiss,
                      validator: (value) => (value ?? '').trim().length < 2
                          ? 'Name is too short'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      focusNode: _emailFocus,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'name@kbtu.kz',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onTapOutside: _dismiss,
                      validator: (value) {
                        final email = (value ?? '').trim();
                        final at = email.indexOf('@');
                        final dot = email.indexOf('.', at + 1);
                        return at > 0 && dot > at + 1 && dot < email.length - 1
                            ? null
                            : 'Email looks wrong';
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'At least 8 characters',
                      ),
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      onTapOutside: _dismiss,
                      onChanged: (_) => setState(() {}),
                      validator: (value) => (value ?? '').length < 8
                          ? 'Password is too short'
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text('${_password.text.length} of 8'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirm,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: _agreed ? (_) => _submit() : null,
                      onTapOutside: _dismiss,
                      validator: (value) =>
                          (value ?? '').isNotEmpty && value == _password.text
                          ? null
                          : 'Passwords do not match',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _group,
                      decoration: const InputDecoration(labelText: 'Group'),
                      items: [
                        for (final group in groups)
                          DropdownMenuItem(value: group, child: Text(group)),
                      ],
                      onChanged: (value) => setState(() => _group = value),
                      validator: (value) =>
                          value == null ? 'Choose a group' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthText,
                      decoration: const InputDecoration(
                        labelText: 'Date of birth',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: _pickBirth,
                      onTapOutside: _dismiss,
                      validator: (_) =>
                          _birth == null ? 'Choose a birth date' : null,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('I agree to the rules'),
                      value: _agreed,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _agreed ? _submit : null,
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}
