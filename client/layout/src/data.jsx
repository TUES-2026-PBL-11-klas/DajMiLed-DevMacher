// data.jsx — DevMatch mock content (people, tasks, skills, matches)
// Exposed on window.DM

const AVATARS = {
  alex:  { bg: '#DCEFE6', fg: '#0B6B4F', initials: 'AR' },
  mira:  { bg: '#E4E9FB', fg: '#3046B0', initials: 'MS' },
  tomas: { bg: '#FBE9DD', fg: '#B5571E', initials: 'TL' },
  yana:  { bg: '#F3E2F7', fg: '#8B3AA8', initials: 'YK' },
  petar: { bg: '#E2F3F7', fg: '#1E7E97', initials: 'PG' },
  noa:   { bg: '#FBE7EE', fg: '#B02E59', initials: 'NB' },
  mila:  { bg: '#EAF0DC', fg: '#5C7016', initials: 'MP' },
  ivan:  { bg: '#E0EEF6', fg: '#235E86', initials: 'ID' },
  sara:  { bg: '#F7ECDD', fg: '#9A6B1A', initials: 'SK' },
  niko:  { bg: '#E6E9EE', fg: '#3B4658', initials: 'NT' },
  lea:   { bg: '#EDE6FB', fg: '#5B3CB0', initials: 'LV' },
  deniz: { bg: '#DCF0EC', fg: '#0E7567', initials: 'DA' },
  you:   { bg: '#D6F3E5', fg: '#047857', initials: 'YOU' },
};

// People you can swipe through (project owners looking for these)
const PEOPLE = [
  {
    id: 'p_alex', kind: 'person', name: 'Alex Roumenov', age: 21,
    role: 'Backend Engineer · Java / Spring', avatar: AVATARS.alex,
    location: 'Sofia · TUES', availability: '~10h / week',
    skills: ['Java', 'Spring Boot', 'PostgreSQL', 'Docker'],
    lookingFor: 'Co-founders & weekend MVP teams',
    bio: 'CS student who loves clean APIs and shipping fast. Built 3 hackathon projects this year, two with live users.',
    stats: { projects: 7, matches: 12, rating: '4.9' },
    highlights: ['🏆 1st place — HackTUES X', 'Maintains an open-source Spring starter'],
  },
  {
    id: 'p_mira', kind: 'person', name: 'Mira Stefanova', age: 23,
    role: 'Frontend Developer · React', avatar: AVATARS.mira,
    location: 'Plovdiv · Remote', availability: '~15h / week',
    skills: ['React', 'Next.js', 'TypeScript', 'TailwindCSS'],
    lookingFor: 'A polished product to build a portfolio piece',
    bio: 'Self-taught, bootcamp grad. I obsess over micro-interactions and accessible UI. Looking for a team that cares about craft.',
    stats: { projects: 5, matches: 9, rating: '4.8' },
    highlights: ['Shipped a 10k-user side project', 'Design-systems nerd'],
  },
  {
    id: 'p_tomas', kind: 'person', name: 'Tomas Lazarov', age: 26,
    role: 'Full-stack & DevOps', avatar: AVATARS.tomas,
    location: 'Varna · Remote', availability: '~8h / week',
    skills: ['Node.js', 'Docker', 'Kubernetes', 'AWS'],
    lookingFor: 'Early founders who need infra done right',
    bio: 'I make deploys boring. Set up CI/CD, observability and k8s so you can focus on features.',
    stats: { projects: 11, matches: 18, rating: '5.0' },
    highlights: ['Ran infra for a YC-backed startup', 'ArgoCD + Grafana evangelist'],
  },
  {
    id: 'p_yana', kind: 'person', name: 'Yana Koleva', age: 22,
    role: 'Product Designer', avatar: AVATARS.yana,
    location: 'Sofia · Hybrid', availability: '~12h / week',
    skills: ['Figma', 'UI/UX', 'Prototyping', 'Branding'],
    lookingFor: 'Engineers who want a designer on the team early',
    bio: 'I turn rough ideas into testable prototypes. Strong on flows, weak on backend — that is where you come in.',
    stats: { projects: 6, matches: 14, rating: '4.9' },
    highlights: ['Designed 4 launched mobile apps', 'Runs a small design club'],
  },
  {
    id: 'p_petar', kind: 'person', name: 'Petar Georgiev', age: 24,
    role: 'ML Engineer · Python', avatar: AVATARS.petar,
    location: 'Remote', availability: '~6h / week',
    skills: ['Python', 'PyTorch', 'FastAPI', 'Pandas'],
    lookingFor: 'A product where ML is the core, not a buzzword',
    bio: 'Recommender systems and small, useful models. I prefer a working demo over a perfect paper.',
    stats: { projects: 4, matches: 7, rating: '4.7' },
    highlights: ['Kaggle Expert', 'Built a real-time rec engine'],
  },
  {
    id: 'p_noa', kind: 'person', name: 'Noa Borisova', age: 20,
    role: 'Mobile Developer · Flutter', avatar: AVATARS.noa,
    location: 'Burgas · Remote', availability: '~14h / week',
    skills: ['Flutter', 'Dart', 'Swift', 'Firebase'],
    lookingFor: 'A founding team that needs a mobile app, fast',
    bio: 'One codebase, two platforms. I love getting an app into the store before the hype dies.',
    stats: { projects: 5, matches: 10, rating: '4.8' },
    highlights: ['2 apps on the App Store', 'Flutter community speaker'],
  },
];

