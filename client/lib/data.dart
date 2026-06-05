import 'package:flutter/material.dart';

// ── Avatar ──────────────────────────────────────────────────────
class AvatarData {
  final Color bg, fg;
  final String initials;
  const AvatarData(this.bg, this.fg, this.initials);
}

final avatarAlex = AvatarData(const Color(0xFFDCEFE6), const Color(0xFF0B6B4F), 'AR');
final avatarMira = AvatarData(const Color(0xFFE4E9FB), const Color(0xFF3046B0), 'MS');
final avatarTomas = AvatarData(const Color(0xFFFBE9DD), const Color(0xFFB5571E), 'TL');
final avatarYana = AvatarData(const Color(0xFFF3E2F7), const Color(0xFF8B3AA8), 'YK');
final avatarPetar = AvatarData(const Color(0xFFE2F3F7), const Color(0xFF1E7E97), 'PG');
final avatarNoa = AvatarData(const Color(0xFFFBE7EE), const Color(0xFFB02E59), 'NB');
final avatarMila = AvatarData(const Color(0xFFEAF0DC), const Color(0xFF5C7016), 'MP');
final avatarIvan = AvatarData(const Color(0xFFE0EEF6), const Color(0xFF235E86), 'ID');
final avatarSara = AvatarData(const Color(0xFFF7ECDD), const Color(0xFF9A6B1A), 'SK');
final avatarNiko = AvatarData(const Color(0xFFE6E9EE), const Color(0xFF3B4658), 'NT');
final avatarLea = AvatarData(const Color(0xFFEDE6FB), const Color(0xFF5B3CB0), 'LV');
final avatarDeniz = AvatarData(const Color(0xFFDCF0EC), const Color(0xFF0E7567), 'DA');
final avatarYou = AvatarData(const Color(0xFFD6F3E5), const Color(0xFF047857), 'YOU');

// ── Item kind ────────────────────────────────────────────────────
enum ItemKind { task, person }

abstract class DiscoverItem {
  String get id;
  ItemKind get kind;
  AvatarData get avatar;
  List<String> get skills;
}

// ── Person ───────────────────────────────────────────────────────
class Person implements DiscoverItem {
  @override final String id;
  @override ItemKind get kind => ItemKind.person;
  @override final AvatarData avatar;
  @override final List<String> skills;
  final String name, role, location, availability, bio;
  final int age;
  final Map<String, String> stats;
  final List<String> highlights;

  const Person({
    required this.id, required this.name, required this.age,
    required this.role, required this.avatar, required this.location,
    required this.availability, required this.skills, required this.bio,
    required this.stats, required this.highlights,
  });
}

// ── Task ─────────────────────────────────────────────────────────
class Task implements DiscoverItem {
  @override final String id;
  @override ItemKind get kind => ItemKind.task;
  @override final AvatarData avatar;
  @override final List<String> skills;
  final String title, project, owner, category, commitment, length, summary, posted;
  final AvatarData ownerAvatar;
  final List<String> details;
  final int applicants, match;

  const Task({
    required this.id, required this.title, required this.project,
    required this.owner, required this.ownerAvatar, required this.category,
    required this.avatar, required this.skills, required this.commitment,
    required this.length, required this.applicants, required this.posted,
    required this.summary, required this.details, required this.match,
  });
}

// ── Chat match ───────────────────────────────────────────────────
class MatchChat {
  final String id, name, context, preview, time;
  final AvatarData avatar;
  final int unread;
  final List<ChatMessage> thread;

  MatchChat({
    required this.id, required this.name, required this.avatar,
    required this.context, required this.unread, required this.time,
    required this.preview, required this.thread,
  });
}

class ChatMessage {
  final String from, text, time;
  const ChatMessage(this.from, this.text, this.time);
}

// ── Profile + options ────────────────────────────────────────────
class GoalOption {
  final String id, label, emoji;
  const GoalOption(this.id, this.label, this.emoji);
}

class AvailOption {
  final String id, label, sub;
  const AvailOption(this.id, this.label, this.sub);
}

class UserProfile {
  String name, email, password, role, headline;
  List<String> skills;
  List<String> goals;
  String avail;

