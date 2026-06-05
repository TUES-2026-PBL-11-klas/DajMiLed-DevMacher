import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../auth.dart' as auth;
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class MyApplicationsScreen extends StatefulWidget {
  final int initialTab;
  const MyApplicationsScreen({super.key, this.initialTab = 0});
  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        leading: DmNavBtn(onPressed: () => context.pop()),
        title: Text('Applications', style: kHeading(18)),
        bottom: TabBar(
          controller: _tabs,
          labelColor: kAccentInk,
          unselectedLabelColor: kInk3,
          indicatorColor: kAccent,
          labelStyle: kBody(14, color: kAccentInk, weight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Applied'),
            Tab(text: 'My Projects'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _AppliedTab(),
          _MyProjectsTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Applications I submitted ──────────────────────────────
class _AppliedTab extends StatefulWidget {
  const _AppliedTab();
  @override
  State<_AppliedTab> createState() => _AppliedTabState();
}

class _AppliedTabState extends State<_AppliedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<_EnrichedApp> _items = [];
  bool _loading = true;
  final Set<int> _withdrawing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiClient.getMyApplications(),
      ApiClient.get('/api/projects?page=0&size=200'),
    ]);
    if (!mounted) return;

    final appsRes = results[0];
    final projectsRes = results[1];

    if (appsRes.statusCode == 401) { context.go('/login'); return; }
    if (appsRes.statusCode != 200) { setState(() => _loading = false); return; }

    final apps = (jsonDecode(appsRes.body) as List<dynamic>)
        .map((a) => ApplicationDto.fromJson(a as Map<String, dynamic>))
        .toList();

    final Map<int, ProjectTaskDto> taskById = {};
    final Map<int, ProjectDto> projectByTaskId = {};
    if (projectsRes.statusCode == 200) {
      final body = jsonDecode(projectsRes.body) as Map<String, dynamic>;
      for (final p in (body['content'] as List<dynamic>)
          .map((p) => ProjectDto.fromJson(p as Map<String, dynamic>))) {
        for (final t in p.tasks) {
          taskById[t.id] = t;
          projectByTaskId[t.id] = p;
        }
      }
    }

    setState(() {
      _items = apps.map((a) => _EnrichedApp(
        app: a,
        task: taskById[a.taskId],
        project: projectByTaskId[a.taskId],
      )).toList();
      _loading = false;
    });
  }

  Future<void> _withdraw(_EnrichedApp item) async {
    final project = item.project;
    if (project == null) return;
    setState(() => _withdrawing.add(item.app.id));
    final res = await ApiClient.withdrawApplication(
        project.id, item.app.taskId, item.app.id);
    if (!mounted) return;
    if (res.statusCode == 204 || res.statusCode == 200) {
      setState(() => _items.removeWhere((i) => i.app.id == item.app.id));
    }
    setState(() => _withdrawing.remove(item.app.id));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    if (_items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.send_outlined, size: 44, color: kInk3),
        const SizedBox(height: 12),
        Text("You haven't applied to anything yet.", style: kBody(15, color: kInk3)),
        const SizedBox(height: 16),
        DmBtn(label: 'Explore projects', variant: DmBtnVariant.outline,
          onPressed: () => context.go('/')),
      ]));
    }
    return RefreshIndicator(
      color: kAccent,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AppCard(
          item: _items[i],
          withdrawing: _withdrawing.contains(_items[i].app.id),
          onWithdraw: () => _withdraw(_items[i]),
          onViewProject: _items[i].project != null
              ? () => context.push('/projects/${_items[i].project!.id}')
              : null,
        ),
      ),
    );
  }
}

// ── Tab 2: My projects with incoming applications ─────────────────
class _MyProjectsTab extends StatefulWidget {
  const _MyProjectsTab();
  @override
  State<_MyProjectsTab> createState() => _MyProjectsTabState();
}

