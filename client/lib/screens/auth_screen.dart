import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class _FocusField extends StatefulWidget {
  final TextEditingController ctrl;
  final String placeholder;
  final TextInputType type;
  final bool obscure;
  const _FocusField({required this.ctrl, required this.placeholder, required this.type, this.obscure = false});
  @override State<_FocusField> createState() => _FocusFieldState();
}

class _FocusFieldState extends State<_FocusField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _focused ? kAccent : kLine, width: 1.5),
        ),
        child: TextField(
          controller: widget.ctrl,
          keyboardType: widget.type,
          obscureText: widget.obscure,
          style: kBody(15.5, color: kInk),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: kBody(15.5, color: kInk3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool isSignup;
  final VoidCallback onBack;
  final void Function(String name, String email, String password) onDone;

  const AuthScreen({super.key, required this.isSignup, required this.onBack, required this.onDone});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool get _canContinue =>
      _emailCtrl.text.contains('@') && (!widget.isSignup || _nameCtrl.text.trim().length > 1);

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(children: [
          // top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(children: [
              DmNavBtn(onPressed: widget.onBack),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.isSignup ? 'Create your account' : 'Welcome back',
                  style: kHeading(30),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isSignup ? 'Two quick fields, then four questions.' : 'Sign in to keep matching.',
                  style: kBody(15.5),
                ),
                const SizedBox(height: 26),
                // fields
                if (widget.isSignup) ...[
                  _label('Name'),
                  const SizedBox(height: 7),
                  _field(_nameCtrl, 'Your name', TextInputType.name),
                  const SizedBox(height: 16),
                ],
                _label('Email'),
                const SizedBox(height: 7),
                _field(_emailCtrl, 'you@example.com', TextInputType.emailAddress),
                const SizedBox(height: 16),
                _label('Password'),
                const SizedBox(height: 7),
                _field(_passCtrl, '••••••••', TextInputType.visiblePassword, obscure: true),
                const SizedBox(height: 24),
                // OR divider
                Row(children: [
                  const Expanded(child: Divider(color: kLine)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: kMono(12, color: kInk3)),
                  ),
                  const Expanded(child: Divider(color: kLine)),
                ]),
                const SizedBox(height: 16),
                // GitHub
                ListenableBuilder(
                  listenable: Listenable.merge([_nameCtrl, _emailCtrl, _passCtrl]),
                  builder: (_, __) => DmBtn(
                    label: 'Continue with GitHub',
                    full: true,
                    variant: DmBtnVariant.outline,
                    icon: LucideIcons.gitBranch,
                    onPressed: () {
                      widget.onDone(
                        _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'You',
                        _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : 'you@devmatch.io',
                        _passCtrl.text,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: ListenableBuilder(
              listenable: Listenable.merge([_nameCtrl, _emailCtrl, _passCtrl]),
              builder: (_, __) => DmBtn(
                label: widget.isSignup ? 'Continue' : 'Sign in',
                full: true,
                icon: Icons.arrow_forward_rounded,
                disabled: widget.isSignup && !_canContinue,
                onPressed: () => widget.onDone(
                  _nameCtrl.text.trim(),
                  _emailCtrl.text.trim(),
                  _passCtrl.text,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text.toUpperCase(), style: kLabel());

  Widget _field(TextEditingController ctrl, String placeholder, TextInputType type,
      {bool obscure = false}) {
    return _FocusField(ctrl: ctrl, placeholder: placeholder, type: type, obscure: obscure);
  }
}
