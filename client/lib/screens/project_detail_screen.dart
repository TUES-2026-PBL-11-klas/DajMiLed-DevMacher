import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api.dart';
import '../auth.dart' as auth;
import '../theme.dart';
import '../widgets/dm_widgets.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});
  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  ProjectDto? _project;
  // taskId → list of applications (owner view)
  final Map<int, List<ApplicationDto>> _taskApps = {};
  // taskId → loading state for that task's apps
  final Map<int, bool> _loadingApps = {};
  // taskIds the current user has applied to
  final Set<int> _appliedTaskIds = {};
  // taskIds currently being applied to
  final Set<int> _applying = {};
  bool _loading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiClient.get('/api/projects/${widget.projectId}'),
      ApiClient.getMyApplications(),
    ]);

    if (!mounted) return;

    final projectRes = results[0];
    final appsRes = results[1];

    if (projectRes.statusCode == 401) { context.go('/login'); return; }
    if (projectRes.statusCode != 200) { setState(() => _loading = false); return; }

    final project = ProjectDto.fromJson(jsonDecode(projectRes.body) as Map<String, dynamic>);

    // resolve owner check — use stored id, fall back to /me fetch
    int? myId = auth.currentUserId;
    if (myId == null && appsRes.statusCode == 200) {
      final meRes = await ApiClient.get('/api/users/me');
      if (mounted && meRes.statusCode == 200) {
        myId = (jsonDecode(meRes.body) as Map<String, dynamic>)['id'] as int?;
        auth.currentUserId = myId;
      }
    }

    final Set<int> applied = {};
    if (appsRes.statusCode == 200) {
      final list = jsonDecode(appsRes.body) as List<dynamic>;
      for (final a in list) {
        final dto = ApplicationDto.fromJson(a as Map<String, dynamic>);
        applied.add(dto.taskId);
      }
    }

    setState(() {
      _project = project;
      _isOwner = myId != null && project.owner.id == myId;
      _appliedTaskIds.addAll(applied);
      _loading = false;
    });
  }

  Future<void> _loadTaskApplications(int taskId) async {
    if (_taskApps.containsKey(taskId)) return;
    setState(() => _loadingApps[taskId] = true);
    final res = await ApiClient.getTaskApplications(widget.projectId, taskId);
    if (!mounted) return;
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      setState(() {
        _taskApps[taskId] = list
            .map((a) => ApplicationDto.fromJson(a as Map<String, dynamic>))
            .toList();
        _loadingApps[taskId] = false;
      });
    } else {
      setState(() => _loadingApps[taskId] = false);
    }
  }

  Future<void> _apply(int taskId) async {
    setState(() => _applying.add(taskId));
    final res = await ApiClient.apply(widget.projectId, taskId);
    if (!mounted) return;
    if (res.statusCode == 201 || res.statusCode == 200) {
      setState(() => _appliedTaskIds.add(taskId));
    } else if (res.statusCode == 409) {
      setState(() => _appliedTaskIds.add(taskId)); // already applied
    }
    setState(() => _applying.remove(taskId));
  }

  Future<void> _updateStatus(int taskId, int appId, String status) async {
    final res = await ApiClient.updateApplicationStatus(
        widget.projectId, taskId, appId, status);
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
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        leading: DmNavBtn(onPressed: () => context.pop()),
        title: Text(_project?.title ?? 'Project', style: kHeading(18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : _project == null
              ? Center(child: Text('Failed to load project', style: kBody(15, color: kInk3)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final p = _project!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Project header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kAccentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              DmAvatar(
                data: AvatarData(kAccentSoft, kAccentInk,
                    p.title.isNotEmpty ? p.title[0].toUpperCase() : '?'),
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, style: kHeading(20)),
                const SizedBox(height: 2),
                Text('by ${p.owner.displayName}', style: kBody(13, color: kInk3)),
              ])),
              if (_isOwner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAccent, borderRadius: BorderRadius.circular(999)),
                  child: Text('Your project',
                    style: kMono(11, color: Colors.white)),
                ),
            ]),
            if (p.description != null && p.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(p.description!, style: kBody(14, color: kInk2)),
            ],
          ]),
        ),
        const SizedBox(height: 24),

        // Tasks
        Text('TASKS'.toUpperCase(), style: kLabel()),
        const SizedBox(height: 12),
        if (p.tasks.isEmpty)
          Text('No tasks yet.', style: kBody(14, color: kInk3))
        else
          ...p.tasks.map((task) => _isOwner
              ? _OwnerTaskCard(
                  task: task,
                  applications: _taskApps[task.id],
                  loading: _loadingApps[task.id] ?? false,
                  onExpand: () => _loadTaskApplications(task.id),
                  onAccept: (appId) => _updateStatus(task.id, appId, 'ACCEPTED'),
                  onReject: (appId) => _updateStatus(task.id, appId, 'REJECTED'),
                )
              : _ApplicantTaskCard(
                  task: task,
                  applied: _appliedTaskIds.contains(task.id),
                  applying: _applying.contains(task.id),
                  onApply: () => _apply(task.id),
                )),
      ],
    );
  }
}

