import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../widgets/company_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';

  List<Company> get _results {
    if (_query.isEmpty) return companies;
    final q = _query.toLowerCase();
    return companies.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.role.toLowerCase().contains(q) ||
        c.industry.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: ShadInput(
          placeholder: const Text('Search companies or roles…'),
          leading: Icon(LucideIcons.search, size: 16, color: theme.colorScheme.mutedForeground),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      Expanded(
        child: _results.isEmpty
            ? Center(child: Text('No results', style: theme.textTheme.muted))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _Tile(company: _results[i]),
              ),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: company.color),
          child: Center(child: Text(company.name[0],
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(company.name,
                style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            ShadBadge.secondary(child: Text(company.industry)),
          ]),
          const SizedBox(height: 3),
          Text('${company.role} · ${company.location}',
              style: theme.textTheme.muted, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        Icon(LucideIcons.chevronRight, size: 16,
            color: theme.colorScheme.mutedForeground),
      ]),
    );
  }
}