class _MyProjectsTabState extends State<_MyProjectsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<ProjectDto> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // resolve current user id if not yet known
    if (auth.currentUserId == null) {
      final meRes = await ApiClient.get('/api/users/me');
      if (!mounted) return;
      if (meRes.statusCode == 401) { context.go('/login'); return; }
      if (meRes.statusCode == 200) {
        auth.currentUserId =
            (jsonDecode(meRes.body) as Map<String, dynamic>)['id'] as int?;
      }
    }

    final res = await ApiClient.get('/api/projects?ownerId=${auth.currentUserId}');
    if (!mounted) return;
    if (res.statusCode != 200) { setState(() => _loading = false); return; }

    setState(() {
      _projects = (jsonDecode(res.body) as List<dynamic>)
          .map((p) => ProjectDto.fromJson(p as Map<String, dynamic>))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    if (_projects.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.folder_outlined, size: 44, color: kInk3),
        const SizedBox(height: 12),
        Text("You don't have any projects yet.", style: kBody(15, color: kInk3)),
      ]));
    }
    return RefreshIndicator(
      color: kAccent,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: _projects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ProjectApplicationCard(project: _projects[i]),
      ),
    );
  }
}

class _ProjectApplicationCard extends StatefulWidget {
  final ProjectDto project;
  const _ProjectApplicationCard({required this.project});
  @override
  State<_ProjectApplicationCard> createState() => _ProjectApplicationCardState();
}

class _ProjectApplicationCardState extends State<_ProjectApplicationCard> {
  // taskId → applications
  final Map<int, List<ApplicationDto>> _taskApps = {};
  final Map<int, bool> _loadingTask = {};
  int? _expanded;

  Future<void> _loadTask(int taskId) async {
    if (_taskApps.containsKey(taskId)) {
      setState(() => _expanded = _expanded == taskId ? null : taskId);
      return;
    }
    setState(() { _loadingTask[taskId] = true; _expanded = taskId; });
    final res = await ApiClient.getTaskApplications(widget.project.id, taskId);
    if (!mounted) return;
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      setState(() {
        _taskApps[taskId] = list
            .map((a) => ApplicationDto.fromJson(a as Map<String, dynamic>))
            .toList();
        _loadingTask[taskId] = false;
      });
    } else {
      setState(() => _loadingTask[taskId] = false);
    }
  }

  Future<void> _updateStatus(int taskId, int appId, String status) async {
    final res = await ApiClient.updateApplicationStatus(
        widget.project.id, taskId, appId, status);
    if (!mounted) return;
    if (res.statusCode == 200) {
      final updated = ApplicationDto.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
      setState(() {
        final list = _taskApps[taskId];
        if (list != null) {
          final idx = list.indexWhere((a) => a.id == appId);
          if (idx != -1) list[idx] = updated;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Project header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(children: [
            DmAvatar(
              data: AvatarData(kAccentSoft, kAccentInk,
                  p.title.isNotEmpty ? p.title[0].toUpperCase() : '?'),
              size: 40,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(p.title,
              style: kBody(15.5, color: kInk, weight: FontWeight.w700))),
            GestureDetector(
              onTap: () => context.push('/projects/${p.id}'),
              child: const Icon(Icons.open_in_new, color: kInk3, size: 18),
            ),
          ]),
        ),
        if (p.tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text('No tasks', style: kBody(13, color: kInk3)),
          )
        else
          ...p.tasks.map((task) {
            final isExpanded = _expanded == task.id;
            final apps = _taskApps[task.id];
            final loading = _loadingTask[task.id] ?? false;
            final pendingCount = apps?.where((a) => a.isPending).length ?? 0;

            return Column(children: [
              const Divider(height: 1, color: kLine),
              InkWell(
                onTap: () => _loadTask(task.id),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(task.title, style: kBody(14.5, color: kInk, weight: FontWeight.w600)),
                      if (apps != null) ...[
                        const SizedBox(height: 3),
                        Text('${apps.length} applicant${apps.length == 1 ? '' : 's'}',
                          style: kBody(12.5, color: kInk3)),
                      ],
                    ])),
                    if (pendingCount > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text('$pendingCount new',
                          style: kBody(11.5, color: Colors.orange.shade700, weight: FontWeight.w600)),
                      ),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: kInk3, size: 20),
                  ]),
                ),
              ),
              if (isExpanded)
                loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: kAccent, strokeWidth: 2))
                    : apps == null || apps.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text('No applications yet.',
                              style: kBody(13, color: kInk3)))
                        : Column(children: apps.map((app) => _InlineAppRow(
                            app: app,
                            onAccept: () => _updateStatus(task.id, app.id, 'ACCEPTED'),
                            onReject: () => _updateStatus(task.id, app.id, 'REJECTED'),
                          )).toList()),
            ]);
          }),
      ]),
    );
  }
}

