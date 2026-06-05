import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../auth.dart' as auth;
import '../theme.dart';
import '../widgets/dm_widgets.dart';
import '../widgets/register_steps.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _total = 8;
  static const _requiredSteps = 4;

  int _step = 0;
  final _ctrl = TextEditingController();
  String? _fieldError;
  bool _loading = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _discordTag = '';
  String _githubLink = '';
  String _bio = '';
  String _education = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    switch (_step) {
      case 0: _firstName = _ctrl.text.trim();
      case 1: _lastName = _ctrl.text.trim();
      case 2: _email = _ctrl.text.trim();
      case 3: _password = _ctrl.text;
      case 4: _discordTag = _ctrl.text.trim();
      case 5: _githubLink = _ctrl.text.trim();
      case 6: _bio = _ctrl.text.trim();
      case 7: _education = _ctrl.text.trim();
    }
  }

  void _next() {
    _save();
    if (_step == 3) {
      _register();
    } else if (_step == _total - 1) {
      _finishProfile();
    } else {
      setState(() { _step++; _ctrl.clear(); _fieldError = null; });
    }
  }

  void _skip() {
    switch (_step) {
      case 4: _discordTag = '';
      case 5: _githubLink = '';
      case 6: _bio = '';
      case 7: _education = '';
    }
    _ctrl.clear();
    if (_step == _total - 1) {
      _finishProfile();
    } else {
      setState(() { _step++; _fieldError = null; });
    }
  }

  void _back() {
    if (_step == 0) { context.pop(); return; }
    // don't allow going back past the account-creation boundary
    if (_step == _requiredSteps) return;
    final prev = _step - 1;
    setState(() { _step = prev; _fieldError = null; });
    final values = [_firstName, _lastName, _email, _password,
                    _discordTag, _githubLink, _bio, _education];
    final text = values[prev];
    _ctrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _register() async {
    setState(() { _loading = true; _fieldError = null; });
    final err = await auth.register(_email, _firstName, _lastName, _password);
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _fieldError = err; });
    } else {
      setState(() { _loading = false; _step = _requiredSteps; _ctrl.clear(); _fieldError = null; });
    }
  }

  Future<void> _finishProfile() async {
    final hasOptional = _discordTag.isNotEmpty || _githubLink.isNotEmpty ||
                        _bio.isNotEmpty || _education.isNotEmpty;
    if (hasOptional) {
      setState(() => _loading = true);
      await ApiClient.updateProfile(
        discordTag: _discordTag,
        githubLink: _githubLink,
        bio: _bio,
        education: _education,
      );
      if (!mounted) return;
    }
    context.go('/');
  }

  bool get _isOptionalStep => _step >= _requiredSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
            child: Row(children: [
              DmNavBtn(onPressed: (_loading || _isOptionalStep) ? () {} : _back),
              const SizedBox(width: 16),
              Expanded(child: DmProgress(step: _step, total: _total)),
              if (_isOptionalStep) ...[
                const SizedBox(width: 8),
                Text('optional', style: kBody(12, color: kInk3)),
              ],
            ]),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: RegisterTextStep(
                  step: _step,
                  controller: _ctrl,
                  fieldError: _fieldError,
                  onNext: _next,
                  loading: (_step == 3 || _step == _total - 1) ? _loading : false,
                  onSkip: _isOptionalStep ? _skip : null,
                  buttonLabel: _step == _total - 1 ? 'Finish' : null,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
