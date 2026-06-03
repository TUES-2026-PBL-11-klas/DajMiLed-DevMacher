import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Company {
  const Company({required this.name, required this.industry, required this.role,
      required this.description, required this.skills, required this.location,
      required this.color});
  final String name, industry, role, description, location;
  final List<String> skills;
  final Color color;
}

const companies = [
  Company(name: 'Stripe', industry: 'Fintech', role: 'Backend Engineer · Mid',
      description: 'Join our payments infrastructure team. Work on high-throughput systems processing millions of transactions daily.',
      skills: ['Java', 'PostgreSQL', 'Kafka', 'Docker'], location: 'Remote',
      color: Color(0xFF635BFF)),
  Company(name: 'Figma', industry: 'Design Tools', role: 'Mobile Developer · Senior',
      description: 'Build prototyping and collaboration tools used by millions of designers worldwide.',
      skills: ['Flutter', 'Dart', 'TypeScript', 'WebGL'], location: 'Hybrid · NYC',
      color: Color(0xFFF24E1E)),
  Company(name: 'Vercel', industry: 'DevTools', role: 'Infrastructure Engineer · Mid',
      description: 'Push deployments to the edge. Work on serverless functions and CDN infrastructure at scale.',
      skills: ['Node.js', 'Rust', 'Docker', 'TypeScript'], location: 'Remote',
      color: Color(0xFF000000)),
  Company(name: 'PlanetScale', industry: 'Databases', role: 'Database Engineer · Senior',
      description: 'Build distributed, MySQL-compatible databases for the world\'s top engineering teams.',
      skills: ['Go', 'MySQL', 'Kubernetes', 'AWS'], location: 'Remote',
      color: Color(0xFF5A17EE)),
  Company(name: 'Linear', industry: 'Productivity', role: 'Frontend Engineer · Mid',
      description: 'Create the fastest, most opinionated issue tracker on the market. Small team, massive impact.',
      skills: ['React', 'TypeScript', 'GraphQL', 'PostgreSQL'], location: 'Remote',
      color: Color(0xFF5E6AD2)),
];

class CompanyCard extends StatelessWidget {
  const CompanyCard({super.key, required this.company});
  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          decoration: BoxDecoration(
            color: company.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Center(child: Text(company.name[0],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: company.color))),
            ),
            const SizedBox(height: 10),
            Text(company.name, style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color.fromARGB(45, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(company.industry,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
        // Body
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(company.role, style: theme.textTheme.h4),
            const SizedBox(height: 5),
            Row(children: [
              Icon(LucideIcons.mapPin, size: 13, color: company.color),
              const SizedBox(width: 4),
              Text(company.location, style: theme.textTheme.muted),
            ]),
            const SizedBox(height: 14),
            Text(company.description, overflow: TextOverflow.ellipsis, maxLines: 4),
            const Spacer(),
            Wrap(spacing: 6, runSpacing: 6,
                children: company.skills.map((s) => ShadBadge.outline(child: Text(s))).toList()),
          ]),
        )),
      ]),
    );
  }
}