class _InlineAppRow extends StatefulWidget {
  final ApplicationDto app;
  final VoidCallback onAccept, onReject;
  const _InlineAppRow({required this.app, required this.onAccept, required this.onReject});
  @override
  State<_InlineAppRow> createState() => _InlineAppRowState();
}

class _InlineAppRowState extends State<_InlineAppRow> {
  UserDto? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final res = await ApiClient.getUserById(widget.app.applicantId);
    if (mounted && res.statusCode == 200) {
      setState(() => _user =
          UserDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.fullName ?? 'User #${widget.app.applicantId}';
    final avatar = AvatarData(kAccentSoft, kAccentInk, _user?.initials ?? '?');
    final (statusColor, statusLabel) = switch (widget.app.status) {
      'ACCEPTED' => (kAccent, 'Accepted'),
      'REJECTED' => (Colors.red.shade400, 'Rejected'),
      _ => (Colors.orange.shade400, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kLine))),
      child: Row(children: [
        GestureDetector(
          onTap: _user != null
              ? () => context.push('/users/${_user!.id}')
              : null,
          child: DmAvatar(data: avatar, size: 36),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _user != null
                ? () => context.push('/users/${_user!.id}')
                : null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: kBody(14, color: kInk, weight: FontWeight.w600)),
              Row(children: [
                Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(statusLabel,
                  style: kBody(12, color: statusColor, weight: FontWeight.w600)),
              ]),
              if (widget.app.isAccepted && _user != null) ...[
                const SizedBox(height: 2),
                Text(_user!.email, style: kBody(12, color: kInk3)),
              ],
            ]),
          ),
        ),
        if (widget.app.isPending) ...[
          DmActionBtn(
            icon: Icons.check, iconColor: Colors.white,
            bgColor: kAccent, borderColor: kAccent, size: 34,
            onPressed: widget.onAccept,
          ),
          const SizedBox(width: 6),
          DmActionBtn(
            icon: Icons.close, iconColor: kInk2,
            bgColor: Colors.white, borderColor: kLine, size: 34,
            onPressed: widget.onReject,
          ),
        ] else if (widget.app.isAccepted)
          const Icon(Icons.check_circle, color: kAccent, size: 20)
        else
          Icon(Icons.cancel, color: Colors.red.shade400, size: 20),
      ]),
    );
  }
}

// ── Shared types ──────────────────────────────────────────────────
class _EnrichedApp {
  final ApplicationDto app;
  final ProjectTaskDto? task;
  final ProjectDto? project;
  const _EnrichedApp({required this.app, this.task, this.project});
}

class _AppCard extends StatelessWidget {
  final _EnrichedApp item;
  final bool withdrawing;
  final VoidCallback onWithdraw;
  final VoidCallback? onViewProject;
  const _AppCard({required this.item, required this.withdrawing,
      required this.onWithdraw, this.onViewProject});

  @override
  Widget build(BuildContext context) {
    final app = item.app;
    final (statusColor, statusLabel) = switch (app.status) {
      'ACCEPTED' => (kAccent, 'Accepted'),
      'REJECTED' => (Colors.red.shade400, 'Rejected'),
      _ => (Colors.orange.shade400, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.task?.title ?? 'Task #${app.taskId}',
              style: kBody(16, color: kInk, weight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(item.project?.title ?? 'Project',
              style: kBody(13.5, color: kInk3)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: statusColor.withAlpha(80)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(statusLabel,
                style: kBody(12.5, color: statusColor, weight: FontWeight.w600)),
            ]),
          ),
        ]),
        if (item.task != null && item.task!.requiredSkills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 4,
            children: item.task!.requiredSkills
                .map((s) => DmTag(s.name, tone: DmTagTone.accent, small: true))
                .toList()),
        ],
        const SizedBox(height: 14),
        Row(children: [
          if (onViewProject != null)
            Expanded(child: DmBtn(label: 'View project',
              variant: DmBtnVariant.ghost, icon: Icons.open_in_new,
              fontSize: 13, onPressed: onViewProject)),
          if (onViewProject != null && app.isPending) const SizedBox(width: 10),
          if (app.isPending)
            Expanded(child: DmBtn(
              label: withdrawing ? 'Withdrawing…' : 'Withdraw',
              variant: DmBtnVariant.outline, disabled: withdrawing,
              fontSize: 13, onPressed: onWithdraw)),
        ]),
      ]),
    );
  }
}