  UserProfile({
    this.name = '', this.email = '', this.password = '',
    this.role = '', this.headline = '',
    List<String>? skills, List<String>? goals, this.avail = '',
  }) : skills = skills ?? [], goals = goals ?? [];

  UserProfile copyWith({
    String? name, String? email, String? password,
    String? role, String? headline,
    List<String>? skills, List<String>? goals, String? avail,
  }) => UserProfile(
    name: name ?? this.name, email: email ?? this.email,
    password: password ?? this.password, role: role ?? this.role,
    headline: headline ?? this.headline, skills: skills ?? this.skills,
    goals: goals ?? this.goals, avail: avail ?? this.avail,
  );
}

// ── Static data ──────────────────────────────────────────────────
final kPeople = <Person>[
  Person(id: 'p_alex', name: 'Alex Roumenov', age: 21, role: 'Backend Engineer · Java / Spring',
    avatar: avatarAlex, location: 'Sofia · TUES', availability: '~10h / week',
    skills: ['Java', 'Spring Boot', 'PostgreSQL', 'Docker'],
    bio: 'CS student who loves clean APIs and shipping fast. Built 3 hackathon projects this year, two with live users.',
    stats: {'projects': '7', 'matches': '12', 'rating': '4.9'},
    highlights: ['🏆 1st place — HackTUES X', 'Maintains an open-source Spring starter']),
  Person(id: 'p_mira', name: 'Mira Stefanova', age: 23, role: 'Frontend Developer · React',
    avatar: avatarMira, location: 'Plovdiv · Remote', availability: '~15h / week',
    skills: ['React', 'Next.js', 'TypeScript', 'TailwindCSS'],
    bio: 'Self-taught, bootcamp grad. I obsess over micro-interactions and accessible UI. Looking for a team that cares about craft.',
    stats: {'projects': '5', 'matches': '9', 'rating': '4.8'},
    highlights: ['Shipped a 10k-user side project', 'Design-systems nerd']),
  Person(id: 'p_tomas', name: 'Tomas Lazarov', age: 26, role: 'Full-stack & DevOps',
    avatar: avatarTomas, location: 'Varna · Remote', availability: '~8h / week',
    skills: ['Node.js', 'Docker', 'Kubernetes', 'AWS'],
    bio: 'I make deploys boring. Set up CI/CD, observability and k8s so you can focus on features.',
    stats: {'projects': '11', 'matches': '18', 'rating': '5.0'},
    highlights: ['Ran infra for a YC-backed startup', 'ArgoCD + Grafana evangelist']),
  Person(id: 'p_yana', name: 'Yana Koleva', age: 22, role: 'Product Designer',
    avatar: avatarYana, location: 'Sofia · Hybrid', availability: '~12h / week',
    skills: ['Figma', 'UI/UX', 'Prototyping', 'Branding'],
    bio: 'I turn rough ideas into testable prototypes. Strong on flows, weak on backend — that is where you come in.',
    stats: {'projects': '6', 'matches': '14', 'rating': '4.9'},
    highlights: ['Designed 4 launched mobile apps', 'Runs a small design club']),
  Person(id: 'p_petar', name: 'Petar Georgiev', age: 24, role: 'ML Engineer · Python',
    avatar: avatarPetar, location: 'Remote', availability: '~6h / week',
    skills: ['Python', 'PyTorch', 'FastAPI', 'Pandas'],
    bio: 'Recommender systems and small, useful models. I prefer a working demo over a perfect paper.',
    stats: {'projects': '4', 'matches': '7', 'rating': '4.7'},
    highlights: ['Kaggle Expert', 'Built a real-time rec engine']),
  Person(id: 'p_noa', name: 'Noa Borisova', age: 20, role: 'Mobile Developer · Flutter',
    avatar: avatarNoa, location: 'Burgas · Remote', availability: '~14h / week',
    skills: ['Flutter', 'Dart', 'Swift', 'Firebase'],
    bio: 'One codebase, two platforms. I love getting an app into the store before the hype dies.',
    stats: {'projects': '5', 'matches': '10', 'rating': '4.8'},
    highlights: ['2 apps on the App Store', 'Flutter community speaker']),
];