// ── Task card for applicants ──────────────────────────────────────
class _ApplicantTaskCard extends StatelessWidget {
  final ProjectTaskDto task;
  final bool applied, applying;
  final VoidCallback onApply;
  const _ApplicantTaskCard(
      {required this.task, required this.applied,
       required this.applying, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(task.title, style: kBody(16, color: kInk, weight: FontWeight.w700)),
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(task.description!, style: kBody(13.5, color: kInk3), maxLines: 3,
            overflow: TextOverflow.ellipsis),
        ],
        if (task.requiredSkills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6,
            children: task.requiredSkills
                .map((s) => DmTag(s.name, tone: DmTagTone.accent, small: true))
                .toList()),
        ],
        const SizedBox(height: 14),
        applied
            ? Row(children: [
                const Icon(Icons.check_circle, color: kAccent, size: 18),
                const SizedBox(width: 6),
                Text('Applied', style: kBody(14, color: kAccentInk, weight: FontWeight.w600)),
              ])
            : DmBtn(
                label: applying ? 'Applying…' : 'Apply',
                disabled: applying,
                icon: Icons.send_outlined,
                onPressed: onApply,
              ),
      ]),
    );
  }
}

// ── Task card for project owner ───────────────────────────────────
class _OwnerTaskCard extends StatefulWidget {
  final ProjectTaskDto task;
  final List<ApplicationDto>? applications;
  final bool loading;
  final VoidCallback onExpand;
  final void Function(int appId) onAccept, onReject;
  const _OwnerTaskCard(
      {required this.task, required this.applications,
       required this.loading, required this.onExpand,
       required this.onAccept, required this.onReject});
  @override
  State<_OwnerTaskCard> createState() => _OwnerTaskCardState();
}

class _OwnerTaskCardState extends State<_OwnerTaskCard> {
  bool _expanded = false;

  void _toggle() {
    if (!_expanded && widget.applications == null) widget.onExpand();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final apps = widget.applications ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _expanded ? kAccent : kLine),
      ),
      child: Column(children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.task.title,
                  style: kBody(15.5, color: kInk, weight: FontWeight.w700)),
                if (widget.task.requiredSkills.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(spacing: 6,
                    children: widget.task.requiredSkills
                        .map((s) => DmTag(s.name, tone: DmTagTone.accent, small: true))
                        .toList()),
                ],
              ])),
              const SizedBox(width: 12),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                color: kInk3, size: 22),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1, color: kLine),
          widget.loading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: kAccent, strokeWidth: 2))
              : apps.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No applications yet.',
                        style: kBody(14, color: kInk3)))
                  : Column(
                      children: apps.map((app) => _ApplicationRow(
                        app: app,
                        onAccept: () => widget.onAccept(app.id),
                        onReject: () => widget.onReject(app.id),
                      )).toList()),
        ],
      ]),
    );
  }
}

class _ApplicationRow extends StatefulWidget {
  final ApplicationDto app;
  final VoidCallback onAccept, onReject;
  const _ApplicationRow(
      {required this.app, required this.onAccept, required this.onReject});
  @override
  State<_ApplicationRow> createState() => _ApplicationRowState();
}

class _ApplicationRowState extends State<_ApplicationRow> {
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
    final initials = _user?.initials ?? '?';
    final avatar = AvatarData(kAccentSoft, kAccentInk, initials);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kLine))),
      child: Row(children: [
        GestureDetector(
          onTap: _user != null
              ? () => context.push('/users/${_user!.id}')
              : null,
          child: DmAvatar(data: avatar, size: 38),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _user != null
                ? () => context.push('/users/${_user!.id}')
                : null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: kBody(14.5, color: kInk, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              _StatusBadge(widget.app.status),
            ]),
          ),
        ),
        if (widget.app.isPending) ...[
          DmActionBtn(
            icon: Icons.check,
            iconColor: Colors.white,
            bgColor: kAccent,
            borderColor: kAccent,
            size: 36,
            onPressed: widget.onAccept,
          ),
          const SizedBox(width: 8),
          DmActionBtn(
            icon: Icons.close,
            iconColor: kInk2,
            bgColor: Colors.white,
            borderColor: kLine,
            size: 36,
            onPressed: widget.onReject,
          ),
        ] else if (widget.app.isAccepted)
          const Icon(Icons.check_circle, color: kAccent, size: 22)
        else
          Icon(Icons.cancel, color: Colors.red.shade400, size: 22),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'ACCEPTED' => (kAccent, 'Accepted'),
      'REJECTED' => (Colors.red.shade400, 'Rejected'),
      _ => (Colors.orange.shade400, 'Pending'),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: kBody(12.5, color: color, weight: FontWeight.w600)),
    ]);
  }
}
