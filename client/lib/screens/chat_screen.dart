import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../theme.dart';
import '../data.dart';
import '../widgets/dm_widgets.dart';

class ChatScreen extends StatefulWidget {
  final MatchChat match;
  final VoidCallback onBack;
  const ChatScreen({super.key, required this.match, required this.onBack});

  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<ChatMessage> _messages;
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.match.thread);
  }

  @override
  void dispose() {
    _ctrl.dispose(); _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage('me', text, 'now'));
      _ctrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() => _messages.add(const ChatMessage('them', 'Sounds great — let\'s do it! 🚀', 'now')));
      Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    });
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(children: [
          // header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: kSurface,
              border: Border(bottom: BorderSide(color: kLine, width: 1)),
            ),
            child: Row(children: [
              DmNavBtn(onPressed: widget.onBack),
              const SizedBox(width: 12),
              DmAvatar(data: widget.match.avatar, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.match.name, style: kBody(15.5, color: kInk, weight: FontWeight.w700)),
                Text(widget.match.context, style: kMono(11, color: kAccentInk)),
              ])),
            ]),
          ),
          // messages
          Expanded(
            child: ListView.separated(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              itemCount: _messages.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(999)),
                      child: Text('You matched on ${widget.match.context}', style: kMono(11.5, color: kInk3)),
                    ),
                  );
                }
                final msg = _messages[i - 1];
                return DmBubble(
                  me: msg.from == 'me',
                  child: Text(msg.text),
                );
              },
            ),
          ),
          // input
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
            decoration: const BoxDecoration(
              color: kSurface,
              border: Border(top: BorderSide(color: kLine, width: 1)),
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: kBg, borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: kLine, width: 1.5),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    style: kBody(15, color: kInk),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Message…', hintStyle: kBody(15, color: kInk3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: kAccent, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: kAccent.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