final kTasks = <Task>[
  Task(id: 't_bracket', title: 'Backend dev for a tournament platform', project: 'BracketUp',
    owner: 'Mila Popova', ownerAvatar: avatarMila, category: 'Backend',
    avatar: AvatarData(const Color(0xFFEAF0DC), const Color(0xFF5C7016), 'BU'),
    skills: ['Java', 'Spring Boot', 'PostgreSQL'], commitment: '~6h / week',
    length: 'Long-term · MVP', applicants: 4, posted: '2h ago',
    summary: 'We run e-sports brackets for student clubs. Need someone to own the match-scheduling service and its API.',
    details: ['Design the relational schema for tournaments, matches & seeding',
              'Build the REST API the React frontend already expects',
              'Pair with our DevOps person on Docker + CI'],
    match: 92),
  Task(id: 't_streaky', title: 'React frontend for a habit tracker', project: 'Streaky',
    owner: 'Ivan Dimitrov', ownerAvatar: avatarIvan, category: 'Frontend',
    avatar: AvatarData(const Color(0xFFE0EEF6), const Color(0xFF235E86), 'St'),
    skills: ['React', 'TypeScript', 'TailwindCSS'], commitment: '~8h / week',
    length: 'Side project', applicants: 7, posted: '5h ago',
    summary: 'Backend & designs are ready. Looking for a frontend dev to bring the streak screens to life with smooth animations.',
    details: ['Implement the swipe-able streak calendar from Figma',
              'Wire up the existing REST API with React Query',
              'Care about motion and empty states'],
    match: 84),
  Task(id: 't_kampi', title: 'Mobile dev for a campus events app', project: 'Kampi',
    owner: 'Sara Koleva', ownerAvatar: avatarSara, category: 'Mobile',
    avatar: AvatarData(const Color(0xFFF7ECDD), const Color(0xFF9A6B1A), 'Ka'),
    skills: ['Flutter', 'Dart', 'Firebase'], commitment: '~10h / week',
    length: 'Long-term · MVP', applicants: 3, posted: '1d ago',
    summary: 'Helping students discover events on campus. We have users waiting — need a Flutter dev to co-own the app.',
    details: ['Build the events feed + RSVP flow',
              'Push notifications via Firebase',
              'Ship to TestFlight + Play Store beta'],
    match: 71),
  Task(id: 't_devops', title: 'DevOps to set up our CI/CD', project: 'DevMatch Core',
    owner: 'Niko Todorov', ownerAvatar: avatarNiko, category: 'DevOps',
    avatar: AvatarData(const Color(0xFFE6E9EE), const Color(0xFF3B4658), 'DM'),
    skills: ['Docker', 'Kubernetes', 'GitHub Actions'], commitment: '~4h / week',
    length: 'Short · 2–3 weeks', applicants: 2, posted: '1d ago',
    summary: 'Code is on GitHub, app runs locally. We need automated builds, a k3s deploy and basic monitoring.',
    details: ['GitHub Actions → Docker image pipeline',
              'Deploy to a k3s cluster via ArgoCD',
              'Prometheus + Loki + Grafana dashboards'],
    match: 66),
  Task(id: 't_tunefit', title: 'ML engineer for a recommendation engine', project: 'TuneFit',
    owner: 'Lea Vasileva', ownerAvatar: avatarLea, category: 'ML',
    avatar: AvatarData(const Color(0xFFEDE6FB), const Color(0xFF5B3CB0), 'TF'),
    skills: ['Python', 'FastAPI', 'PyTorch'], commitment: '~6h / week',
    length: 'Research → MVP', applicants: 5, posted: '2d ago',
    summary: 'Music + fitness. We want a model that recommends a playlist from a workout type.',
    details: ['Prototype a recommender on our dataset',
              'Wrap it in a FastAPI service',
              'Keep latency under 200ms'],
    match: 58),
  Task(id: 't_orbit', title: 'Designer for landing page + brand', project: 'Orbit',
    owner: 'Deniz Ahmedov', ownerAvatar: avatarDeniz, category: 'Design',
    avatar: AvatarData(const Color(0xFFDCF0EC), const Color(0xFF0E7567), 'Or'),
    skills: ['Figma', 'UI Design', 'Branding'], commitment: '~5h / week',
    length: 'Short · launch sprint', applicants: 6, posted: '3d ago',
    summary: 'A community tool for student orgs. The product works — it just looks like a hackathon project.',
    details: ['Define a lightweight brand + logo',
              'Design a marketing landing page',
              'Hand off a small component kit'],
    match: 49),
];