// Tasks you can swipe through (you apply to these)
const TASKS = [
  {
    id: 't_bracket', kind: 'task', title: 'Backend dev for a tournament platform',
    project: 'BracketUp', owner: 'Mila Popova', ownerAvatar: AVATARS.mila,
    category: 'Backend', avatar: { bg: '#EAF0DC', fg: '#5C7016', initials: 'BU' },
    skills: ['Java', 'Spring Boot', 'PostgreSQL'],
    commitment: '~6h / week', length: 'Long-term · MVP', applicants: 4, posted: '2h ago',
    summary: 'We run e-sports brackets for student clubs. Need someone to own the match-scheduling service and its API.',
    details: [
      'Design the relational schema for tournaments, matches & seeding',
      'Build the REST API the React frontend already expects',
      'Pair with our DevOps person on Docker + CI',
    ],
    match: 92,
  },
  {
    id: 't_streaky', kind: 'task', title: 'React frontend for a habit tracker',
    project: 'Streaky', owner: 'Ivan Dimitrov', ownerAvatar: AVATARS.ivan,
    category: 'Frontend', avatar: { bg: '#E0EEF6', fg: '#235E86', initials: 'St' },
    skills: ['React', 'TypeScript', 'TailwindCSS'],
    commitment: '~8h / week', length: 'Side project', applicants: 7, posted: '5h ago',
    summary: 'Backend & designs are ready. Looking for a frontend dev to bring the streak screens to life with smooth animations.',
    details: [
      'Implement the swipe-able streak calendar from Figma',
      'Wire up the existing REST API with React Query',
      'Care about motion and empty states',
    ],
    match: 84,
  },
  {
    id: 't_kampi', kind: 'task', title: 'Mobile dev for a campus events app',
    project: 'Kampi', owner: 'Sara Koleva', ownerAvatar: AVATARS.sara,
    category: 'Mobile', avatar: { bg: '#F7ECDD', fg: '#9A6B1A', initials: 'Ka' },
    skills: ['Flutter', 'Dart', 'Firebase'],
    commitment: '~10h / week', length: 'Long-term · MVP', applicants: 3, posted: '1d ago',
    summary: 'Helping students discover events on campus. We have users waiting — need a Flutter dev to co-own the app.',
    details: [
      'Build the events feed + RSVP flow',
      'Push notifications via Firebase',
      'Ship to TestFlight + Play Store beta',
    ],
    match: 71,
  },
  {
    id: 't_devops', kind: 'task', title: 'DevOps to set up our CI/CD',
    project: 'DevMatch Core', owner: 'Niko Todorov', ownerAvatar: AVATARS.niko,
    category: 'DevOps', avatar: { bg: '#E6E9EE', fg: '#3B4658', initials: 'DM' },
    skills: ['Docker', 'Kubernetes', 'GitHub Actions'],
    commitment: '~4h / week', length: 'Short · 2–3 weeks', applicants: 2, posted: '1d ago',
    summary: 'Code is on GitHub, app runs locally. We need automated builds, a k3s deploy and basic monitoring.',
    details: [
      'GitHub Actions → Docker image pipeline',
      'Deploy to a k3s cluster via ArgoCD',
      'Prometheus + Loki + Grafana dashboards',
    ],
    match: 66,
  },
  {
    id: 't_tunefit', kind: 'task', title: 'ML engineer for a recommendation engine',
    project: 'TuneFit', owner: 'Lea Vasileva', ownerAvatar: AVATARS.lea,
    category: 'ML', avatar: { bg: '#EDE6FB', fg: '#5B3CB0', initials: 'TF' },
    skills: ['Python', 'FastAPI', 'PyTorch'],
    commitment: '~6h / week', length: 'Research → MVP', applicants: 5, posted: '2d ago',
    summary: 'Music + fitness. We want a model that recommends a playlist from a workout type. Data is collected and waiting.',
    details: [
      'Prototype a recommender on our dataset',
      'Wrap it in a FastAPI service',
      'Keep latency under 200ms',
    ],
    match: 58,
  },
  {
    id: 't_orbit', kind: 'task', title: 'Designer for landing page + brand',
    project: 'Orbit', owner: 'Deniz Ahmedov', ownerAvatar: AVATARS.deniz,
    category: 'Design', avatar: { bg: '#DCF0EC', fg: '#0E7567', initials: 'Or' },
    skills: ['Figma', 'UI Design', 'Branding'],
    commitment: '~5h / week', length: 'Short · launch sprint', applicants: 6, posted: '3d ago',
    summary: 'A community tool for student orgs. The product works — it just looks like a hackathon project. Make it shine.',
    details: [
      'Define a lightweight brand + logo',
      'Design a marketing landing page',
      'Hand off a small component kit',
    ],
    match: 49,
  },
];

