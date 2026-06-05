import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<ProjectDto> _projects = [];
  final ScrollController _scroll = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;
  bool _last = false;
  int _page = 0;
  String _query = '';

  static const _size = 10;

  @override
  void initState() {
    super.initState();
    _loadPage(0);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _last) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadPage(_page + 1);
    }
  }

  Future<void> _loadPage(int page) async {
    if (page == 0) {
      setState(() { _loading = true; _projects.clear(); _last = false; });
    } else {
      setState(() => _loadingMore = true);
    }

    final res = await ApiClient.getProjects(page: page, size: _size);
    if (!mounted) return;

    if (res.statusCode == 401) { context.go('/login'); return; }
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final items = (body['content'] as List<dynamic>)
          .map((p) => ProjectDto.fromJson(p as Map<String, dynamic>))
          .toList();
      setState(() {
        _projects.addAll(items);
        _last = body['last'] as bool;
        _page = page;
        _loading = false;
        _loadingMore = false;
      });
    } else {
      setState(() { _loading = false; _loadingMore = false; });
    }
  }

  List<ProjectDto> get _results {
    if (_query.isEmpty) return _projects;
    final q = _query.toLowerCase();
    return _projects.where((p) =>
        p.title.toLowerCase().contains(q) ||
        (p.description ?? '').toLowerCase().contains(q) ||
        p.owner.displayName.toLowerCase().contains(q) ||
        p.allSkillNames.any((s) => s.toLowerCase().contains(q))).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: kBody(15, color: kInk),
            decoration: InputDecoration(
              hintText: 'Search projects or skills…',
              hintStyle: kBody(15, color: kInk3),
              prefixIcon: const Icon(Icons.search, color: kInk3, size: 20),
              filled: true,
              fillColor: kSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kLine, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kLine, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kAccent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kAccent))
              : _results.isEmpty
                  ? Center(child: Text(
                      _projects.isEmpty ? 'No projects yet' : 'No results',
                      style: kBody(15, color: kInk3)))
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: _results.length + (_loadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        if (i == _results.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator(
                                color: kAccent, strokeWidth: 2)),
                          );
                        }
                        return _ProjectTile(project: _results[i]);
                      },
                    ),
        ),
      ]),
      Positioned(
        right: 20, bottom: 20,
        child: GestureDetector(
          onTap: () async {
            await context.push('/projects/create');
            _loadPage(0);
          },
          child: Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                color: kAccent.withAlpha(130),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    ]);
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project});
  final ProjectDto project;

  @override
  Widget build(BuildContext context) {
    final skills = project.allSkillNames.take(3).toList();
    final initial = project.title.isNotEmpty ? project.title[0].toUpperCase() : '?';
    final avatar = AvatarData(kAccentSoft, kAccentInk, initial);

    return GestureDetector(
      onTap: () => context.push('/projects/${project.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kLine, width: 1),
        ),
        child: Row(children: [
          DmAvatar(data: avatar, size: 46),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(project.title,
                style: kBody(15.5, color: kInk, weight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text('by ${project.owner.displayName} · ${project.tasks.length} task${project.tasks.length == 1 ? '' : 's'}',
                style: kBody(13, color: kInk3)),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: skills.map((s) => DmTag(s, small: true)).toList()),
            ],
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: kInk3, size: 20),
        ]),
      ),
    );
  }
}
