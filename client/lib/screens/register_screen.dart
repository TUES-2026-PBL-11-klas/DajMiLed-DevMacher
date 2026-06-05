import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  static const _total = 5;

  int _step = 0;
  final _ctrl = TextEditingController();
  String? _fieldError;
  bool _loading = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  final Set<String> _ownSkills = {};

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
    }
  }

  void _next() {
    _save();
    if (_step < _total - 1) {
      setState(() { _step++; _ctrl.clear(); });
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) { context.pop(); return; }
    final prev = _step - 1;
    setState(() { _step = prev; _fieldError = null; });
    if (prev < 4) {
      final text = [_firstName, _lastName, _email, _password][prev];
      _ctrl.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _fieldError = null; });
    final err = await auth.register(_email, _firstName, _lastName, _password, _ownSkills.toList());
    if (!mounted) return;
    if (err != null) {
      setState(() { _loading = false; _fieldError = err; });
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
            child: Row(children: [
              DmNavBtn(onPressed: _loading ? () {} : _back),
              const SizedBox(width: 16),
              Expanded(child: DmProgress(step: _step, total: _total)),
            ]),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _step < 4
                    ? RegisterTextStep(step: _step, controller: _ctrl,
                        fieldError: _fieldError, onNext: _next)
                    : RegisterSkillStep(
                        selectedSkills: _ownSkills,
                        onToggle: (s) => setState(() =>
                            _ownSkills.contains(s) ? _ownSkills.remove(s) : _ownSkills.add(s)),
                        fieldError: _fieldError,
                        onNext: _next,
                        loading: _loading,
                      ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