// Existing matches / conversations for the inbox
const MATCHES = [
  {
    id: 'm_mila', name: 'Mila Popova', avatar: AVATARS.mila,
    context: 'BracketUp · Backend', unread: 2, time: '9:24',
    preview: 'Awesome — when could you hop on a quick call?',
    accepted: true,
    thread: [
      { from: 'them', text: 'Hey! Saw you applied to the backend task 🙌', time: '9:02' },
      { from: 'them', text: 'Your Spring starter repo is exactly our style.', time: '9:02' },
      { from: 'me', text: 'Thanks! The match-scheduling part sounds fun. What is the current stack?', time: '9:15' },
      { from: 'them', text: 'Spring Boot + Postgres, deployed on a k3s cluster.', time: '9:21' },
      { from: 'them', text: 'Awesome — when could you hop on a quick call?', time: '9:24' },
    ],
  },
  {
    id: 'm_ivan', name: 'Ivan Dimitrov', avatar: AVATARS.ivan,
    context: 'Streaky · Frontend', unread: 0, time: 'Yesterday',
    preview: 'You: I can start on the calendar this weekend.',
    accepted: true,
    thread: [
      { from: 'them', text: 'Designs are in Figma, link incoming.', time: 'Yʼday' },
      { from: 'me', text: 'I can start on the calendar this weekend.', time: 'Yʼday' },
    ],
  },
  {
    id: 'm_yana', name: 'Yana Koleva', avatar: AVATARS.yana,
    context: 'You liked · Designer', unread: 0, time: 'Mon',
    preview: 'You matched! Say hi 👋',
    accepted: true,
    thread: [
      { from: 'them', text: 'You matched! Say hi 👋', time: 'Mon' },
    ],
  },
];

const ALL_SKILLS = [
  'Java', 'Spring Boot', 'Python', 'FastAPI', 'PyTorch', 'JavaScript', 'TypeScript',
  'React', 'Next.js', 'Vue', 'Node.js', 'Go', 'Rust', 'PostgreSQL', 'MongoDB',
  'Docker', 'Kubernetes', 'AWS', 'GitHub Actions', 'GraphQL', 'TailwindCSS',
  'Flutter', 'Dart', 'Swift', 'Kotlin', 'Firebase', 'Figma', 'UI/UX',
];

const ROLES = [
  'Backend Engineer', 'Frontend Developer', 'Full-stack Developer', 'Mobile Developer',
  'DevOps / Infra', 'ML Engineer', 'Product Designer', 'Founder / PM',
];

const GOALS = [
  { id: 'mvp', label: 'Build an MVP with a small team', emoji: '🚀' },
  { id: 'portfolio', label: 'Get real projects for my portfolio', emoji: '📁' },
  { id: 'cofounder', label: 'Find a co-founder', emoji: '🤝' },
  { id: 'oss', label: 'Contribute to open source', emoji: '🌱' },
  { id: 'hackathon', label: 'Team up for a hackathon', emoji: '⚡' },
];

const AVAIL = [
  { id: 'few', label: '1–5 hrs / week', sub: 'Casual' },
  { id: 'some', label: '6–10 hrs / week', sub: 'Steady' },
  { id: 'lots', label: '10–20 hrs / week', sub: 'Committed' },
  { id: 'full', label: '20+ hrs / week', sub: 'All-in' },
];

window.DM = { AVATARS, PEOPLE, TASKS, MATCHES, ALL_SKILLS, ROLES, GOALS, AVAIL };