List<MatchChat> buildInitialMatches() => [
  MatchChat(id: 'm_mila', name: 'Mila Popova', avatar: avatarMila,
    context: 'BracketUp · Backend', unread: 2, time: '9:24',
    preview: 'Awesome — when could you hop on a quick call?',
    thread: [
      const ChatMessage('them', 'Hey! Saw you applied to the backend task 🙌', '9:02'),
      const ChatMessage('them', 'Your Spring starter repo is exactly our style.', '9:02'),
      const ChatMessage('me', 'Thanks! The match-scheduling part sounds fun. What is the current stack?', '9:15'),
      const ChatMessage('them', 'Spring Boot + Postgres, deployed on a k3s cluster.', '9:21'),
      const ChatMessage('them', 'Awesome — when could you hop on a quick call?', '9:24'),
    ]),
  MatchChat(id: 'm_ivan', name: 'Ivan Dimitrov', avatar: avatarIvan,
    context: 'Streaky · Frontend', unread: 0, time: 'Yesterday',
    preview: 'You: I can start on the calendar this weekend.',
    thread: [
      const ChatMessage('them', 'Designs are in Figma, link incoming.', 'Yʼday'),
      const ChatMessage('me', 'I can start on the calendar this weekend.', 'Yʼday'),
    ]),
  MatchChat(id: 'm_yana', name: 'Yana Koleva', avatar: avatarYana,
    context: 'You liked · Designer', unread: 0, time: 'Mon',
    preview: 'You matched! Say hi 👋',
    thread: [const ChatMessage('them', 'You matched! Say hi 👋', 'Mon')]),
];

const kAllSkills = [
  'Java', 'Spring Boot', 'Python', 'FastAPI', 'PyTorch', 'JavaScript', 'TypeScript',
  'React', 'Next.js', 'Vue', 'Node.js', 'Go', 'Rust', 'PostgreSQL', 'MongoDB',
  'Docker', 'Kubernetes', 'AWS', 'GitHub Actions', 'GraphQL', 'TailwindCSS',
  'Flutter', 'Dart', 'Swift', 'Kotlin', 'Firebase', 'Figma', 'UI/UX',
];

const kRoles = [
  'Backend Engineer', 'Frontend Developer', 'Full-stack Developer', 'Mobile Developer',
  'DevOps / Infra', 'ML Engineer', 'Product Designer', 'Founder / PM',
];

const kGoals = [
  GoalOption('mvp', 'Build an MVP with a small team', '🚀'),
  GoalOption('portfolio', 'Get real projects for my portfolio', '📁'),
  GoalOption('cofounder', 'Find a co-founder', '🤝'),
  GoalOption('oss', 'Contribute to open source', '🌱'),
  GoalOption('hackathon', 'Team up for a hackathon', '⚡'),
];

const kAvail = [
  AvailOption('few', '1–5 hrs / week', 'Casual'),
  AvailOption('some', '6–10 hrs / week', 'Steady'),
  AvailOption('lots', '10–20 hrs / week', 'Committed'),
  AvailOption('full', '20+ hrs / week', 'All-in'),
];

bool isMatchItem(DiscoverItem item) {
  if (item is Task) return item.match >= 80;
  return ['p_alex', 'p_yana', 'p_noa'].contains(item.id);
}

MatchChat makeMatchChat(DiscoverItem item) {
  String name, context;
  AvatarData avatar;
  if (item is Task) {
    name = item.owner;
    avatar = item.ownerAvatar;
    context = '${item.project} · ${item.category}';
  } else {
    final p = item as Person;
    name = p.name;
    avatar = p.avatar;
    context = 'You liked · ${p.role.split(' · ')[0]}';
  }
  return MatchChat(
    id: 'new_${item.id}', name: name, avatar: avatar,
    context: context, unread: 0, time: 'now',
    preview: 'You matched! Say hi 👋',
    thread: [const ChatMessage('them', 'You matched! Say hi 👋', 'now')],
  );
}
